//
//  OrderTimeList.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/19.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "OrderTimeList.h"

@implementation OrderTimeList
+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSArray class];
}
//返回转换后的对象
- (id)transformedValue:(id)value {
    
    return  value;
}

- (id)reverseTransformedValue:(id)value {
    return [NSArray array];
}
@end
