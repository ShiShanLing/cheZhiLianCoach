//
//  CarTypeModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/11/15.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CarTypeModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CarTypeModel (CoreDataProperties)

+ (NSFetchRequest<CarTypeModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *carTypeId;
@property (nullable, nonatomic, copy) NSString *carTypeName;



- (void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
