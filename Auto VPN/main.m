//
//  main.m
//  Auto VPN
//
//  Created by Grimmer Kang on 2014/3/8.
//  Copyright (c) 2014年 Grimmer Kang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
