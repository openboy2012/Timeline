//
//  YSTimeNode.m
//  C_TTHcNetAPI
//
//  Created by DeJohn Dong on 2018/9/17.
//

#import "YSTimeNode.h"

@implementation YSTimeNode

+ (instancetype)node
{
    YSTimeNode *node = [[YSTimeNode alloc] init];
    node.key = @-1; //默认Key值为-1，必须保证有个值
    node.subViewArray = [NSMutableArray array];
    return node;
}

- (BOOL)ys_avalible
{
    if ([self.key isEqualToNumber:@-1])
    {
        return NO;
    }
    return YES;
}

@end
