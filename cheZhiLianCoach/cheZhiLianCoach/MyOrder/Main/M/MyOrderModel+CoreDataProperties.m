//
//  MyOrderModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/8.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "MyOrderModel+CoreDataProperties.h"

@implementation MyOrderModel (CoreDataProperties)

+ (NSFetchRequest<MyOrderModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MyOrderModel"];
}

@dynamic startTime;
@dynamic state;
@dynamic price;
@dynamic phone;
@dynamic commentState;
@dynamic realName;
@dynamic payState;
@dynamic endTime;
@dynamic orderId;
@dynamic open;
@dynamic trainState;
-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.orderId = value;
    }else if([key isEqualToString:@"startTime"]){
      //  int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
      
        self.startTime = detaildate;
    }else if([key isEqualToString:@"endTime"]){
        NSLog(@"value%@", value);
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.endTime = detaildate;
    }else{
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {


}
@end
