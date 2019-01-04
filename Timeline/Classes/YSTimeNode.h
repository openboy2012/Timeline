//
//  YSTimeNode.h
//  C_TTHcNetAPI
//
//  Created by DeJohn Dong on 2018/9/17.
//

#import <UIKit/UIKit.h>

//时间刻度对象
@interface YSTimeNode : NSObject

@property (nonatomic, strong) NSNumber *key; //key值，重要参数，用来匹配UI重用机制
@property (nonatomic, assign) CGPoint pointCenter; //刻度中心点，x是center.x，y是origin.y
@property (nonatomic, assign) BOOL pointHidden; //刻度是否隐藏
@property (nonatomic, assign) CGFloat height; //刻度高度
@property (nonatomic, copy) NSString *timeStr; //刻度时间信息
@property (nonatomic, assign) BOOL timeHidden; //刻度时间信息是否隐藏
@property (nonatomic, strong) NSMutableArray<YSTimeNode *> *subViewArray; //下级刻度数组

/**
 工厂方法

 @return 刻度对象
 */
+ (instancetype)node;

/**
 是否有效
 */
- (BOOL)ys_avalible;

@end
