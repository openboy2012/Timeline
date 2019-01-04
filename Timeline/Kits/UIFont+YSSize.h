//
//  UIFont+YSSize.h
//  VideoGo
//
//  Created by DeJohn Dong on 2017/10/24.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (YSSize)

/**
 约束高度求宽度，高度一般情况下不会超过50px

 @param text 文字
 @return 尺寸
 */
- (CGSize)ys_sizeOfTextLimitWidth:(NSString *)text;


/**
 约束宽度求适应高度

 @param text 文字
 @param limitWidth 约束宽度
 @return 尺寸
 */
- (CGSize)ys_sizeOfText:(NSString *)text limitWidth:(CGFloat)limitWidth;

@end
