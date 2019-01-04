//
//  YSFont+PreferConfign.m
//  VideoGo
//
//  Created by zhil.shi on 15/7/21.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import "UIFont+PreferConfign.h"

static  NSString *fontNameForCN = @"Arial";//@"STHeitiTC-Light";
static  NSString *fontNameForEN = @"Arial";//@"HelveticaNeue";

@implementation UIFont (PreferConfign)
#pragma mark - public
+ (UIFont *)ys_preferredFontWithFontSize:(YSFontSizeStandardStype)fontSize fontNameType:(YSFontNameStype)nameType
{
    return [[self class] preferredFontForIOS7LaterWithFontSize:fontSize fontNameType:nameType];
}


+ (UIFont *)ys_preferredFontOfChineseWithFontSize:(YSFontSizeStandardStype)fontSize
{
    UIFont *font = [[self class] ys_preferredFontWithFontSize:fontSize fontNameType:YSFontNameForCNType];
    return font;
}
//中文粗体
+ (UIFont *)ys_preferredFontOfChineseWithBoldFontSize:(YSFontSizeStandardStype)fontSize
{
    UIFontDescriptor *fontDescriptor;
    // 粗体
    fontDescriptor = [UIFontDescriptor fontDescriptorWithName:[[self class] fontNameforFontNameStype:YSFontNameForCNType]
                                                         size:[[self class] fontSizeforFontSizeStanderdStype:fontSize]];
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    return [UIFont fontWithDescriptor:fontDescriptor size:0.0];
}


+ (UIFont *)ys_preferredFontOfEnglishWithFontSize:(YSFontSizeStandardStype)fontSize
{
    UIFont *font = [[self class] ys_preferredFontWithFontSize:fontSize fontNameType:YSFontNameForEnType];
    return font;
}


+ (UIFont *)ys_preferredDefaultFontForChinese
{
    UIFont *font = [[self class] ys_preferredFontWithFontSize:YSFontSizeF30 fontNameType:YSFontNameForCNType];
    return font;
}


+ (UIFont *)ys_preferredDefaultFontForEnglish
{
    UIFont *font = [[self class] ys_preferredFontWithFontSize:YSFontSizeF30 fontNameType:YSFontNameForEnType];
    return font;
}

//iOS 7 以后
+ (UIFont *)preferredFontForIOS7LaterWithFontSize:(YSFontSizeStandardStype)fontSize fontNameType:(YSFontNameStype)nameType
{
    UIFontDescriptor* fontDescriptor;
    // 粗体
    if ([[self class] isFontBoldForFontSizeStanderStype:fontSize])
    {
        fontDescriptor = [UIFontDescriptor fontDescriptorWithName:[[self class] fontNameforFontNameStype:nameType]
                                                             size:[[self class] fontSizeforFontSizeStanderdStype:fontSize]];
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];

    }
    else
    {
        fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorNameAttribute:[[self class] fontNameforFontNameStype:nameType],
                                                                                                UIFontDescriptorSizeAttribute:@([[self class] fontSizeforFontSizeStanderdStype:fontSize])}];
    }
    return [UIFont fontWithDescriptor:fontDescriptor size:0.0];

}

// ios 7 以前
+ (UIFont *)preferredFontForIOS7BeforeWithFontSize:(YSFontSizeStandardStype)fontSize fontNameType:(YSFontNameStype)nameType
{
    UIFont *font = [UIFont fontWithName:[[self class] fontNameforFontNameStype:nameType]
                                   size:[[self class] fontSizeforFontSizeStanderdStype:fontSize]];
    return font;
}

#pragma mark - private
+ (CGFloat)fontSizeforFontSizeStanderdStype:(YSFontSizeStandardStype)sizeType
{
    switch (sizeType)
    {
        case YSFontSizeF18:
            return 9.0;
            
        case YSFontSizeF20:
            return 10.0;
            
        case YSFontSizeF24:
            return 12.0;
            
        case YSFontSizeF28:
            return 14.0;
            
        case YSFontSizeF30:
            return 15.0;
            
        case YSFontSizeF34:
            return 17.0;
            
        case YSFontSizeF26:
            return 13.0;
            
        case YSFontSizeF22:
            return 11.0;
            
        case YSFontSizeF32:
            return 16.0;
        case YSFontSizeF36:
            return 18.0;
        case YSFontSizeF48:
            return 24.0;
        default:
            return 17.0;
    }
}

+ (NSString *)fontNameforFontNameStype:(YSFontNameStype)fontType
{
    switch (fontType)
    {
        case YSFontNameForCNType:
            return fontNameForCN;
            
        case YSFontNameForEnType:
            return fontNameForEN;
            
        default:
            return fontNameForCN;
    }
}

+ (BOOL)isFontBoldForFontSizeStanderStype:(YSFontSizeStandardStype)sizeType
{
    return NO;
}
@end
