//
//  YSRecordSlice.m
//  C_TTHcNetAPI
//
//  Created by DeJohn Dong on 2018/9/17.
//

#import "YSRecordSlice.h"

@implementation YSRecordSlice

+ (instancetype)recordSlice
{
    return [[YSRecordSlice alloc] init];
}

- (void)ys_start:(NSTimeInterval)startTime stop:(NSTimeInterval)stopTime
{
    self.key = [NSString stringWithFormat:@"%@-%@", @(startTime), @(stopTime)];
}

@end
