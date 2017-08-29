//
//  MainViewController.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBar.h"
#import "TaskListViewController.h"
#import "ScheduleViewController.h"
#import "MyViewController.h"
#import "LoginViewController.h"

@interface MainViewController :UITabBarController

@property (nonatomic, strong) CustomTabBar *customTabBar;
@end
