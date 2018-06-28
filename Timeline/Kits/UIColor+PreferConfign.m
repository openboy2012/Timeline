//
//  UIColor+PreferConfign.m
//  VideoGo
//
//  Created by zhil.shi on 15/7/27.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import "UIColor+PreferConfign.h"

@implementation UIColor (PreferConfign)

+ (UIColor *)ys_preferColorWithType:(YSColorType)colorType
{
    return YS_UIColorFromRGB([[self class] colorHexStringWithColorType:colorType],1.0);
}

+ (NSUInteger)colorHexStringWithColorType:(YSColorType)colorType
{
    switch (colorType)
    {
        case YSColorC1Type:
            return 0xf37f4c;
            break;
        case YSColorC2Type:
            return 0x333333;
            break;
        case YSColorC3Type:
            return 0x666666;
            break;
        case YSColorC4Type:
            return 0x8d8d8d;
            break;
        case YSColorC5Type:
            return 0x999999;
            break;
        case YSColorC6Type:
            return 0xb7b7b7;
            break;
        case YSColorC7Type:
            return 0xcacaca;
            break;
        case YSColorC8Type:
            return 0xe1e1e1;
            break;
        case YSColorC9Type:
            return 0xf4f4f4;
            break;
        case YSColorC10Type:
            return 0xca511c;
            break;
        case YSColorC11Type:
            return 0xf9f9f9;
       case YSColorC12Type:
            return 0xff3b30;
        case YSColorC13Type:
            return 0x09bb07;
        default:
            return 0x333333;
            break;
    }
}

+ (UIColor *)ys_defaultPreferColor
{
    return YS_UIColorFromRGB([[self class]colorHexStringWithColorType:YSColorC1Type],1.0);
}

+ (UIColor *)ys_lineGray
{
    return YS_UIColorFromRGB(0xc8c8c8,1.0);
}

+ (UIColor *)ys_darkGray
{
    return YS_UIColorFromRGB(0x6e6e6e,1.0);
}
@end
