//
//  YSTimeBarPanel.m
//  VideoGo
//
//  Created by DeJohn Dong on 2018/09/13.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "YSTimeBarPanel.h"
#import "YSRecordFileInfo.h"
#import "UIFont+YSSize.h"
#import "UIColor+PreferConfign.h"
#import "UIView+Sizes_nisk.h"
#import "UIFont+PreferConfign.h"
#import "YSTimeNode.h"
#import "YSRecordSlice.h"
#import "Masonry.h"

#define YS_NOT_IPHONE4 (!CGSizeEqualToSize(CGSizeMake(320, 480), [UIScreen mainScreen].bounds.size) && !CGSizeEqualToSize(CGSizeMake(480, 320), [UIScreen mainScreen].bounds.size))

@interface YSTimeBarPanel()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSNumber *lastMinutesPerPage; //缩放过程中最新的一页占多少分钟
@property (nonatomic, assign) NSTimeInterval currentTime; //当前时间
@property (nonatomic, assign) CGFloat ysHoursPerPage; //一个屏幕宽度多少个小时，默认1个小时
@property (nonatomic, strong) UIActivityIndicatorView *ysIndicatorView;
@property (nonatomic, strong) NSMutableArray *recordSliceList; //录像片段视图数组
@property (nonatomic, strong) NSMutableArray *timeNodeList; //时间刻度
@property (nonatomic, strong) UIImageView *indicator; // 黄线图标
@property (nonatomic, strong) UIView *ysContentView; // 用于绘制的父视图
@property (nonatomic, strong) NSMutableSet *ysRecycleTimeNodeSet; //时间刻度回收Set
@property (nonatomic, strong) NSMutableSet *ysRecycleRecordSet; //切片回收Set
@property (nonatomic, strong) NSMutableDictionary *ysVisibleViews; //显示UI字典
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer; //双指缩放
@property (nonatomic, assign) BOOL needShowIndicator; //是否要显示时间指针
@property (nonatomic, assign) BOOL isLandscape; //是否已经横屏
@property (nonatomic, assign) CGRect ysVisibleRect; //有效显示的区域范围

@end

@implementation YSTimeBarPanel

- (void)dealloc
{
    _delegate = nil;
    _scrollView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.timeNodeList = [NSMutableArray array];
        self.recordSliceList = [NSMutableArray array];
        self.ysHoursPerPage = 1.0f;
        self.ysZoomLevel = 1.0f;
        self.ysZoomLevelEnable = YES;
        
        self.ysVisibleViews = [NSMutableDictionary dictionaryWithCapacity:0];
        self.ysRecycleTimeNodeSet = [NSMutableSet setWithCapacity:0];
        self.ysRecycleRecordSet = [NSMutableSet setWithCapacity:0];
        
        [self ys_addContentViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame zoomLevel:(CGFloat)scale
{
    self  = [self initWithFrame:frame];
    if (self)
    {
        self.ysZoomLevel = scale;
    }
    return self;
}


#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.recordSliceList count] <= 0)
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(timeBarWillStartDragging:)])
    {
        [self.delegate timeBarWillStartDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.ysVisibleRect = CGRectMake(scrollView.contentOffset.x - self.width/2, 0, scrollView.width * 3.0/2.0, self.height);
    if (scrollView.tracking ||
        scrollView.decelerating ||
        scrollView.dragging)
    {
        CGPoint curPoint = [scrollView contentOffset];
        if (curPoint.x < 0)
        {
            _currentTime = _ysTimePointBeginTime;
        }
        else if (curPoint.x > self.frame.size.width * 24.0 / self.ysHoursPerPage)
        {
            _currentTime = _ysTimePointEndTime + 1;
        }
        else
        {
            CGFloat secPerPix = self.ysHoursPerPage * 3600.0 / self.frame.size.width;
            NSInteger secs = curPoint.x * secPerPix;
            _currentTime = _ysTimePointBeginTime + secs;
        }
        
        if ([self.delegate respondsToSelector:@selector(timeBar:scrollDraggingTimeInterval:)])
        {
            [self.delegate timeBar:self scrollDraggingTimeInterval:_currentTime];
        }
        
        [self ys_cancelDelayAction];
        [self performSelector:@selector(scrollDraggingHandle:) withObject:scrollView afterDelay:0.15];
    }
    [self ysRefreshTimeNodes:self.timeNodeList isScroll:YES];
    [self refreshRecordSlice];
}

#pragma mark - Delegate Methods

- (void)scrollDraggingHandle:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(timeBar:scrollStoppedTimeInterval:)])
    {
        [self.delegate timeBar:self scrollStoppedTimeInterval:_currentTime];
    }
}

#pragma mark - UIPinchGestureRecognizer

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (!self.ysZoomLevelEnable)
    {
        return;
    }
    CGFloat tempZoomLevel = recognizer.scale * self.ysZoomLevel;
    
    CGFloat max = 12.0f; //最小刻度级别显示5分钟
    CGFloat min = 1.0f / 24.0f; //最大刻度级别显示24小时
    
    if (tempZoomLevel > max) {
        tempZoomLevel = max;
    }
    
    if (tempZoomLevel < min) {
        tempZoomLevel = min;
    }
    
    double tempPageMin = 60 / tempZoomLevel;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
//        [YSDCLog logUserAction:ACTION_PBACK_time_axis_kneading];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        self.ysZoomLevel = tempZoomLevel;
        return;
    }
    
    _lastMinutesPerPage = @(tempPageMin);
    [self performSelectorOnMainThread:@selector(updateTimeBanelWithPageMin:) withObject:_lastMinutesPerPage waitUntilDone:YES];
}

#pragma mark - Recycle Views

- (UIView *)ys_reuseRecordView:(YSRecordSlice *)slice
{
    UIView *sliceV = [self.ysVisibleViews objectForKey:slice.key];
    if (!sliceV)
    {
        sliceV = [self dequeueRecordView];
        if (!sliceV)
        {
            sliceV = [[UIView alloc] initWithFrame:CGRectZero];
        }
        [self.ysVisibleViews setObject:sliceV forKey:slice.key];
    }
    sliceV.frame = slice.sliceFrame;
    sliceV.backgroundColor = slice.ysColor;
    return sliceV;
}

- (UIView *)ys_reusePointView:(YSTimeNode *)node
{
    UIView *timePoint = [self.ysVisibleViews objectForKey:node.key];
    if (!timePoint)
    {
        timePoint = [self dequeueTimeNodeView];
        if (!timePoint)
        {
            timePoint = [self pointLineViewWithHeight:node.height];
        }
        [self.ysVisibleViews setObject:timePoint forKey:node.key];
    }
    //更新frame
    timePoint.frame = CGRectMake(node.pointCenter.x, node.pointCenter.y, 1.0/[UIScreen mainScreen].scale, node.height);
    if (node.timeStr.length > 0 && !node.timeHidden)
    {
        UILabel *label = [timePoint viewWithTag:1001];
        if(!label)
        {
            label = [self timeLabelWithFont:[UIFont ys_preferredFontOfChineseWithFontSize:YSFontSizeF24]];
        }
        label.tag = 1001;
        CGSize size = [label.font ys_sizeOfTextLimitWidth:node.timeStr];
        label.text = node.timeStr;
        CGFloat width = ceilf(size.width) + 3.0f;
        label.frame = CGRectMake(-width/2.0, timePoint.height, width, 16.0f);
        [timePoint addSubview:label];
    }
    else
    {
        UILabel *label = [timePoint viewWithTag:1001];
        [label removeFromSuperview];
    }
    return timePoint;
}

- (UIView *)dequeueTimeNodeView
{
    UIView *view = [self.ysRecycleTimeNodeSet anyObject];
    if (view)
    {
        [self.ysRecycleTimeNodeSet removeObject:view];
    }
    return view;
}

- (UIView *)dequeueRecordView
{
    UIView *view = [self.ysRecycleRecordSet anyObject];
    if (view)
    {
        [self.ysRecycleRecordSet removeObject:view];
    }
    return view;
}

/**
 检查scrollView中是否需要添加/删除这个子view.

 @param timeNode 子视图
 */
- (void)ys_checkSubviewAddOrRemove:(YSTimeNode *)timeNode
{
    if (![timeNode ys_avalible])
    {
        return;
    }
    
    //检查是否有有效视图内，且视图图可见
    if (CGRectContainsPoint(self.ysVisibleRect, timeNode.pointCenter) && !timeNode.pointHidden)
    {
        [self.scrollView addSubview:[self ys_reusePointView:timeNode]];
    }
    else
    {
        UIView *view = [self.ysVisibleViews objectForKey:timeNode.key];
        [self.ysVisibleViews removeObjectForKey:timeNode.key];
        if (view)
        {
            [view removeFromSuperview];
            //回收view
            [self.ysRecycleTimeNodeSet addObject:view];
        }
    }
}

- (void)ysRefreshTimeNodes:(NSArray *)nodeList isScroll:(BOOL)scrolling
{
    CGFloat hourWidth = self.width / self.ysHoursPerPage;
    CGFloat seperator = hourWidth / 60.0f;
    CGFloat minSeperator = seperator / 6.0f;
    
    CGFloat originHeight = self.height/2.0f;
    
    if (self.isLandscape ||
        !YS_NOT_IPHONE4)
    {
        originHeight = 20.0f;
    }
    //遍历小时的时间刻度
    [nodeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YSTimeNode *node = obj;
        //pointView
        node.pointCenter = CGPointMake(idx * hourWidth + self.width/2, originHeight);
        node.timeHidden = NO;
        if (seperator < 0.6f && (idx+1) % 2 == 0)
        {
            node.timeHidden = YES;
        }
        else if(seperator < 0.3f && idx % 4 == 2)
        {
            node.timeHidden = YES;
        }
        
        [self ys_checkSubviewAddOrRemove:node];
        
        //遍历分钟的时间刻度
        [node.subViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YSTimeNode *subNode = obj;
            
            subNode.pointCenter = CGPointMake(node.pointCenter.x + seperator * idx, originHeight);
            
            //每10分钟显示一个点
            if (idx % 10 == 0)
            {
                subNode.pointHidden = NO;
                subNode.timeHidden = seperator < 3.5f;
            }
            else
            {
                subNode.pointHidden = seperator < 5.0f;
                //显示时间信息
                if (idx % 5 == 0)
                {
                    subNode.timeHidden = minSeperator < 2.5f;
                }
                else
                {
                    subNode.timeHidden = minSeperator < 5.0f;
                }
            }
 
            [self ys_checkSubviewAddOrRemove:subNode];
            
            //遍历10秒的时间刻度
            [subNode.subViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YSTimeNode *minNode = obj;
                minNode.pointCenter = CGPointMake(subNode.pointCenter.x + minSeperator * (idx+1), originHeight);
                
                minNode.pointHidden = minSeperator < 5.0f;
                
                [self ys_checkSubviewAddOrRemove:minNode];
                
                //如果遍历到的点已经超过有效显示区域
                if ([minNode ys_avalible] && minNode.pointCenter.x > self.ysVisibleRect.origin.x + self.ysVisibleRect.size.width && scrolling)
                {
                    //跳出循环
                    *stop = YES;
                }
            }];
            
            //如果遍历到的点已经超过有效显示区域
            if ([subNode ys_avalible] && subNode.pointCenter.x > self.ysVisibleRect.origin.x + self.ysVisibleRect.size.width && scrolling)
            {
                //跳出循环
                *stop = YES;
            }
        }];
        
        //如果遍历到的点已经超过有效显示区域
        if ([node ys_avalible] && node.pointCenter.x > self.ysVisibleRect.origin.x + self.ysVisibleRect.size.width && scrolling)
        {
            //跳出循环
            *stop = YES;
        }
    }];
}

#pragma mark - Public Methods

- (void)setScrollViewBackgroundColor:(UIColor *)color
{
    if (self.scrollView)
    {
        self.scrollView.backgroundColor = color;
    }
}

- (void)setHiddenTimeIndicator:(BOOL)hidden
{
    if (!hidden)
    {
        //中线
        [self addSubview:self.indicator];
        [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@10);
            make.top.bottom.mas_equalTo(@0);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
    }
    self.needShowIndicator = !hidden;
    self.indicator.hidden = hidden;
}

- (void)changedOrientation
{
    self.isLandscape = NO;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        self.isLandscape = YES;
    }
    //转屏后重新刷新绘制的尺寸
    self.ysContentView.frame = CGRectMake(self.width/2.0, 0.0, self.width * 24.0 / self.ysHoursPerPage, self.height);
    self.scrollView.frame = CGRectMake(0.0, 0.0, self.width, self.height);
    [self reloadTimePanel];
}

- (void)resetTime
{
    // 设置滚动条位置
    if (self.scrollView)
    {
        if (self.needShowIndicator)
        {
            self.indicator.hidden = YES;
        }
        [self.scrollView setContentOffset:CGPointMake(-15.0f, 0) animated:NO];
    }
}

- (BOOL)reloadRecords:(NSMutableArray *)recordArray
{
    [self createScrollBarView];
    [self clearRecords];
    
    if (recordArray == nil)
    {
        return NO;
    }
    
    if ([recordArray count] == 0)
    {
        // 无录像提示
        return NO;
    }
    
    [self refreshRecords:recordArray];
    
    [self.ysIndicatorView stopAnimating];
    self.ysIndicatorView.hidden = YES;
    if (self.needShowIndicator)
    {
        self.indicator.hidden = NO;
    }

    return YES;
}

- (void)clearRecords
{
    [self.ysIndicatorView startAnimating];
    self.ysIndicatorView.hidden = NO;
    [self resetTime];
    // 首先清空原录像视图View
    if ([self.recordSliceList count] > 0)
    {
        [self.recordSliceList removeAllObjects];
    }
    //清理片段UI
    [[self.ysContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

/** @fn	updateSlider
 *  @brief  更新进度位置
 *  @param  currentTime - 当前播放时间
 *  @return 无
 */
- (BOOL)refreshCurrentTimeInterval:(NSTimeInterval)currentTime;
{    
    if (self.scrollView.tracking ||
        self.scrollView.decelerating ||
        self.scrollView.dragging)
    {
        return YES;
    }
    
    // 更新进度条位置
    if (self.scrollView)
    {
        self.currentTime = currentTime;
        [self refreshScrollViewIndicator:currentTime animated:YES];
    }
    
    return YES;
}

#pragma mark - Private Methods

- (void)ys_addContentViews
{
    self.backgroundColor = [UIColor clearColor];
    
    //上下2条线
    UIView *baseLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    baseLine.backgroundColor = YS_UIColorFromRGB(0xc9c9c9, 1.0f);
    baseLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:baseLine];
    
    UIView *baseButtomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.width, 1)];
    baseButtomLine.backgroundColor = YS_UIColorFromRGB(0xc9c9c9, 1.0f);
    baseButtomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:baseButtomLine];
    
    // 创建滑动播放视图组
    [self addSubview:self.scrollView];
    [self addSubview:self.ysIndicatorView];
    [self.ysIndicatorView startAnimating];
    
    // 更新UI约束
    [self ys_layout];
}

- (void)ys_layout
{
    [self.ysIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(@30);
    }];
}

- (void)ys_cancelDelayAction
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollDraggingHandle:) object:self.scrollView];
}

- (void)refreshScrollViewIndicator:(NSTimeInterval)currentTime animated:(BOOL)animated
{
    if (!self.scrollView)
    {
        return;
    }
    long secs_x = currentTime - self.ysTimePointBeginTime;
    if (secs_x < 0)
    {
        secs_x = 0;
    }
    CGPoint curPoint = CGPointMake(secs_x * self.frame.size.width / self.ysHoursPerPage /3600, 0);
    [self.scrollView setContentOffset:curPoint animated:animated];
}

- (void)refreshRecordSlice
{
    CGFloat height = 0;
    if (self.isLandscape ||
        !YS_NOT_IPHONE4)
    {
        height = 20.0f;
    }
    else
    {
        height = self.height/2.0f;
    }
    CGFloat zoomValue = self.width / self.ysHoursPerPage / 3600; //缩放等级以后
    [self.recordSliceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YSRecordSlice *recordSlice = obj;
        recordSlice.sliceFrame = CGRectMake(recordSlice.secs_x * zoomValue, 0, recordSlice.secs_len * zoomValue, height);
        
        //与有效显示区域有交集且至少大于一个像素
        if (CGRectIntersectsRect(self.ysVisibleRect, recordSlice.sliceFrame)
//            && recordSlice.sliceFrame.size.width >= 1.0/[UIScreen mainScreen].scale
            )
        {
            UIView *sliceV = [self ys_reuseRecordView:recordSlice];
            [self.ysContentView addSubview:sliceV];
        }
        else
        {
            UIView *view = [self.ysVisibleViews objectForKey:recordSlice.key];
            [self.ysVisibleViews removeObjectForKey:recordSlice.key];
            if (view)
            {
                [view removeFromSuperview];
                [self.ysRecycleRecordSet addObject:view];
            }
        }
    }];
}

- (void)updateTimeBanelWithPageMin:(NSNumber *)minutesPerPage
{
    self.ysHoursPerPage = [minutesPerPage doubleValue] / 60;
    [self reloadTimePanel];
}

- (void)reloadTimePanel
{
    [self ysRefreshTimeNodes:self.timeNodeList isScroll:NO];
    self.ysContentView.width = ((YSTimeNode *)[self.timeNodeList lastObject]).pointCenter.x - self.width/2;
    [self.scrollView setContentSize:CGSizeMake(self.ysContentView.width + self.width, self.height)];
    [self refreshScrollViewIndicator:self.currentTime animated:NO];
    [self refreshRecordSlice];
}

- (void)refreshRecords:(NSArray<YSRecordFileInfo *> *)records
{
    if (0 == [records count])
    {
        return;
    }
    
    // 取出每段录像起始时间及结束时间并生成相应录像条视图
    for (YSRecordFileInfo *value in records)
    {
        // 处理如果录像文件开始时间早于00：00则将结束时间设为00：00
        if (value.startTime < self.ysTimePointBeginTime)
        {
            value.startTime = self.ysTimePointBeginTime;
        }
        
        // 处理如果录像文件结束时间超过24：00则将结束时间设为24：00
        if (value.stopTime > self.ysTimePointEndTime)
        {
            value.stopTime = self.ysTimePointEndTime;
        }
        
        //开始时间大于结束时间 过滤掉
        if (value.startTime > value.stopTime)
        {
            continue;
        }
        
        long secs_x = value.startTime - self.ysTimePointBeginTime;
        long secs_len = value.stopTime - secs_x - self.ysTimePointBeginTime;
        
        YSRecordSlice *recordSlice = [YSRecordSlice recordSlice];
        [recordSlice ys_start:value.startTime stop:value.stopTime]; //设置Key值
        recordSlice.secs_x = secs_x;
        recordSlice.secs_len = secs_len;
        
        if (value.ysFileType == 0)
        {
            recordSlice.ysColor = YS_UIColorFromRGB(0x6ebbf3, 1.0f); // 定时录像蓝色
        }
        else
        {
            recordSlice.ysColor = YS_UIColorFromRGB(0xff9252, 1.0f); // 告警录像橘黄色
        }
        
        [self.recordSliceList addObject:recordSlice];
    }
}

#pragma mark - Create TimeNode View

- (void)createTimeNodes
{
    CGFloat hourWidth = self.width / self.ysHoursPerPage;
    CGFloat minCount = 60.0f;
    CGFloat seperator = hourWidth / minCount;
    CGFloat secSeperator = seperator / 6.0f;
    for (int i = 0; i < 25; i++)
    {
        YSTimeNode *node = [YSTimeNode node];
        [self.timeNodeList addObject:node];
        //1小时刻度
        node.key = @(i * 60 * 6); //设置Key
        node.pointCenter = CGPointMake(i * hourWidth + self.width/2, 0);
        node.height = 12.0f;
        node.timeStr = [NSString stringWithFormat:@"%@:00", [self genString:i]];
        if (i >= 24)
        {
            break;
        }
        for (int j = 0; j < minCount; ++j)
        {
            //1分钟刻度
            YSTimeNode *minNode = [YSTimeNode node];
            if (j != 0) //1个小时的0分钟的刻度已经由小时刻度绘制
            {
                minNode.key = @(i * 60 * 6 + j * 6); //设置Key
                minNode.height = 8.0f;
                minNode.pointCenter = CGPointMake(node.pointCenter.x + seperator * j, 0);
                minNode.timeStr = [NSString stringWithFormat:@"%@:%02d", [self genString:i], j];
            }
            [node.subViewArray addObject:minNode];
            
            //10秒刻度数组
            NSMutableArray *secArray = [NSMutableArray array];
            minNode.subViewArray = secArray;
            
            for (int k = 1; k < 6; k++)
            {
                //10秒刻度
                YSTimeNode *sec10Node = [YSTimeNode node]; //设置Key
                sec10Node.key = @(i * 60 * 6 + j * 6 + k);
                sec10Node.pointCenter = CGPointMake(minNode.pointCenter.x + secSeperator * k, 0);
                sec10Node.height = 6.0f;
                [secArray addObject:sec10Node];
            }
        }
    }
}

- (NSString *)genString:(int)i
{
    if (i < 0 || i >= 60)
    {
        return @"00";
    }
    
    if (i < 10)
    {
        return [NSString stringWithFormat:@"0%d", i];
    }
    else
    {
        return [NSString stringWithFormat:@"%d", i];
    }
}

- (void)createScrollBarView
{
    if (!self.ysContentView)
    {
        // 添加录像片段绘制的父View
        self.ysContentView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2.0f, 0.0, self.width * 24 / self.ysHoursPerPage, self.height)];
        [self.scrollView setContentSize:CGSizeMake(self.ysContentView.width + self.width, self.scrollView.height)];
        [self.scrollView addSubview:self.ysContentView];
        [self createTimeNodes];
    }
}

- (UILabel *)timeLabelWithFont:(UIFont *)font
{
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectZero];
    [lblTime setBackgroundColor:[UIColor clearColor]];
    lblTime.textColor = [UIColor ys_preferColorWithType:YSColorC4Type];
    [lblTime setFont:font];
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.numberOfLines = 1;
    lblTime.userInteractionEnabled = NO;
    lblTime.layer.zPosition = 5;
    return lblTime;
}

- (UIView *)pointLineViewWithHeight:(CGFloat)height
{
    CGFloat originY = self.height/2.0f;
    UIImageView *hourPoint = [[UIImageView alloc] initWithFrame:CGRectMake(0, originY, 1.0/[UIScreen mainScreen].scale, height)];
    hourPoint.backgroundColor = [UIColor ys_preferColorWithType:YSColorC4Type];
    hourPoint.userInteractionEnabled = NO;
    return hourPoint;
}

#pragma mark - SET/GET Methods

- (void)setYsZoomLevel:(CGFloat)ysZoomLevel
{
    _ysZoomLevel = ysZoomLevel;
    double pageMin = 60 /ysZoomLevel;
    [self performSelectorOnMainThread:@selector(updateTimeBanelWithPageMin:) withObject:@(pageMin) waitUntilDone:YES];
}

- (void)setYsZoomLevelEnable:(BOOL)ysZoomLevelEnable
{
    _ysZoomLevelEnable = ysZoomLevelEnable;
    if (_ysZoomLevelEnable)
    {
        [self addGestureRecognizer:self.pinchRecognizer];
    }
    else
    {
        [self removeGestureRecognizer:self.pinchRecognizer];
    }
}

- (UIPinchGestureRecognizer *)pinchRecognizer
{
    if (!_pinchRecognizer)
    {
        _pinchRecognizer = ({
            UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
            recognizer.delegate = self;
            recognizer;
        });
    }
    return _pinchRecognizer;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = ({
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      self.width,
                                                                                      self.height)];
            
            [scrollView setBackgroundColor:YS_UIColorFromRGB(0xefefef, 1.0f)];
            scrollView.userInteractionEnabled = YES;
            scrollView.multipleTouchEnabled = YES;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.delegate = self;
            scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            scrollView;
        });
    }
    return _scrollView;
}

- (UIImageView *)indicator
{
    if (!_indicator)
    {
        _indicator = ({
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playback_time_bg"]];
            imageView.userInteractionEnabled = NO;
            imageView.layer.zPosition = 6;
            imageView;
        });
    }
    return _indicator;
}

- (UIActivityIndicatorView *)ysIndicatorView
{
    if (!_ysIndicatorView)
    {
        _ysIndicatorView = ({
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            activityView;
        });
    }
    return _ysIndicatorView;
}

@end


