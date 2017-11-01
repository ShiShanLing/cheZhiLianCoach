//
//  ScheduleSettingViewController.h
//  guangda
//
//  Created by 吴筠秋 on 15/4/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"   //课程设置
/**
 *课程设置
 */
@interface ScheduleSettingViewController : GreyTopViewController

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSArray *timeArray;
@property (strong, nonatomic) NSDictionary *timeDic;//对应的日期
@property (strong, nonatomic) NSString *date;//修改的日期<2015-03-01>
@property (strong, nonatomic) NSMutableArray *allDayArray;
@property (strong, nonatomic) IBOutlet UIButton *pricePencil;
@property (strong, nonatomic) IBOutlet UIButton *rentPricePencil;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *isRentConstraint;
/**
 *选择时间数组
 */
@property (nonatomic, strong)NSMutableArray  *chooseTime;
/**
 *一节课的价钱
 */
@property (nonatomic, strong)NSString *CoursePrice;

@property (nonatomic, assign)CGFloat bai2;
@property (nonatomic, assign)CGFloat bai3;
@property (nonatomic, assign)CGFloat hei2;
@property (nonatomic, assign)CGFloat hei3;

@end
