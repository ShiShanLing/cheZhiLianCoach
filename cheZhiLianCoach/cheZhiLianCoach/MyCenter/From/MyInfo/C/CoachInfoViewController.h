//
//  CoachInfoViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface CoachInfoViewController : GreyTopViewController  //教练信息

@property (strong, nonatomic) NSString *superViewNum;   // 0登录注册界面条转过来的 / 1其他界面跳转过来

@property (assign, nonatomic) int hasPassed; // 是否通过审核 0:未通过 1:通过
@end
