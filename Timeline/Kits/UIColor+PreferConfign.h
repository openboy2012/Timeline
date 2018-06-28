//
//  UIColor+PreferConfign.h
//  VideoGo
//  APP 颜色配置
//  Created by zhil.shi on 15/7/27.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

// 颜色值
#define YS_UIColorFromRGB(rgbValue, alp)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alp]

typedef NS_ENUM(NSInteger, YSColorType)
{
    YSColorC1Type = 0, //0xf37f4c 小面积使用 用于特别突出强调
    YSColorC2Type,     //0x333333 用于主要文字颜色内容标题信息
    YSColorC3Type,     //0x666666 用于普通段落信息引导词色
    YSColorC4Type,     //0x8d8d8d 用于辅助文字色
    YSColorC5Type,     //0x999999 用于次要文字信息 辅助文字色
    YSColorC6Type,     //0xb7b7b7 辅助文字色
    YSColorC7Type,     //0xcacaca 分割线颜色 辅助文字颜色
    YSColorC8Type,     //0xe1e1e1 分割线颜色
    YSColorC9Type,     //0xf4f4f4 内容底色
    YSColorC10Type,    //0xca511c C1的高亮
    YSColorC11Type,    //0xf9f9f9
    YSColorC12Type,    // ff3b30
    YSColorC13Type,    // 09bb07
};

@interface UIColor (PreferConfign)

/**
 *  获取主要的颜色信息
 *
 *  @param colorType 类型
 *
 *  @return uicolor
 */
+ (UIColor *)ys_preferColorWithType:(YSColorType)colorType;

/**
 *  默认的主色调 YSColorC1Type
 *
 *  @return YSColorC1Type类型颜色
 */
+ (UIColor *)ys_defaultPreferColor;

/*
 线条灰色
 */
+ (UIColor *)ys_lineGray;

+ (UIColor *)ys_darkGray;
@end
