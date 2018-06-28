//
//  YSRecordFileInfo.h
//  VideoGo
//
//  Created by DeJohn Dong on 2017-08-31
//  Copyright (c) 2017年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

//文件类型:0－定时录像,1-移动侦测 ，2－报警触发，
//3-报警|移动侦测 4-报警&移动侦测 5-命令触发 6-手动录像,7－震动报警，8-环境报警，9-智能报警，10-PIR报警，11-无线报警，12-呼救报警,14-智能交通事件

#define YS_FILE_TYPE_TIMING_RECORD   0  // 定时录像
#define YS_FILE_TYPE_MANUAL_RECORD   6  // 手动录像

typedef enum YSFileStorageType {
    YSFileStorageTypeDevice = 0,          // 设备存储文件
    YSFileStorageTypeCloud                // 云存储文件
}YSFileStorageType;

//@class YSCloudVideo;

@interface YSRecordFileInfo : NSObject <NSCopying>

#pragma mark - 目前不在使用的字段，考虑删除--2018.01.03
@property (nonatomic, copy) NSString *strDeviceName;  //设备名称
@property (nonatomic, copy) NSString *strChannelName; //通道名称
@property (nonatomic, copy) NSString *strCardNum;     //卡号

#pragma mark - 有用的字段
@property (nonatomic, copy) NSString *deviceSerial; //设备序列号
@property (nonatomic, copy) NSString *fileId; //云录像专用字段，使用customPrimaryKey，seqId+startTime作为主键。
@property (nonatomic, assign) NSTimeInterval startTime; //录像文件开始时间，距离1970年1月1日的时间缀
@property (nonatomic, assign) NSTimeInterval stopTime;  //录像文件结束时间，距离1970年1月1日的时间缀
@property (nonatomic, assign) NSUInteger ysFileSize; //文件大小
@property (nonatomic, assign) NSUInteger ysFileType; //文件类型 0 定时录像 6 手动录像 其他为报警
@property (nonatomic, assign) YSFileStorageType storageType;  //文件存储位置类型
@property (nonatomic, copy) NSString *storageVersion; //云存储类型，1-单文件，2-连续云存储，只在云存储片段类型里有用
@property (nonatomic, copy) NSString *cloudRecordPassword;  //云存储录像加密密码两次MD5字符串
@property (nonatomic, copy) NSString *captureUrl; //封面url
@property (nonatomic, assign) NSInteger speedRate; //云录像播放速度，0表示原速，1-4x 2-8x 3-16x 4-32x

//记录播放时间中间的全部片段的开始时间
@property (nonatomic, strong) NSMutableArray<NSNumber *> *pageList;

/**
 *  请求的url 去掉ticket的url
 *  用来下载和缓存
 */
@property (nonatomic, strong) NSURL *reqUrl;

/**
 *  请求的url 去掉ticket的url
 *  用来下载和缓存
 */
@property (nonatomic, strong) NSMutableDictionary *reqDic;

/**
 *  录像时长
 */
@property (nonatomic, assign) NSInteger videoLength;

/**
 *  云录像的服务器地址
 */
@property (nonatomic, copy) NSString *serverIp;

/**
 *  云录像服务器端口
 */
@property (nonatomic, assign) NSInteger serverPort;

/**
 是否是概要云录像信息
 */
@property (nonatomic, assign, readonly) BOOL isSummary;
@property (nonatomic, assign) NSInteger cloudType; //云存储类型，用来判断是否是同一个服务器

@property (nonatomic, copy) NSString *password; //明文密码，内存类型，通常是nil
@property (nonatomic, assign) NSInteger avliableSeconds; //有效时长


/**
 获取云存储的seqId

 @return seqId
 */
- (NSString *)ys_cloudSeqId;

/**
 获取云录像类型

 @return 云录像类型
 */
- (NSInteger)ys_cloudVideoType;

/**
 文件排序

 @param files 排序前的文件
 @return 排序后的文件
 */
+ (NSArray *)sortedForRecordFiles:(NSArray *)files;


// 录像时间显示格式化，"HH:mm", "昨天", "x天前"
- (NSString *)startTimeDisplayString;

/**
 *  解析服务器字符窜信息后设置录像的属性
 *
 *  @param fileInfo     云录像
 *  @param downloadPath 服务器相关信息
 */
+ (void)setRecord:(YSRecordFileInfo *)fileInfo serverInfoWithString:(NSString *)downloadPath;

/**
 解析YSCloudVideo数据

 @param cloudVideo 服务端返回对象
 @return 回放播放对象
 */
//+ (instancetype)recordFileInfoWithCloudVideo:(YSCloudVideo *)cloudVideo;

/**
 获取概要请求数据

 @return 概要数据对象
 */
//- (YSCloudVideo *)ys_summaryYSCloudVideo;

@end


//#pragma mark - SearchedRecordFileProcessor
//
//@interface SearchedRecordFileProcessor : NSObject
//
//+ (void)sortRecordFilesByRecordStartTime:(NSMutableArray *)recordFiles;
//
//@end
