//
//  MyOrderModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "MyOrderModel+CoreDataProperties.h"

@implementation MyOrderModel (CoreDataProperties)

+ (NSFetchRequest<MyOrderModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MyOrderModel"];
}

@dynamic couponMemberId;
@dynamic schoolName;
@dynamic createTime;
@dynamic orderAmount;
@dynamic commentState;
@dynamic studentId;
@dynamic orderTimes;
@dynamic coachId;
@dynamic payState;
@dynamic orderSn;
@dynamic orderId;
@dynamic state;
@dynamic trainState;
-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
        NSString *str=[NSString stringWithFormat:@"%@", value];
        self.createTime = [CommonUtil  getDataForSJCString:str];
    }else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
}
@end
