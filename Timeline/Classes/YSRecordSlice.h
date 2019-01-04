//
//  YSRecordSlice.h
//  C_TTHcNetAPI
//
//  Created by DeJohn Dong on 2018/9/17.
//

#import <UIKit/UIKit.h>

//录像切片对象
@interface YSRecordSlice : NSObject

@property (nonatomic, copy) NSString *key; //索引Key
@property (nonatomic, assign) CGRect sliceFrame; //尺寸frame
@property (nonatomic, strong) UIColor *ysColor; //背景色
@property (nonatomic, assign) CGFloat secs_x; //origin.x
@property (nonatomic, assign) CGFloat secs_len; //width

/**
 工厂方法

 @return 切片对象
 */
+ (instancetype)recordSlice;

/**
 根据开始结束时间生成Key

 @param startTime 开始时间
 @param stopTime 结束时间
 */
- (void)ys_start:(NSTimeInterval)startTime stop:(NSTimeInterval)stopTime;

@end
