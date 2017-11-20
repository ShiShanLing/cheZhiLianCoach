//
//  TradingRecordModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/11.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//
/**
 *教练交易记录model
 */
#import "TradingRecordModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TradingRecordModel (CoreDataProperties)

+ (NSFetchRequest<TradingRecordModel *> *)fetchRequest;

@property (nonatomic) int16_t userType;
@property (nullable, nonatomic, copy) NSString *logId;
@property (nonatomic) float balanceChange;
@property (nonatomic) int16_t accountType;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nullable, nonatomic, copy) NSString *userId;
@property (nullable, nonatomic, copy) NSString *couponMemberId;
-(void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
