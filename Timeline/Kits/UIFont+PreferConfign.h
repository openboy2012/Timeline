//
//  YSFont+PreferConfign.h
//  VideoGo
//  用于本工程所有字体设置
//  Created by zhil.shi on 15/7/21.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

// 标准的字体大小
typedef NS_ENUM(NSInteger, YSFontSizeStandardStype)
{
    YSFontSizeF18 = 0,
    YSFontSizeF20,
    YSFontSizeF24,               // 12.0
    YSFontSizeF28,               // 14.0
    YSFontSizeF30,
    YSFontSizeF34,
    YSFontSizeF26,
    YSFontSizeF22,
    YSFontSizeF32,
    YSFontSizeF36,
    YSFontSizeF48,
};
// 字体名称
typedef NS_ENUM(NSInteger, YSFontNameStype)
{
    YSFontNameForCNType = 0,//中文，默认Heiti SC light
    YSFontNameForEnType,    //英文，默认Helvetica Neue
};


@interface UIFont (PreferConfign)

/**
 *  根据字体大小和字体,获取字体
 *
 *  @param fontSize 字体大小，根据视觉设计，有6种字体大小
 *  @param nameType 字体类型，根据视觉设计，对应中英文采用不同的字体名称
 *
 *  @return 字体对象
 */
+ (UIFont *)ys_preferredFontWithFontSize:(YSFontSizeStandardStype)fontSize fontNameType:(YSFontNameStype)nameType;

/**
 *  根据字体大小，获取中文的字体
 *
 *  @param fontSize 字体大小
 *
 *  @return 字体对象
 */
+ (UIFont *)ys_preferredFontOfChineseWithFontSize:(YSFontSizeStandardStype)fontSize;

//中文粗体
+ (UIFont *)ys_preferredFontOfChineseWithBoldFontSize:(YSFontSizeStandardStype)fontSize;
/**
 *  根据字体大小，获取英文的字体
 *
 *  @param fontSize 字体大小
 *
 *  @return 字体对象
 */
+ (UIFont *)ys_preferredFontOfEnglishWithFontSize:(YSFontSizeStandardStype)fontSize;

/**
 *  获取默认的中文字体
 *  字体大小为:YSFontSizeF30 字体名称为:Heiti SC light
 *  @return 字体对象
 */
+ (UIFont *)ys_preferredDefaultFontForChinese;

/**
 *  获取默认的英文字体
 *  字体大小为:YSFontSizeF30 字体名称为:Helvetica Neue
 *  @return 字体对象
 */
+ (UIFont *)ys_preferredDefaultFontForEnglish;

@end
