//
//  AppInfos.h
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/12.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppInfos : NSObject

@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic,copy) NSString *download;

/**
 *  保存网络下载的图像
 */
//@property(nonatomic,strong) UIImage *img;

+ (instancetype)AppInfoWithDict:(NSDictionary *)dict;

@end
