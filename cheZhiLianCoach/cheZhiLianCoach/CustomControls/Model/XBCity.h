//
//  XBCity.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBArea.h"

@interface XBCity : NSObject

@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSArray *areasArray;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)cityWithDict:(NSDictionary *)dict;
+ (NSArray *)citiesWithArray:(NSArray *)array;

@end
