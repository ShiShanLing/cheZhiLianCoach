//
//  CoachDriverAddreModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/15.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "CoachDriverAddreModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoachDriverAddreModel (CoreDataProperties)

+ (NSFetchRequest<CoachDriverAddreModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *addressId;
@property (nullable, nonatomic, copy) NSString *addressName;
@property (nullable, nonatomic, copy) NSString *coachId;
@property (nonatomic) int16_t isDefault;

-(void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
