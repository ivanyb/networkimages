//
//  ViewController.m
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/12.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

#import "ViewController.h"
#import "AppInfos.h"
#import "NSString+Dir.h"
#import <UIKit/UIKit.h>
#import "downLoadImageOperation.h"

@interface ViewController ()

/**
 *  应用数据实体对象集合
 */
@property (nonatomic,strong)NSArray *appInfoList;

/**
 *  执行队列
 */
@property (nonatomic,strong)NSOperationQueue *appQueue;

/**
 *  用于存放网络下载回来的图片
 */
@property (nonatomic,strong) NSMutableDictionary *imgCache;

/**
 *  用于存放正在下载中的操作
 */
@property (nonatomic,strong) NSMutableDictionary *operationCache;



@end

@implementation ViewController

- (NSMutableDictionary *)operationCache{
    if(_operationCache == nil){
        _operationCache = [[NSMutableDictionary alloc] init];
    }
    return _operationCache;
}

- (NSMutableDictionary *)imgCache{
    if(_imgCache == nil){
        _imgCache = [[NSMutableDictionary alloc] init];
    }
    return _imgCache;
}

- (NSOperationQueue *)appQueue{
    if(_appQueue ==nil){
        
        _appQueue = [[NSOperationQueue alloc] init];
    }
    return _appQueue;
}


/**
 *  重写getter 方法 appInfoList
 */

- (NSArray *)appInfoList{
    if(_appInfoList ==nil){
        
        //从apps.plist中获取数据,将每条记录初始化AppInfos的实例后加入到AppInfoList数组中
        NSURL *dataurl = [[NSBundle mainBundle] URLForResource:@"apps.plist" withExtension:nil];
        NSArray *appDatas = [[NSArray alloc] initWithContentsOfURL:dataurl];
        //便利appDatas利用KVC将数据初始化到appinfos模型属性中
        NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:appDatas.count];
        for (NSDictionary *dict in appDatas) {
           [tmpArr addObject: [AppInfos AppInfoWithDict:dict ]];
        }
        
        //将tmpArr的数据赋值给_appInfoList
        _appInfoList = tmpArr;
        
    }
    
    return _appInfoList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //距离顶部20个长度，使得第一个数据图片不会被状态栏遮盖住
    self.tableView.contentInset= UIEdgeInsetsMake(20, 0, 0, 0);
    
    //沙盒各个目录操作
//    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //    NSString *docDir = [paths objectAtIndex:0];
    //    if(!docDir) {
    //        NSLog(@"Documents 目录未找到");
    //    }
    //    NSArray *array = [[NSArray alloc] initWithObjects:@"内容",@"content",nil];
    //    NSString *filePath = [docDir stringByAppendingPathComponent:@"testFile.txt"];
    //    [array writeToFile:filePath atomically:YES];

//    NSString *s = @"http://www.baidu.com/aa/1.png";
//    NSLog(@"%@",[s cacheDir]);
    
//    self.tableView.contentOffset = CGPointMake(x, y);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //self.appInfoList=nil;
    //清除图片缓存
    [self.imgCache removeAllObjects];
}

#pragma MARK: tableview表格控件的数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    return self.appInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"appcell"];
    AppInfos *app = self.appInfoList[indexPath.row];
    cell.textLabel.text=app.name;
    cell.detailTextLabel.text=app.download;
    
    //0.0 增加判断，如果app.img已经存在了数据则直接赋值
    //    if(app.img != nil)
    //    {
    //        cell.imageView.image=app.img;
    //        return cell;
    //    }
    //0.0 判断字典中有对于图片地址的图像，则直接赋值
    if(self.imgCache[app.icon] != nil){
        NSLog(@"来源于内存缓存... %ld",indexPath.row);
        cell.imageView.image=self.imgCache[app.icon];
        return cell;
    }
    
    //0.1 判断沙盒中是否有图片，有则获取后赋值给表格的图片
    if([[NSFileManager defaultManager] fileExistsAtPath:[app.icon cacheDir]]){
        NSLog(@"来源于沙盒缓存... %ld",indexPath.row);
        UIImage *img = [UIImage imageWithContentsOfFile:[app.icon cacheDir]];
        cell.imageView.image=img;
        return cell;
    }
    
    
    NSLog(@"队列操作数... %ld",self.appQueue.operationCount);
    
    //使用默认图片占位来保证子线程中下来回来的图片能自动在表格的cell中展示
    cell.imageView.image=[UIImage imageNamed:@"user_default.png"];
    
    if(self.operationCache[app.icon] != nil){
        NSLog(@"正在努力加载中... %ld",indexPath.row);
       
        //[self performSelector:@selector(reset:) withObject:indexPath afterDelay:0.1];
       
        return cell;
    }
    
    //下载图像
    [self DownLoadImage:indexPath];
    
    
    return cell;
  }

//- (void)reset:(NSIndexPath *)indexPath{
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//}

- (void)DownLoadImage:(NSIndexPath *)indexPath{
    
    AppInfos *app = self.appInfoList[indexPath.row];
    
//    //1.0 在子线程中设置图片
//    NSBlockOperation *downloadimg = [[NSBlockOperation alloc] init];
//    //2.0 在downloadimg操作中添加下载图片和设置图片的block代码
//    [downloadimg addExecutionBlock:^{
//        
//        //模拟第10张图片下载很缓慢，那么结果是会将第一条数据图片给覆盖，造成第一条数据图片显示紊乱
//        if(indexPath.row==13)
//        {
//            //使子线程睡眠5秒钟，模拟row==10的这条数据的图片需要5秒钟才能下载下来
//            [NSThread sleepForTimeInterval:5.0];
//        }
//        NSLog(@"网络下载... %ld",indexPath.row);
//        
//        //2.0.1 下载图片
//        NSURL *imgurl = [[NSURL alloc] initWithString:app.icon];
//        //由于此时下载图片操作是在子线程中，此时如果图片下载响应缓慢也不会出现主线程卡住
//        NSData *imgdata = [[NSData alloc] initWithContentsOfURL:imgurl];
//        UIImage *img = [[UIImage alloc] initWithData:imgdata];
//        
//        //2.0.1 将图片保存到沙盒中
//        [imgdata writeToFile:[app.icon cacheDir] atomically:YES];
//        
//        //2.0.2 在主线程中将下载完毕的图片设置给cell
//        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//        [mainQueue addOperationWithBlock:^{
//            //          cell.imageView.image=img;
//            //赋值给模型的img属性后刷新当前行数据
//            //app.img=img;
//            [self.imgCache setValue:img forKey:app.icon ];
//            
//            //从operationCache中移除下载图片操作
//            /**
//             *  优点：
//             1、减少operationCache字典的内存占用
//             2、打断ViewController与NSOperationQueue与ViewController的循环依赖
//             */
//            [self.operationCache removeObjectForKey:app.icon];
//            
//            
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            
//        }];
//    }];
    
    downLoadImageOperation *downloadimg = [[downLoadImageOperation alloc] init];
    //设置图片url和回调block
    downloadimg.appIcon=app.icon;
    downloadimg.complation= ^(UIImage *img){
        
         NSLog(@"网络下载完成...");
        
        [self.imgCache setValue:img forKey:app.icon ];
        
        //从operationCache中移除下载图片操作
        /**
         *  优点：
         1、减少operationCache字典的内存占用
         2、打断ViewController与NSOperationQueue与ViewController的循环依赖
         */
        [self.operationCache removeObjectForKey:app.icon];


        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    };
    
    
    //3.0 将操作添加到队列中
    [self.appQueue addOperation:downloadimg];
    
    //4.0 将操作添加进入缓存字典
    [self.operationCache setObject:downloadimg forKey:app.icon];
    
}

- (void)dealloc{
    NSLog(@"我去了~~");
}

@end
