//
//  TradingRecordModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/11.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "TradingRecordModel+CoreDataProperties.h"

@implementation TradingRecordModel (CoreDataProperties)

+ (NSFetchRequest<TradingRecordModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TradingRecordModel"];
}

@dynamic userType;
@dynamic logId;
@dynamic balanceChange;
@dynamic accountType;
@dynamic createTime;
@dynamic userId;
-(void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"createTime"]) {
       // int 转 nsstring 再转 nsdate
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
