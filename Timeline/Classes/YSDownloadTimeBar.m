//
//  YSDownloadTimeBar.m
//  VideoGo
//
//  Created by DeJohn Dong on 2017/10/26.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import "YSDownloadTimeBar.h"
#import "UIColor+PreferConfign.h"
#import "UIView+Sizes_nisk.h"
#import "Masonry.h"
#import "YSDeviceJudger.h"

#define YSTimePointWidth (floorf((YSPBScreenWidth/30.0) * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale)
#define YSPBScreenHeight [UIScreen mainScreen].bounds.size.height
#define YSPBScreenWidth [UIScreen mainScreen].bounds.size.width

@interface YSTimeDrawInfo : NSObject

@property (nonatomic, assign) CGFloat originX; //起点
@property (nonatomic, assign) CGFloat length; //长度
@property (nonatomic, strong) UIColor *drawColor; //填充色

@end

@implementation YSTimeDrawInfo

@end

@interface YSTimePoint : NSObject

@property (nonatomic, assign) NSTimeInterval beginTime; //开始时间
@property (nonatomic, assign) NSTimeInterval endTime; //结束时间 = 开始时间 + 10s
@property (nonatomic, assign) CGFloat timeWidth; //时间占屏幕的宽度
@property (nonatomic, strong) NSMutableArray<YSTimeDrawInfo *> *drawInfos; //通常只有一个，也可能存在多个
@property (nonatomic, copy) NSString *timeText; //时间点
@property (nonatomic, strong) NSMutableArray<YSTimePoint *> *clusterTimePoints; //下级时间点数组

@end

@implementation YSTimePoint

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (NSMutableArray<YSTimeDrawInfo *> *)drawInfos
{
    if (!_drawInfos)
    {
        _drawInfos = ({
            NSMutableArray *array = [NSMutableArray new];
            array;
        });
    }
    return _drawInfos;
}

@end

@interface YSTimeBarCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *leftPoint; //左边点
@property (nonatomic, strong) NSMutableArray<UIView *> *recordViews; //录像片段填充
@property (nonatomic, strong) UIImageView *rightPoint; //右边点
@property (nonatomic, strong) UILabel *lblTime; //时间

- (void)setTimePoint:(YSTimePoint *)point;
- (void)isLastCell;

@end

@implementation YSTimeBarCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self.contentView addSubview:self.leftPoint];
    [self.leftPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.top.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(@(1.0/[UIScreen mainScreen].scale));
    }];
    [self.contentView addSubview:self.lblTime];
    [self.lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@40);
        make.centerX.mas_equalTo(self.leftPoint.mas_centerX);
        make.top.mas_equalTo(self.leftPoint.mas_bottom).offset(3);
        make.height.mas_equalTo(@20);
    }];
}

- (void)notLastCell
{
    if (self.rightPoint.superview)
    {
        [self.rightPoint removeFromSuperview];
        self.lblTime.text = nil;
        [self.lblTime mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@40);
            make.centerX.mas_equalTo(self.leftPoint.mas_centerX);
            make.top.mas_equalTo(self.leftPoint.mas_bottom).offset(3);
            make.height.mas_equalTo(@20);
        }];
    }
}

- (void)isLastCell
{
    [self.contentView addSubview:self.rightPoint];
    [self.rightPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right);
        make.top.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(@(1.0/[UIScreen mainScreen].scale));
    }];
    
    [self.lblTime mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@40);
        make.centerX.mas_equalTo(self.rightPoint.mas_centerX);
        make.top.mas_equalTo(self.rightPoint.mas_bottom).offset(3);
        make.height.mas_equalTo(@20);
    }];
    self.lblTime.text = @"24:00";
}

- (void)setTimePoint:(YSTimePoint *)point
{
    [self notLastCell];
    //移除旧视图
    if (self.recordViews.count > 0)
    {
        [self.recordViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    //如果存在绘制内容，重新添加绘制
    if (point.drawInfos.count > 0)
    {
        for (YSTimeDrawInfo *info in point.drawInfos)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(info.originX , 0, info.length, self.height/2.0f)];
            view.backgroundColor = info.drawColor;
            [self.contentView addSubview:view];
            [self.recordViews addObject:view];
        }
    }
}

#pragma mark - GET/SET Methods

- (UILabel *)lblTime
{
    if (!_lblTime)
    {
        _lblTime = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = [UIFont systemFontOfSize:10.f];
            label.textColor = [UIColor ys_preferColorWithType:YSColorC4Type];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _lblTime;
}

- (UIImageView *)leftPoint
{
    if (!_leftPoint)
    {
        _leftPoint = ({
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageV.backgroundColor = [UIColor ys_preferColorWithType:YSColorC4Type];
            imageV.userInteractionEnabled = NO;
            imageV.layer.zPosition = 10;
            imageV;
        });
    }
    return _leftPoint;
}

- (UIImageView *)rightPoint
{
    if (!_rightPoint)
    {
        _rightPoint = ({
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageV.backgroundColor = [UIColor ys_preferColorWithType:YSColorC4Type];
            imageV.userInteractionEnabled = NO;
            imageV.layer.zPosition = 10;
            imageV;
        });
    }
    return _rightPoint;
}


- (NSMutableArray<UIView *> *)recordViews
{
    if (!_recordViews)
    {
        _recordViews = ({
            NSMutableArray *views = [NSMutableArray new];
            views;
        });
    }
    return _recordViews;
}

@end

@interface YSDownloadTimeBar()<UIScrollViewDelegate,UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIImageView *redLineView;
@property (nonatomic, assign) NSTimeInterval curTime; //当前时间
@property (nonatomic, strong) NSValue *offsetValue; //偏移值
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer; //双指缩放
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) NSTimeInterval beginTime; //一天起始时间yyyy-MM-dd 00:00:00
@property (nonatomic, strong) NSMutableArray<YSTimePoint *> *timePoints; //时间点个数
@property (nonatomic, copy) NSArray<YSTimePoint *> *displayPoints; //显示的时间点个数

@property (nonatomic, strong) YSRecordFileInfo *fileInfo; //下载文件
@property (nonatomic, strong) YSRecordFileInfo *originFileInfo; //原始大小文件，通常是因为片段小于5分钟才有值
@property (nonatomic, assign) CGFloat layerOriginX;
@property (nonatomic, assign) CGFloat layerWidth;
@property (nonatomic, strong) YSRecordFileInfo *downloadFile; //下载录像片段

@end

@implementation YSDownloadTimeBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        // 创建滑动播放视图组
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:self.loadingView];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.collectionView.mas_centerX);
            make.centerY.mas_equalTo(self.collectionView.mas_centerY);
            make.width.height.mas_equalTo(@40);
        }];
        [self.loadingView startAnimating];
    }
    return self;
}
#pragma mark - UICollectionViewDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.displayPoints.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YSTimePoint *p = [self.timePoints objectAtIndex:indexPath.row];
    return CGSizeMake(p.timeWidth, self.height);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YSTimeBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YSTimeBarCell" forIndexPath:indexPath];
    cell.lblTime.text = nil;
    YSTimePoint *p = [self.displayPoints objectAtIndex:indexPath.row];
    [cell setTimePoint:p];
    if (indexPath.row == self.displayPoints.count - 1)
    {
        [cell isLastCell];
    }
    if (indexPath.row % 6 == 0) //1分钟显示一个时间
    {
        cell.lblTime.text = p.timeText;
    }
    return cell;
}

/**
 *  判断两个浮点数是否整除
 *
 *  @param firstNumber  第一个浮点数(被除数)
 *  @param secondNumber 第二个浮点数(除数,不能为0)
 *
 *  @return 返回值可判定是否整除
 */
- (BOOL)ys_judgeDivisibleWithFirstNumber:(CGFloat)firstNumber andSecondNumber:(CGFloat)secondNumber {
    // 默认记录为整除
    BOOL isDivisible = YES;
    
    if (secondNumber == 0)
    {
        return NO;
    }
    
    CGFloat result = firstNumber / secondNumber;
    NSString *resultStr = [NSString stringWithFormat:@"%f", result];
    NSRange range = [resultStr rangeOfString:@"."];
    NSString *subStr = [resultStr substringFromIndex:range.location + 1];
    
    for (NSInteger index = 0; index < subStr.length; index ++)
    {
        unichar ch = [subStr characterAtIndex:index];
        // 后面的字符中只要有一个不为0，就可判定不能整除，跳出循环
        if ('0' != ch) {
            isDivisible = NO;
            break;
        }
    }
    
    return isDivisible;
}

- (BOOL)ys_checkIndex:(NSInteger)index remainder:(NSInteger)remainder
{
    BOOL isNeedPadding = NO; //默认不需要偏移
    if (index == 0)
    {
        return isNeedPadding;
    }
    if (YSPBScreenWidth == 414.0 && index % 2 == 0 && index % 5 != 0) //经过计算 Plus是12个像素的求余值
    {
        isNeedPadding = YES;
    }
    else if ([YSDeviceJudger isPhoneX] && index % 2 == 0)
    {
        isNeedPadding = YES;
    }
    else
    {
        if (index % 3 == 0)
        {
            isNeedPadding = YES;
        }
    }
    return isNeedPadding;
}

- (CGFloat)ys_getPaddingWidth:(NSInteger)index;
{
    CGFloat realWidth = YSPBScreenWidth * [UIScreen mainScreen].scale;
    if ([self ys_judgeDivisibleWithFirstNumber:realWidth andSecondNumber:30.0]) //如果能被30整除
    {
        return YSTimePointWidth;
    }
    else
    {
        NSInteger remainder = realWidth - YSTimePointWidth * 30.0 * [UIScreen mainScreen].scale; //求余数
        if ([self ys_checkIndex:index remainder:remainder])
        {
            CGFloat paddings = 1.0 / [UIScreen mainScreen].scale; //均分到各个点的偏移值，余数除以屏幕倍数
            return YSTimePointWidth + paddings;
        }
        else
        {
            return YSTimePointWidth;
        }
    }
}

- (void)createAllPoints:(NSTimeInterval)beginTime records:(NSArray *)recordsArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        self.timePoints = [NSMutableArray new];
        [self.timePoints removeAllObjects];
        self.dateFormatter.dateFormat = @"HH:mm";
        for (NSInteger i = 0; i < 60 * 24 * 6; i++) //10秒一个点
        {
            YSTimePoint *point = [[YSTimePoint alloc] init];
            point.beginTime = beginTime + i * 10;
            point.endTime = point.beginTime + 10;
            point.timeWidth = [self ys_getPaddingWidth:i];
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:point.beginTime];
            point.timeText = [self.dateFormatter stringFromDate:time];
            [self.timePoints addObject:point];
        }
        
        [self drawItems:recordsArray];
        self.displayPoints = [self.timePoints copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            [self.collectionView reloadData];
            if (self.curTime > 0)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CGFloat pecent = (self.curTime - beginTime) / (3600.0 * 24.0); //计算时间的百分比
                    CGPoint offsetPoint = CGPointMake(pecent * self.collectionView.contentSize.width, 0.0f);
                    [self.collectionView setContentOffset:offsetPoint animated:NO];
                    if (self.didScrolledToOffsetTimeBlock)
                    {
                        self.didScrolledToOffsetTimeBlock(YES);
                    }
                });
            }
        });
    });
}

- (NSArray *)drawItems:(NSArray *)recordsArray
{
    NSInteger j = 0;
    for (NSInteger i = 0; i < recordsArray.count; i++)
    {
        YSRecordFileInfo *recordFileInfo = [recordsArray objectAtIndex:i];
        for (;j < self.timePoints.count; j++)
        {
            YSTimePoint *p = [self.timePoints objectAtIndex:j];
            if (p.beginTime >= recordFileInfo.startTime &&
                p.endTime <= recordFileInfo.stopTime) //点完全在片段内
            {
                YSTimeDrawInfo *info = [[YSTimeDrawInfo alloc] init];
                info.drawColor = (recordFileInfo.ysFileType == 0 ? YS_UIColorFromRGB(0x6ebbf3, 1.0f) : YS_UIColorFromRGB(0xff9252, 1.0f));
                info.originX = 0;
                info.length = p.timeWidth; //绘制全部
                [p.drawInfos addObject:info];
                continue;
            }
            else if (p.beginTime < recordFileInfo.startTime &&
                     p.endTime > recordFileInfo.startTime) //开始时间在片段外，结束时间在片段内
            {
                YSTimeDrawInfo *info = [[YSTimeDrawInfo alloc] init];
                info.drawColor = (recordFileInfo.ysFileType == 0 ? YS_UIColorFromRGB(0x6ebbf3, 1.0f) : YS_UIColorFromRGB(0xff9252, 1.0f));
                info.length = (p.endTime - recordFileInfo.startTime)/10.0 * p.timeWidth;
                info.originX = p.timeWidth - info.length;
                [p.drawInfos addObject:info];
                continue;
            }
            else if (p.endTime > recordFileInfo.stopTime) //结束时间在片段外了，开始时间在片段内
            {
                if (p.beginTime < recordFileInfo.startTime) //如果整个片段在这10秒范围呢
                {
                    YSTimeDrawInfo *info = [[YSTimeDrawInfo alloc] init];
                    info.drawColor = (recordFileInfo.ysFileType == 0 ? YS_UIColorFromRGB(0x6ebbf3, 1.0f) : YS_UIColorFromRGB(0xff9252, 1.0f));
                    info.originX = (recordFileInfo.startTime - p.beginTime)/10.0f * p.timeWidth;
                    info.length = p.timeWidth - info.originX;
                    [p.drawInfos addObject:info];
                }
                else
                {
                    YSTimeDrawInfo *info = [[YSTimeDrawInfo alloc] init];
                    info.drawColor = (recordFileInfo.ysFileType == 0 ? YS_UIColorFromRGB(0x6ebbf3, 1.0f) : YS_UIColorFromRGB(0xff9252, 1.0f));
                    info.originX = 0;
                    info.length = (recordFileInfo.stopTime - p.beginTime)/10.0f * p.timeWidth;
                    [p.drawInfos addObject:info];
                }
                j = j - 1; //时间点 索引向前一位，存在多个切片的情况下
                if (j < 0)
                {
                    j = 0;
                }
                break;
            }
        }
    }
    return self.timePoints;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x <= 0) //已经到最左边
    {
        if (_offsetValue)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayOffset:) object:_offsetValue];
            _offsetValue = [NSValue valueWithCGPoint:scrollView.contentOffset];
            [self performSelector:@selector(delayOffset:) withObject:_offsetValue afterDelay:0.2];
        }
    }
    
    if (scrollView.tracking ||
        scrollView.decelerating ||
        scrollView.dragging)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayOffset:) object:_offsetValue];
        _offsetValue = [NSValue valueWithCGPoint:scrollView.contentOffset];
        [self performSelector:@selector(delayOffset:) withObject:_offsetValue afterDelay:0.2];
    }
}

#pragma mark - Private Methods

- (void)delayOffset:(NSValue *)value
{
    CGPoint p = [self.offsetValue CGPointValue];
    if (self.didPanOffsetTimeBlock)
    {
        CGFloat pecent = p.x/self.collectionView.contentSize.width;
        self.curTime = 24 * 3600 * pecent + self.beginTime;
        self.didPanOffsetTimeBlock(self.curTime);
    }
    _offsetValue = nil;
}

#pragma mark - Public Methods

- (void)reloadData:(NSTimeInterval)timeInterval
{
    self.curTime = timeInterval;
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.beginTime = [[self.dateFormatter dateFromString:self.selectedDay] timeIntervalSince1970];
    [self createAllPoints:self.beginTime records:self.records];
}

#pragma mark - GET/SET Methods

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = ({
            UICollectionView *collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:self.flowLayout];
            collectionV.delegate = self;
            collectionV.dataSource = self;
            collectionV.backgroundColor = YS_UIColorFromRGB(0xefefef, 1.0f);
            collectionV.showsVerticalScrollIndicator = NO;
            collectionV.showsHorizontalScrollIndicator = NO;
            [collectionV registerClass:[YSTimeBarCell class] forCellWithReuseIdentifier:@"YSTimeBarCell"];
            collectionV;
        });
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout
{
    if (!_flowLayout)
    {
        _flowLayout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 0.0f;
            layout.minimumInteritemSpacing = 0.0f;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout;
        });
    }
    return _flowLayout;
}

- (UIImageView *)redLineView
{
    if (!_redLineView)
    {
        _redLineView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playback_time_bg"]];
            imageView.userInteractionEnabled = NO;
            imageView.layer.zPosition = 6;
            imageView;
        });
    }
    return _redLineView;
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

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = ({
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            formatter;
        });
    }
    return _dateFormatter;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = ({
            UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            loadingView;
        });
    }
    return _loadingView;
}

@end
