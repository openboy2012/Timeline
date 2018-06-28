//
//  YSDownloadTimeBar.h
//  VideoGo
//
//  Created by DeJohn Dong on 2017/10/26.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSRecordFileInfo.h"

@interface YSDownloadTimeBar : UIView

@property (nonatomic, copy) NSString *selectedDay;
@property (nonatomic, copy) NSArray<YSRecordFileInfo *> *records; //存在的录像片段
@property (nonatomic, copy) void (^didPanOffsetTimeBlock)(NSTimeInterval offsetTime);
@property (nonatomic, copy) void (^didScrolledToOffsetTimeBlock)(BOOL isFinished);

- (void)reloadData:(NSTimeInterval)timeInterval;

@end
