//
//  MyStudentListModel+CoreDataProperties.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/8/31.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "MyStudentListModel+CoreDataProperties.h"

@implementation MyStudentListModel (CoreDataProperties)

+ (NSFetchRequest<MyStudentListModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MyStudentListModel"];
}

@dynamic realName;
@dynamic avatarUrl;
@dynamic phone;
@dynamic state;

-(void)setValue:(id)value forKey:(NSString *)key {
    
    [super setValue:value forKey:key];
    
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {


}
@end
