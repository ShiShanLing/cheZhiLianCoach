//
//  CoachInfoTextFieldViewController.h
//  guangda
//
//  Created by Ray on 15/8/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"  //教练资料详情

@interface CoachInfoTextFieldViewController : GreyTopViewController

@property (strong, nonatomic) NSString *viewType; //1：姓名   2：驾培教龄  3：个人评价
@property (strong, nonatomic) NSString *textString;
@end
