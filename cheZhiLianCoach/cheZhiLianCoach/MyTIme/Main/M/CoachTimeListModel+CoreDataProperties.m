//
//  CoachTimeListModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/1.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "CoachTimeListModel+CoreDataProperties.h"

@implementation CoachTimeListModel (CoreDataProperties)

+ (NSFetchRequest<CoachTimeListModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CoachTimeListModel"];
}

@dynamic coachId;
@dynamic endTime;
@dynamic timeId;
@dynamic payState;
@dynamic periodStr;
@dynamic startTime;
@dynamic state;
@dynamic studentId;
@dynamic timeStr;
@dynamic unitPrice;
@dynamic openCourse;
@dynamic subType;
-(void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"startTime"]) {
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.startTime = detaildate;
        self.timeStr = @"0";
    }else if ([key isEqualToString:@"endTime"]) {
        NSString *str=[NSString stringWithFormat:@"%@", value];
        NSTimeInterval time=[str doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        self.endTime = detaildate;
    }else if([key isEqualToString:@"id"]){
        self.timeId = value;
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
    
    
}

@end
