//
//  UIFont+YSSize.m
//  VideoGo
//
//  Created by DeJohn Dong on 2017/10/24.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import "UIFont+YSSize.h"

@implementation UIFont (YSSize)

- (CGSize)ys_sizeOfTextLimitWidth:(NSString *)text
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:self,
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 50.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

- (CGSize)ys_sizeOfText:(NSString *)text limitWidth:(CGFloat)limitWidth
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 4.0f;
    NSDictionary *attributes = @{NSFontAttributeName:self,
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [text boundingRectWithSize:CGSizeMake(limitWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

@end
