//
//  OrderTimeModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "OrderTimeModel+CoreDataProperties.h"

@implementation OrderTimeModel (CoreDataProperties)

+ (NSFetchRequest<OrderTimeModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"OrderTimeModel"];
}

@dynamic subType;
@dynamic startTime;
@dynamic price;
@dynamic createTime;
@dynamic trainState;
@dynamic studentId;
@dynamic coachId;
@dynamic orderId;
@dynamic coachName;
@dynamic endTime;
@dynamic timeId;
-(void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"startTime"]) {
    //    int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.startTime = detaildate;
    }else if ([key isEqualToString:@"createTime"]) {
        //    int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
  
        self.createTime = [CommonUtil  getDataForSJCString:str];
    }else if ([key isEqualToString:@"endTime"]) {
        NSString *str=[NSString stringWithFormat:@"%@", value];
        self.endTime = [CommonUtil  getDataForSJCString:str];
    }else if([key isEqualToString:@"id"]){
        
        self.timeId = value;
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
    
}
@end
