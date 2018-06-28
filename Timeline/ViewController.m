//
//  ViewController.m
//  Timeline
//
//  Created by DeJohn Dong on 2018/4/30.
//  Copyright © 2018年 DDKit. All rights reserved.
//

#import "ViewController.h"
#import "YSDownloadTimeBar.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    YSDownloadTimeBar *bar = [[YSDownloadTimeBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65.0f)];
    [self.view addSubview:bar];
    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(@65);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    bar.selectedDay = [format stringFromDate:[NSDate date]];
    
    YSRecordFileInfo *record = [[YSRecordFileInfo alloc] init];
    record.startTime  = [[NSDate date] timeIntervalSince1970] - 30.0f;
    record.stopTime = record.startTime + 24 * 60.0f;
    
    bar.records = @[record];
    [bar reloadData:[[NSDate date] timeIntervalSince1970]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
