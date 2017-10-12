//
//  EvaluationOrderModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/10.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "EvaluationOrderModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EvaluationOrderModel (CoreDataProperties)

+ (NSFetchRequest<EvaluationOrderModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *appealTime;
@property (nullable, nonatomic, copy) NSString *appealId;
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nullable, nonatomic, copy) NSString *studentPhone;
@property (nullable, nonatomic, copy) NSString *studentName;
@property (nullable, nonatomic, copy) NSString *appealReason;
@property ( nonatomic,) int16_t appealState;

- (void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
