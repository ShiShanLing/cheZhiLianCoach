//
//  MyEvaluationViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface MyEvaluationViewController : GreyTopViewController  //我的评价
@property (assign, nonatomic) int evaluationType; // 0:我的评价 1:评价我的 2: 投诉我的
@property (assign, nonatomic) int hasData; // 0:无数据 1:有数据
@end
