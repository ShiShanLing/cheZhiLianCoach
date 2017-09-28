//
//  MyOrderModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/8.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "MyOrderModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyOrderModel (CoreDataProperties)

+ (NSFetchRequest<MyOrderModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate * startTime;
@property (nonatomic) int16_t state;
@property (nonatomic) int16_t price;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nonatomic) int16_t commentState;
@property (nullable, nonatomic, copy) NSString *realName;
@property (nonatomic) int16_t payState;
@property (nullable, nonatomic, copy) NSDate * endTime;
@property (nonatomic) int16_t open;
@property (nonatomic) int16_t trainState;
@property (nullable, nonatomic, copy) NSString *orderId;

-(void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
