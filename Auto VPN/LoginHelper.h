//
//  LoginHelper.h
//  Auto VPN
//
//  Created by Grimmer Kang on 2014/3/9.
//  Copyright (c) 2014年 Grimmer Kang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHelper : NSObject

+ (BOOL)isLaunchAtStartup;
+ (void)toggleLaunchAtStartup;

@end
