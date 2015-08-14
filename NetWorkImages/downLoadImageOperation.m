//
//  downLoadImageOperation.m
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/13.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "downLoadImageOperation.h"
#import "NSString+Dir.h"


@implementation downLoadImageOperation

/**
 *  图片下载操作入口方法，会自动被NSOperationQueue调用
 */
- (void)main{
    @autoreleasepool {
        
        NSLog(@"网络下载开始...");
       
        //2.0.1 下载图片
        NSURL *imgurl = [[NSURL alloc] initWithString:self.appIcon];
        //由于此时下载图片操作是在子线程中，此时如果图片下载响应缓慢也不会出现主线程卡住
        NSData *imgdata = [[NSData alloc] initWithContentsOfURL:imgurl];
        UIImage *img = [[UIImage alloc] initWithData:imgdata];
        
        //2.0.1 将图片保存到沙盒中
        [imgdata writeToFile:[self.appIcon cacheDir] atomically:YES];
        
        //回调方法设置图片
        if(self.complation != nil)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.complation(img);
            }];            
        }
        
    }
    
}

@end
