//
//  NSString+Dir.m
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/13.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

#import "NSString+Dir.h"

@implementation NSString (Dir)

/**
 *  获取沙盒中的当前路径字符串最后一个文件路径
 *
 *  @return <#return value description#>
 */
- (NSString *)cacheDir{
    NSString *cacheDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject ];
    
    return [cacheDirPath stringByAppendingPathComponent:[self lastPathComponent]];
}

@end
