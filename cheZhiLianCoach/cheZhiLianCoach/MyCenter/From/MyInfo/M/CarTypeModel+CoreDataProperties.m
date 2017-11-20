//
//  CarTypeModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/11/15.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CarTypeModel+CoreDataProperties.h"

@implementation CarTypeModel (CoreDataProperties)

+ (NSFetchRequest<CarTypeModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CarTypeModel"];
}

@dynamic carTypeId;
@dynamic carTypeName;
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"carTypeId"]) {
        self.carTypeId = [NSString stringWithFormat:@"%@", value];
    }else {
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
}
@end
