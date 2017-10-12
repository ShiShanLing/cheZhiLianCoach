//
//  EvaluationOrderModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/10.
//  Copyright © 2017年 石山岭. All rights reserved.
//
//

#import "EvaluationOrderModel+CoreDataProperties.h"

@implementation EvaluationOrderModel (CoreDataProperties)

+ (NSFetchRequest<EvaluationOrderModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"EvaluationOrderModel"];
}

@dynamic appealTime;
@dynamic appealId;
@dynamic studentId;
@dynamic studentPhone;
@dynamic studentName;
@dynamic appealReason;
@dynamic appealState;
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"appealTime"]) {
        //int 转 nsstring 再转 nsdate
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.appealTime = detaildate;
    }else {
        [super setValue:value forKey:key];
    }
    
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    
    
}
@end
