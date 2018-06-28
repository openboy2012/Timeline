//
//  YSRecordFileInfo.m
//  VideoGo
//
//  Created by DeJohn Dong on 2017-08-31
//  Copyright (c) 2017年 Hikvision. All rights reserved.
//

#import "YSRecordFileInfo.h"
//#import "YSDeviceInfo+Extension.h"
//#import "YSCloudVideo+AccessDB.h"
//#import "YSTimerFormart.h"
//#import "NSDate-Utilities.h"

@implementation YSRecordFileInfo

//+ (NSArray *)sortedForRecordFiles:(NSArray *)files
//{
//    if (0 == [files count])
//    {
//        return nil;
//    }
//
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fStartTime" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    return [files sortedArrayUsingDescriptors:sortDescriptors];
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone
//{
//    YSRecordFileInfo *fileInfo = [[[self class] allocWithZone:zone] init];
//    fileInfo.ysFileType = self.ysFileType;
//    fileInfo.storageType = self.storageType;
//    fileInfo.cloudRecordPassword = self.cloudRecordPassword;
//    fileInfo.captureUrl = self.captureUrl;
//    fileInfo.deviceSerial = self.deviceSerial;
//    fileInfo.videoLength = self.videoLength;
//    fileInfo.ysFileSize = self.ysFileSize;
//    fileInfo.serverIp = self.serverIp;
//    fileInfo.serverPort = self.serverPort;
//    fileInfo.startTime = self.startTime;
//    fileInfo.stopTime = self.stopTime;
//    fileInfo.fileId = self.fileId;
//    fileInfo.password = self.password;
//    fileInfo.cloudType = self.cloudType;
//    return fileInfo;
//}
//
//- (instancetype)init
//{
//    if (self = [super init])
//    {
//        self.storageType = YSFileStorageTypeDevice;
//        _cloudRecordPassword = nil;
//    }
//    return self;
//}
//
//- (NSString *)ys_cloudSeqId
//{
//    return [[self.fileId componentsSeparatedByString:@"-"] firstObject];
//}
//
//- (YSCloudVideo *)ys_summaryYSCloudVideo
//{
//    YSCloudVideo *video = [YSCloudVideo getCloudVideoWithPrimaryKey:self.fileId];
//    return video;
//}
//
///**
// *  解析服务器字符窜信息后设置录像的属性
// *
// *  @param rfi          云录像
// *  @param downloadPath 服务器相关信息
// */
//+ (void)setRecord:(YSRecordFileInfo *)fileInfo serverInfoWithString:(NSString *)downloadPath
//{
//    if (0 == [downloadPath length])
//    {
//        return;
//    }
//
//    NSArray *infos = [downloadPath componentsSeparatedByString:@":"];
//    if ([infos count] >= 2)
//    {
//        fileInfo.serverIp = [infos objectAtIndex:0];
//        fileInfo.serverPort = [[infos objectAtIndex:1] integerValue];
//    }
//}
//
//- (NSInteger)videoLength
//{
//    return self.stopTime - self.startTime;
//}
//
////解析YSCloudVideo数据
//+ (instancetype)recordFileInfoWithCloudVideo:(YSCloudVideo *)file
//{
//    if (file.customPrimaryKey.length == 0) //如果还没有生成主键
//    {
//        [file genPrimaryKey]; //生成主键
//    }
//    YSRecordFileInfo *recordFile = [YSRecordFileInfo new];
//    recordFile.startTime = file.startTimeInterval;
//    recordFile.stopTime = file.stopTimeInterval;
//
//    if (0 == recordFile.stopTime) { // 过滤异常文件
//        return nil;
//    }
//
//    if (file.videoType == 1)
//    {
//        recordFile.ysFileType = 0; //连续云录像
//    }
//    else
//    {
//        recordFile.ysFileType = 1; //活动云录像
//    }
//
//    recordFile.storageType = YSFileStorageTypeCloud;
//    recordFile.storageVersion = file.storageVersion;
//    recordFile.cloudRecordPassword = file.keyChecksum;
//    recordFile.captureUrl = file.coverPic;
//    recordFile.deviceSerial = file.deviceSerial;
//    recordFile.fileId = file.customPrimaryKey;
//    recordFile.videoLength = file.videoLong;
//    recordFile.ysFileSize = file.fileSize;
//    recordFile.password = file.decryptKey;
//    recordFile.cloudType = file.cloudType;
//    [YSRecordFileInfo setRecord:recordFile serverInfoWithString:file.streamUrl];
//    [recordFile reqUrl];
//    return recordFile;
//}
//
//- (NSInteger)ys_cloudVideoType
//{
//    if (self.ysFileType == 1)
//    {
//        return 2;
//    }
//    return -1;
//}
//
//- (BOOL)isSummary
//{
//    if ((0 == [self.serverIp length] && self.storageType == YSFileStorageTypeCloud))
//    {
//        return YES;
//    }
//    return NO;
//}
//
//- (NSURL *)reqUrl
//{
//    if (!_reqUrl) {
//        if (_captureUrl.length == 0) {
//            return nil;
//        }
//        NSArray *components = [self.captureUrl componentsSeparatedByString:@"&ticket"];
//        if (components.count > 1) {
//            _reqUrl = [NSURL URLWithString:[components objectAtIndex:0]];
//        }
//        else {
//            _reqUrl = [NSURL URLWithString:self.captureUrl];
//        }
//    }
//    return _reqUrl;
//}
//
//- (NSMutableDictionary *)reqDic
//{
//    if (!_reqDic) {
//
//        if (self.deviceSerial)
//        {
//            NSArray *components = [self.captureUrl componentsSeparatedByString:@"&fid"];
//            if (2 > [components count])
//            {
//                return nil;
//            }
//
//            NSString *body = nil;
//            if (0 == [self.cloudRecordPassword length])
//            {
//                body = [NSString stringWithFormat:@"fid%@&x=%d", [components objectAtIndex:1], (int)([UIScreen mainScreen].bounds.size.width /3.0f)];
//            }
//            else
//            {
//                YSDeviceInfo *di = [YSDeviceInfo getDeviceBySerial:self.deviceSerial];
//                if ([di checkCloudPasswordIsValid:self.cloudRecordPassword])
//                {
//                    body = [NSString stringWithFormat:@"fid%@&x=%d&decodekey=%@",
//                            [components objectAtIndex:1],
//                            (int)([UIScreen mainScreen].bounds.size.width / 3.0),
//                            [di getCloudPassword]];
//                }
//                else
//                {
//                    return nil;
//                }
//            }
//
//            if (0 != [body length])
//            {
//                DDLogInfo(@"Request cloud record capture parameter is: %@", body);
//
//                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//                [dict setObject:self.reqUrl forKey:@"imageUrl"];
//                [dict setObject:[body dataUsingEncoding:NSUTF8StringEncoding] forKey:@"body"];
//                [dict setObject:@"POST" forKey:@"method"];
//
//                _reqDic = dict;
//            }
//        }
//    }
//    return _reqDic;
//}
//
//- (NSMutableArray *)pageList
//{
//    if (!_pageList) {
//        _pageList = [NSMutableArray array];
//    }
//    return _pageList;
//}
//
//- (NSString *)startTimeDisplayString
//{
//    NSDate *detectTime = [NSDate dateWithTimeIntervalSince1970:self.startTime];
//
//    if ([detectTime isToday])
//    {
//        return [[YSTimerFormart shareInstance] timerStringFromUTCDate:detectTime formart:@"HH:mm"];
//    }
//
//    if ([detectTime isYesterday])
//    {
//        return @"昨天";
//    }
//
//    int days = [[detectTime dateAtStartOfDay] daysBeforeDate:[[NSDate date] dateAtStartOfDay]];
//    if (days <= 0) {
//        return [[YSTimerFormart shareInstance] timerStringFromUTCDate:detectTime formart:@"HH:mm"];
//    }
//
//    return [NSString stringWithFormat:@"%ld天前", (long)[[detectTime dateAtStartOfDay] daysBeforeDate:[[NSDate date] dateAtStartOfDay]]];
//}

@end

#pragma mark - SearchedRecordFileProcessor

//@implementation SearchedRecordFileProcessor
//
///**
// *  按照录像的开始时间进行升序排列
// *
// *  @param recordFiles 录像文件集合
// */
//+ (void)sortRecordFilesByRecordStartTime:(NSMutableArray *)recordFiles
//{
//    if (0 == [recordFiles count]) {
//        return;
//    }
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fStartTime" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray *array = [recordFiles sortedArrayUsingDescriptors:sortDescriptors];
//    [recordFiles removeAllObjects];
//    [recordFiles addObjectsFromArray:array];
//}
//
//@end
