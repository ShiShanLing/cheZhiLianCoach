//
//  TaskListViewController.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface TaskListViewController : GreyTopViewController //任务列表

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSTimer *confirmTimer;
@end
