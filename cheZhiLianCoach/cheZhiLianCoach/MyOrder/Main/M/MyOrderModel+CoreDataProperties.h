//
//  MyOrderModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "MyOrderModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyOrderModel (CoreDataProperties)

+ (NSFetchRequest<MyOrderModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *couponMemberId;
@property (nullable, nonatomic, copy) NSString *schoolName;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nonatomic) int16_t orderAmount;
@property (nonatomic) int16_t commentState;
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nullable, nonatomic, retain) NSObject *orderTimes;
@property (nullable, nonatomic, copy) NSString *coachId;
@property (nonatomic) int16_t payState;
@property (nullable, nonatomic, copy) NSString *orderSn;
@property (nullable, nonatomic, copy) NSString *orderId;
@property (nonatomic) int16_t state;
@property (nullable, nonatomic, copy) NSString *trainState;
-(void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
