//
//  XBProvince.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBCity.h"

@interface XBProvince : NSObject

@property (copy, nonatomic) NSString *provinceID;
@property (copy, nonatomic) NSString *provinceName;
@property (strong, nonatomic) NSArray *citiesArray;
@property (assign, nonatomic) BOOL isZxs; // 是否是直辖市

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)provinceWithDict:(NSDictionary *)dict;
+ (NSArray *)provincesWithArray:(NSArray *)array;

@end
