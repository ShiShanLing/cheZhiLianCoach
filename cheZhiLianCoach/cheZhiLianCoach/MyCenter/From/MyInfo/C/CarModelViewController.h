//
//  CarModelViewController.h
//  guangda
//
//  Created by Ray on 15/8/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"  //准驾类型

@interface CarModelViewController : GreyTopViewController

@property (nonatomic,copy) void(^blockCar)(NSString *carState,NSString *carTypeId);

@end
