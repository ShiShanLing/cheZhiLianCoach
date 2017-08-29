//
//  XBCity.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import "XBCity.h"

@implementation XBCity

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _cityID = [dict[@"cityid"] description];
        _cityName = dict[@"city"];
        NSArray * areasInfoArray = dict[@"areas"];
        _areasArray = [XBArea areasWithArray:areasInfoArray];
    }
    return self;
}

+ (instancetype)cityWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)citiesWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBCity cityWithDict:dict]];
        }
    }
    return tempArray;
}

@end
