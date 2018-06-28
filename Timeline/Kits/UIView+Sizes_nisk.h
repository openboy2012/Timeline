//
//  UIView+Sizes.h
//  NISK-X
//
//  Created by wtndcs on 14-10-8.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Sizes_nisk)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

@property (nonatomic, readonly) CGPoint innerCenter;

@end
