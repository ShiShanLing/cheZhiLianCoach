//
//  XBArea.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import "XBArea.h"

@implementation XBArea

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _areaID = [dict[@"areaid"] description];
        _areaName = dict[@"area"];
    }
    return self;
}

+ (instancetype)areaWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)areasWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBArea areaWithDict:dict]];
        }
    }
    return tempArray;
}

@end
