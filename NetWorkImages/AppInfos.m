//
//  AppInfos.m
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/12.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

#import "AppInfos.h"

@implementation AppInfos

+ (instancetype)AppInfoWithDict:(NSDictionary *)dict{
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}

@end
