//
//  CoachAuditStatusModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/29.
//  Copyright © 2017年 石山岭. All rights reserved.
//
/**
 *教练审核状态的 model
 */
#import "CoachAuditStatusModel+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoachAuditStatusModel (CoreDataProperties)
+ (NSFetchRequest<CoachAuditStatusModel *> *)fetchRequest;

@property (nonatomic) float longitude;
@property (nullable, nonatomic, copy) NSString *memberId;
@property (nullable, nonatomic, copy) NSString *idCardBack;
@property (nullable, nonatomic, copy) NSString *schoolName;
@property (nullable, nonatomic, copy) NSString *schoolId;
@property (nonatomic) int16_t state;
@property (nonatomic) int16_t sex;
//@property (nonatomic) int16_t schoolId;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nonatomic) int16_t carType;
@property (nonatomic) float score;
@property (nullable, nonatomic, copy) NSString *realName;
@property (nullable, nonatomic, copy) NSString *idCardFront;
@property (nullable, nonatomic, copy) NSString *coachId;
@property (nullable, nonatomic, copy) NSString *coachCertificate;
@property (nonatomic) float latitude;
@property (nullable, nonatomic, copy) NSString *driveCertificate;
@property (nullable, nonatomic, copy) NSString *address;
@property(nullable, nonatomic, copy) NSString *rejectReason;
@property(nullable, nonatomic, copy) NSString *avatar;
@property(nullable, nonatomic, copy) NSString *teachAge;
@property(nullable, nonatomic, copy) NSString *descriptionStr;
@property (nonatomic) float balance;

-(void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
