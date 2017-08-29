//
//  XBArea.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/23.
//  Copyright (c) 2015年 冯彦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBArea : NSObject

@property (copy, nonatomic) NSString *areaID;
@property (copy, nonatomic) NSString *areaName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)areaWithDict:(NSDictionary *)dict;
+ (NSArray *)areasWithArray:(NSArray *)array;

@end
