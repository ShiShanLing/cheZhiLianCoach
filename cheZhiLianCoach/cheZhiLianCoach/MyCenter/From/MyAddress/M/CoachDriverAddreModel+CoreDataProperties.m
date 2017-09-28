//
//  CoachDriverAddreModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/15.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "CoachDriverAddreModel+CoreDataProperties.h"

@implementation CoachDriverAddreModel (CoreDataProperties)

+ (NSFetchRequest<CoachDriverAddreModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CoachDriverAddreModel"];
}

@dynamic addressId;
@dynamic addressName;
@dynamic coachId;
@dynamic isDefault;

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

@end
