//
//  CouponsModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/11/6.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CouponsModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CouponsModel (CoreDataProperties)

+ (NSFetchRequest<CouponsModel *> *)fetchRequest;

@property (nonatomic) int16_t couponAllowState;
@property (nullable, nonatomic, copy) NSString *couponClassId;
@property (nullable, nonatomic, copy) NSString *couponDesc;
@property (nonatomic) int16_t couponDuration;
@property (nullable, nonatomic, copy) NSString *couponGoodsClassId;
@property (nullable, nonatomic, copy) NSString *couponId;
@property (nonatomic) int16_t couponIock;
@property (nonatomic) int16_t couponIsUsed;
@property (nonatomic) int32_t couponLimit;
@property (nullable, nonatomic, copy) NSString *couponMemberId;
@property (nullable, nonatomic, copy) NSString *couponPic;
@property (nonatomic) int16_t couponPrice;
@property (nullable, nonatomic, copy) NSString *couponPrintStyle;
@property (nullable, nonatomic, copy) NSString *couponState;
@property (nonatomic) int16_t couponstorage;
@property (nullable, nonatomic, copy) NSString *couponTitle;
@property (nonatomic) int16_t couponusage;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nullable, nonatomic, copy) NSString *createTimeStr;
@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nullable, nonatomic, copy) NSString *endTimeStr;
@property (nonatomic) int16_t identity;
@property (nullable, nonatomic, copy) NSDate *startTime;
@property (nullable, nonatomic, copy) NSString *startTimeStr;
@property (nullable, nonatomic, copy) NSString *storeId;
@property (nullable, nonatomic, copy) NSString *storeName;
@property (nullable, nonatomic, copy) NSString *timeLimit;
@property (nullable, nonatomic, copy) NSString *selected;
- (void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
