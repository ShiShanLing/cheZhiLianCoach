//
//  CoachAuditStatusModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/29.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "CoachAuditStatusModel+CoreDataProperties.h"

@implementation CoachAuditStatusModel (CoreDataProperties)

+ (NSFetchRequest<CoachAuditStatusModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CoachAuditStatusModel"];
}
@dynamic longitude;
@dynamic memberId;
@dynamic idCardBack;
@dynamic schoolName;
@dynamic state;
@dynamic schoolId;
@dynamic phone;
@dynamic createTime;
@dynamic carType;
@dynamic score;
@dynamic realName;
@dynamic idCardFront;
@dynamic coachId;
@dynamic coachCertificate;
@dynamic latitude;
@dynamic driveCertificate;
@dynamic address;
@dynamic sex;
@dynamic rejectReason;
-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
   //     int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.createTime = detaildate;
    }else {
        [super setValue:value forKey:key];
    }

}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {


}
@end
