//
//  ViewController.m
//  Timeline
//
//  Created by DeJohn Dong on 2018/4/30.
//  Copyright © 2018年 DDKit. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "YSTimeBarPanel.h"
#import "ReactiveObjC.h"
#import "YSRecordFileInfo.h"

@interface ViewController ()

@property (nonatomic, strong) YSTimeBarPanel *bar;
//@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectZero];
    playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:playerView];
    playerView.tag = 10001;
    [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(320, 180));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(50);
    }];
    
    //crate的value表示，最多几个资源可访问
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    //任务1
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        dispatch_semaphore_signal(semaphore);
    });
    //任务2
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");
        dispatch_semaphore_signal(semaphore);
    });
    //任务3
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
        dispatch_semaphore_signal(semaphore);
    });
    // Do any additional setup after loading the view, typically from a nib.
    self.bar = [[YSTimeBarPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65.0f) zoomLevel:2.0f];
    [self.view addSubview:self.bar];
    [self.bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(@65);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [format stringFromDate:[NSDate date]];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *dateStart = [format dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", dateStr]];
    
    YSRecordFileInfo *record = [[YSRecordFileInfo alloc] init];
    record.startTime = [[NSDate date] timeIntervalSince1970];
    record.stopTime = record.startTime + 30.0f * 60.0f;
    
    [self.bar reloadRecords:@[record]];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
    slider.maximumValue = 101.0f;
    slider.minimumValue = 0.0f;
    [self.view addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(10);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-10);
        make.height.mas_equalTo(@10);
        make.centerY.mas_equalTo(self.view.mas_centerY).mas_offset(-120);
    }];
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 目前UISlider的取值范围是0～100，与YSTimeBar缩放不一致，采用等差数列解决转换问题
 
 @param value 当前YSTimeBar的值
 @return 转化后的UISlider的值
 */
- (double)ys_scaleValue:(CGFloat)value
{
    double q = pow(1/288.0, 1/100.0);
    double result = log(value/12.0f)/log(q);
    NSLog(@"#### result scale = %f", result);
    return result;
}

/**
 目前UISlider的取值范围是0～100，与YSTimeBar缩放不一致，采用等差数列解决转换问题
 
 @param value 当前UISlider的值
 @return 转化后的YSTimeBar的值
 */
- (double)ys_timeBarValue:(CGFloat)value
{
    double q = pow(1/288.0, 1/100.0);
    double result = 12.0 * pow(q, value - 1);
    NSLog(@"#### origin value is %f result time = %f", value, result);
    return result;
}


- (void)valueChanged:(id)sender
{
    UISlider *slider = sender;
    CGFloat scaleValue = [self ys_timeBarValue:(slider.maximumValue - slider.value)]; //该值大于12时，当12倍处理。
    if (scaleValue > 12.0)
    {
        scaleValue = 12.0f;
    }
    else if (scaleValue < 1.0f/12.0f)
    {
        scaleValue = 1.0f/12.0f;
    }
    self.bar.ysZoomLevel = scaleValue;

}


@end
