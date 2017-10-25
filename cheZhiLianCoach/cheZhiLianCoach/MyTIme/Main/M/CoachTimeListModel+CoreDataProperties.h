//
//  CoachTimeListModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/9/1.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "CoachTimeListModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoachTimeListModel (CoreDataProperties)

+ (NSFetchRequest<CoachTimeListModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *coachId;
@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nullable, nonatomic, copy) NSString * timeId;
@property (nonatomic) int16_t payState;
@property (nullable, nonatomic, copy) NSString *periodStr;
@property (nullable, nonatomic, copy) NSDate *startTime;
@property (nonatomic) int16_t state;
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nonatomic) int16_t openCourse;
@property (nonatomic) int16_t subType;
@property (nullable, nonatomic, copy) NSString *timeStr;
@property (nonatomic) float unitPrice;
-(void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
