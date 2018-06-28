//
//  YSDeviceJudger.h
//  VideoGo
//  当前设备类型判断
//  Created by zhil.shi on 15/7/2.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>
//注意 不要轻易调整型号顺序
typedef NS_ENUM(NSInteger, YSDeviceNameType)
{
    YSDevicei386   = 1,   //32-bit 模拟器
    YSDevicex86_64 , //64-bit 模拟器
    YSDeviceTV,
    YSDeviceiPod,
    YSDeviceiPhone3,//包含iPhone3 3GS
    YSDeviceiPad,   //不细分
    YSDeviceiPhone4,//包含iPhone4 iPhone4s
    YSDeviceiPhoneSe,//se
    YSDeviceiPhone5,//包含iPhone5 5c 5s
    YSDeviceiPhone6,//6
    YSDeviceiPhone6p,//6 plus
    YSDeviceiPhone6s,//6s
    YSDeviceiPhone6sp,//6s plus
    YSDeviceiPhone7,//7
    YSDeviceiPhone7P,//7P
    YSDeviceiPhone8,//8
    YSDeviceiPhone8P,//8p
    YSDeviceiPhoneX,//X
    YSDeviceUnknow
};
@interface YSDeviceJudger : NSObject
/**
 *  获取当前设备类型
 *
 *  @return 设备类型
 */
+ (NSString *)deviceName;


/**
 *  获取当前设备类型
 *
 *  @return 设备类型
 */
+ (YSDeviceNameType)deviceNameType;

///**
// *  设备当前是不是竖屏
// *
// *  @return YES Or No
// */
//+ (BOOL)isDeviceOrientationPortrait;
//
///**
// *  设备当前是不是横屏
// *
// *  @return YES Or No
// */
//+ (BOOL)isDeviceOrientationLandscape;


/**
 当前时刻耳机是否插着

 @return YES or NO
 */
+ (BOOL)isHeadsetPluggedIn;

+ (BOOL)isPhoneX;

/**
 当前设备是否可使用

 @return YES or NO
 */
+ (BOOL)isCanExplorer;

@end
