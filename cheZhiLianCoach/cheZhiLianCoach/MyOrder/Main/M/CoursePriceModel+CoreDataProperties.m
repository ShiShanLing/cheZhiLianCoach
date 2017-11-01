//
//  CoursePriceModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/11/1.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CoursePriceModel+CoreDataProperties.h"

@implementation CoursePriceModel (CoreDataProperties)

+ (NSFetchRequest<CoursePriceModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CoursePriceModel"];
}

@dynamic dateId;
@dynamic subName;
@dynamic classId;
@dynamic subId;
@dynamic classPrice;
@dynamic carTypeId;
@dynamic dateName;
@dynamic dateTime;
@dynamic carTypeName;
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"dateTime"]) {
        NSString *str=[NSString stringWithFormat:@"%@", value];
        self.dateTime = [CommonUtil  getDataForSJCString:str];
    }else {
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
}
@end
