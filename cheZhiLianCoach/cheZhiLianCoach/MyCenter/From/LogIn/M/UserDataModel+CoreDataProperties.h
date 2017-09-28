//
//  UserDataModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/24.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "UserDataModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserDataModel (CoreDataProperties)

+ (NSFetchRequest<UserDataModel *> *)fetchRequest;

@property (nonatomic) int16_t applyState;
@property (nonatomic) int16_t availablePredeposit;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nullable, nonatomic, copy) NSString *createTimeStr;
@property (nonatomic) int16_t freezePredeposit;
@property (nonatomic) int16_t informAllow;
@property (nonatomic) int16_t isAllowtalk;
@property (nonatomic) int16_t isBuy;
@property (nullable, nonatomic, copy) NSString *memberAvatar;
@property (nonatomic) int16_t memberConsumePoints;
@property (nullable, nonatomic, copy) NSString *memberCredit;
@property (nullable, nonatomic, copy) NSString *memberGradeId;
@property (nullable, nonatomic, copy) NSString *memberId;
@property (nonatomic) int16_t memberLoginNum;
@property (nullable, nonatomic, copy) NSString *memberMobile;
@property (nullable, nonatomic, copy) NSString *memberName;
@property (nullable, nonatomic, copy) NSString *memberPasswd;
@property (nonatomic) int16_t memberRankPoints;
@property (nonatomic) int16_t memberSex;
@property (nonatomic) int16_t memberSnsvisitnum;
@property (nonatomic) int16_t memberState;
@property (nonatomic) int16_t state;
@property (nullable, nonatomic, copy) NSString *memberTruename;
@property (nonatomic) int16_t noEvaluationOrder;
@property (nonatomic) int16_t noFilledOrder;
@property (nullable, nonatomic, copy) NSString *noPayOrder;
@property (nonatomic) int16_t noReceiveOrder;
@property (nullable, nonatomic, copy) NSString *referralCode;
@property (nullable, nonatomic, copy) NSString *coachId;
@property (nonatomic) int16_t userType;
@property (nonatomic) int16_t approvalState;
-(void)setValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
