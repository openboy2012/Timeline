//
//  YSTimeBarPanel.h
//  VideoGo
//
//  Created by DeJohn Dong on 2018/09/13.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSRecordFileInfo;
@protocol YSTimeBarPanelDelegate;

@interface YSTimeBarPanel : UIView

@property (nonatomic, weak) id<YSTimeBarPanelDelegate> delegate; //代理方法
@property (nonatomic, assign) CGFloat ysZoomLevel; //缩放比例
@property (nonatomic, strong) UIScrollView *scrollView; //滚动视图
@property (nonatomic, assign) NSTimeInterval ysTimePointBeginTime; //时间刻度开始时间
@property (nonatomic, assign) NSTimeInterval ysTimePointEndTime; //时间刻度结束时间
@property (nonatomic, assign) BOOL ysZoomLevelEnable; //设置是否可缩放

/**
 通过缩放尺寸和视图大小实例化对象

 @param frame 视图大小
 @param scale 绽放尺寸
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame zoomLevel:(CGFloat)scale;

/**
 设置滚动区域背景色

 @param color 背景色
 */
- (void)setScrollViewBackgroundColor:(UIColor *)color;

/**
 设置是否显示时间基准中线

 @param hidden 是否隐藏
 */
- (void)setHiddenTimeIndicator:(BOOL)hidden;

// 绘制进度条
- (BOOL)reloadRecords:(NSArray *)recordArray;

// 清除绘制条
- (void)clearRecords;

// 更新进度位置
- (BOOL)refreshCurrentTimeInterval:(NSTimeInterval)currentTime;

/**
 重置时间
 */
- (void)resetTime;

/**
 处理转屏后的UI变化
 */
- (void)changedOrientation;

/**
 取消延时操作
 */
- (void)ys_cancelDelayAction;

@end

@protocol YSTimeBarPanelDelegate <NSObject>

@optional
- (void)timeBarWillStartDragging:(YSTimeBarPanel *)timeBar;

- (void)timeBar:(YSTimeBarPanel *)timeBar scrollDraggingTimeInterval:(NSTimeInterval)time;

- (void)timeBar:(YSTimeBarPanel *)timeBar scrollStoppedTimeInterval:(NSTimeInterval)time;

@end
