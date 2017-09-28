//
//  MyStudentListModel+CoreDataProperties.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/31.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "MyStudentListModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyStudentListModel (CoreDataProperties)

+ (NSFetchRequest<MyStudentListModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *realName;
@property (nullable, nonatomic, copy) NSString *avatarUrl;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nonatomic) int16_t state;

-(void)setValue:(id)value forKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
