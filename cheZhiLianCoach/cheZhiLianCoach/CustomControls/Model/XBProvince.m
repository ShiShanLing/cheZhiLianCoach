//
//  XBProvince.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import "XBProvince.h"

@implementation XBProvince

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _provinceID = [dict[@"provinceid"] description];
        _provinceName = dict[@"province"];
        NSArray * citiesInfoArray = dict[@"cities"];
        _citiesArray = [XBCity citiesWithArray:citiesInfoArray];
        // 是否是直辖市
        if ([_provinceName isEqualToString:@"北京市"] ||[_provinceName isEqualToString:@"天津市"] || [_provinceName isEqualToString:@"上海市"] || [_provinceName isEqualToString:@"重庆市"]) {
            _isZxs = YES;
        } else {
            _isZxs = NO;
        }
    }
    return self;
}

+ (instancetype)provinceWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)provincesWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBProvince provinceWithDict:dict]];
        }
    }
    return tempArray;
}

@end
