//
//  downLoadImageOperation.h
//  NetWorkImages
//
//  Created by zhangyangbo on 15/8/13.
//  Copyright (c) 2015年 zhangyangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface downLoadImageOperation : NSOperation

@property (nonatomic,copy) NSString *appIcon;

@property (nonatomic,copy) void(^complation)(UIImage *image);




@end
