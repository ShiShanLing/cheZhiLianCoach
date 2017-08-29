//
//  UserDataModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/24.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "UserDataModel+CoreDataProperties.h"

@implementation UserDataModel (CoreDataProperties)

+ (NSFetchRequest<UserDataModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"UserDataModel"];
}

@dynamic applyState;
@dynamic availablePredeposit;
@dynamic createTime;
@dynamic createTimeStr;
@dynamic freezePredeposit;
@dynamic informAllow;
@dynamic isAllowtalk;
@dynamic isBuy;
@dynamic memberAvatar;
@dynamic memberConsumePoints;
@dynamic memberCredit;
@dynamic memberGradeId;
@dynamic memberId;
@dynamic memberLoginNum;
@dynamic memberMobile;
@dynamic memberName;
@dynamic memberPasswd;
@dynamic memberRankPoints;
@dynamic memberSex;
@dynamic memberSnsvisitnum;
@dynamic memberState;
@dynamic memberTruename;
@dynamic noEvaluationOrder;
@dynamic noFilledOrder;
@dynamic noPayOrder;
@dynamic noReceiveOrder;
@dynamic referralCode;
@dynamic userType;
@dynamic state;
-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
      //  int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.createTime = detaildate;
    }else if([key isEqualToString:@"noPayOrder"]){
        self.noPayOrder = [NSString stringWithFormat:@"%@", value];
    } else if([key isEqualToString:@"memberCredit"]){
        self.memberCredit = [NSString stringWithFormat:@"%@", value];
    }else{
        [super setValue:value forKey:key];
    }

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {


}

@end
