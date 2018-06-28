//
//  YSDeviceJudger.m
//  VideoGo
//  判断设备系统类型 系统型号等
//  Created by zhil.shi on 15/7/2.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import "YSDeviceJudger.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>
static NSDictionary *iphonesTypesArray;
@implementation YSDeviceJudger
+ (void)load
{
    iphonesTypesArray= @{@"iPhone3,1":@(YSDeviceiPhone4),
                        @"iPhone3,2":@(YSDeviceiPhone4),
                        @"iPhone3,3":@(YSDeviceiPhone4),
                        @"iPhone4,1":@(YSDeviceiPhone4),
                        @"iPhone5,1":@(YSDeviceiPhone5),
                        @"iPhone5,2":@(YSDeviceiPhone5),
                        @"iPhone5,3":@(YSDeviceiPhone5),
                        @"iPhone5,4":@(YSDeviceiPhone5),
                        @"iPhone6,1":@(YSDeviceiPhone5),
                        @"iPhone6,2":@(YSDeviceiPhone5),
                        @"iPhone7,1":@(YSDeviceiPhone6p),
                        @"iPhone7,2":@(YSDeviceiPhone6),
                        @"iPhone8,1":@(YSDeviceiPhone6s),
                        @"iPhone8,2":@(YSDeviceiPhone6sp),
                        @"iPhone8,4":@(YSDeviceiPhoneSe),
                        @"iPhone9,1":@(YSDeviceiPhone7),//@"国行、日版、港行iPhone 7";
                        @"iPhone9,2":@(YSDeviceiPhone7P),//@"港行、国行iPhone 7 Plus";
                        @"iPhone9,3":@(YSDeviceiPhone7),// @"美版、台版iPhone 7";
                        @"iPhone9,4":@(YSDeviceiPhone7P),// @"美版、台版iPhone 7 Plus";
                        @"iPhone10,1":@(YSDeviceiPhone8),//@"国行(A1863)、日行(A1906)iPhone 8";
                        @"iPhone10,4":@(YSDeviceiPhone8),
                        @"iPhone10,2":@(YSDeviceiPhone8P),
                        @"iPhone10,5":@(YSDeviceiPhone8P),
                        @"iPhone10,3":@(YSDeviceiPhoneX),
                        @"iPhone10,6":@(YSDeviceiPhoneX),
                      };
}

+ (NSString *)deviceName
{
    struct utsname systemInfo ;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (YSDeviceNameType)deviceNameType
{
    static NSString *deviceName = nil;
    if (!deviceName)
    {
        deviceName = [[self class] deviceName];
    }
    
    if ([deviceName hasPrefix:@"i386"]) {
        return YSDevicei386;
    }
    
    if ([deviceName hasPrefix:@"x86_64"]) {
        return YSDevicex86_64;
    }
    
    if ([deviceName hasPrefix:@"iPod"]) {
        return YSDeviceiPod;
    }
    
    if ([deviceName hasPrefix:@"iPad"]) {
        return YSDeviceiPad;
    }
    
    if ([deviceName hasPrefix:@"AppleTV"]) {
        return YSDeviceTV;
    }
    
    NSNumber *iphoneType = [iphonesTypesArray objectForKey:deviceName];
    
    // iphones
    if(iphoneType)
    {
        return [iphoneType integerValue];
    }

    return YSDeviceUnknow;
}

//+ (BOOL)isDeviceOrientationPortrait
//{
//    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
//    {
//        return YES;
//    }
//    
//    return NO;
//
//}
//
//+ (BOOL)isDeviceOrientationLandscape
//{
//    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
//    {
//        return YES;
//    }
//    
//    return NO;
//}

+ (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs])
    {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}
+ (BOOL)isPhoneX
{
    if([self deviceNameType] == YSDeviceiPhoneX)
    {
        return YES;
    }
    return NO;
}
//==========================
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

+ (BOOL)isCanExplorer
{
    if([self isCanExplorerForTools])return YES;

    if([self isCanExplorerForCydiaUrlScheme])return YES;
    
    if([self isCanExplorerForApplicationsAccess])return YES;
    
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

// 是否存在对应的越狱工具
+ (BOOL)isCanExplorerForTools
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]])
        {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    return NO;
}

// 判断cydia url scheme
+ (BOOL)isCanExplorerForCydiaUrlScheme
{
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
//        NSLog(@"The device is jail broken!");
//        return YES;
//    }
    return NO;
}

//判断应用访问权限
#define USER_APP_PATH                 @"/User/Applications/"
+ (BOOL)isCanExplorerForApplicationsAccess
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        NSLog(@"applist = %@", applist);
        return YES;
    }
    return NO;
}

@end
