//
//  CouponsModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/12.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "CouponsModel+CoreDataProperties.h"

@implementation CouponsModel (CoreDataProperties)

+ (NSFetchRequest<CouponsModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CouponsModel"];
}

@dynamic couponAllowState;
@dynamic couponClassId;
@dynamic couponDesc;
@dynamic couponGoodsClassId;
@dynamic couponId;
@dynamic couponIock;
@dynamic couponIsUsed;
@dynamic couponLimit;
@dynamic couponMemberId;
@dynamic couponPic;
@dynamic couponPrice;
@dynamic couponPrintStyle;
@dynamic couponState;
@dynamic couponstorage;
@dynamic couponTitle;
@dynamic couponusage;
@dynamic createTime;
@dynamic createTimeStr;
@dynamic endTime;
@dynamic endTimeStr;
@dynamic identity;
@dynamic startTime;
@dynamic startTimeStr;
@dynamic storeId;
@dynamic storeName;
@dynamic timeLimit;
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"startTime"]) {
        //int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.startTime = detaildate;
    }else    if ([key isEqualToString:@"createTime"]) {
        //int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.createTime = detaildate;
    }else    if ([key isEqualToString:@"endTime"]) {
        //int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.endTime = detaildate;
    }else if([key isEqualToString:@"couponState"]){
        self.couponState = [NSString stringWithFormat:@"%@", value];
    }else{
        [super setValue:value forKey:key];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
    
}
@end
