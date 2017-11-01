//
//  CoursePriceModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/11/1.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CoursePriceModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoursePriceModel (CoreDataProperties)

+ (NSFetchRequest<CoursePriceModel *> *)fetchRequest;

@property (nonatomic) int16_t dateId;
@property (nullable, nonatomic, copy) NSString *subName;
@property (nonatomic) int16_t classId;
@property (nonatomic) int16_t subId;
@property (nonatomic) float classPrice;
@property (nonatomic) int16_t carTypeId;
@property (nullable, nonatomic, copy) NSString *dateName;
@property (nullable, nonatomic, copy) NSDate *dateTime;
@property (nullable, nonatomic, copy) NSString *carTypeName;
- (void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
