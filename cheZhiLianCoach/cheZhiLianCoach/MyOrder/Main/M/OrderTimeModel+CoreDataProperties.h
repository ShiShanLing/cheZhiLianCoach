//
//  OrderTimeModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "OrderTimeModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OrderTimeModel (CoreDataProperties)

+ (NSFetchRequest<OrderTimeModel *> *)fetchRequest;

@property (nonatomic) int16_t subType;
@property (nullable, nonatomic, copy) NSDate *startTime;
@property (nonatomic) int16_t price;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nonatomic) int16_t trainState;
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nullable, nonatomic, copy) NSString *coachId;
@property (nullable, nonatomic, copy) NSString *orderId;
@property (nullable, nonatomic, copy) NSString *coachName;
@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nullable, nonatomic, copy) NSString *timeId;

-(void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
