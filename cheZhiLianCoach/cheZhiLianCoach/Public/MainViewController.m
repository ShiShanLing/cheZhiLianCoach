//
//  MainViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "CustomTabBar.h"
#import "CoachInfoViewController.h"
#import "TaskListViewController.h"
#import "ScheduleViewController.h"
#import "MyViewController.h"
#import "LoginViewController.h"
#import "RecommendCodeViewController.h"
@interface MainViewController ()<CustomTabBarDelegate>

@property (nonatomic, strong) TaskListViewController *tasklistVC;
@property (nonatomic, strong) ScheduleViewController *scheduleVC;
@property (nonatomic, strong) MyViewController *myVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomTabBar" owner:self options:nil];
    self.customTabBar = [nib objectAtIndex:0];
    self.customTabBar.delegate = self;
    
    self.tasklistVC = [[TaskListViewController alloc] initWithNibName:@"TaskListViewController" bundle:nil];
    self.scheduleVC = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
    self.myVC = [[MyViewController alloc] initWithNibName:@"MyViewController" bundle:nil];
    
    _tasklistVC.hidesBottomBarWhenPushed = true;
    _scheduleVC.hidesBottomBarWhenPushed = true;
    _myVC.hidesBottomBarWhenPushed = true;
    
    self.viewControllers = @[_tasklistVC, _scheduleVC, _myVC];
    [self.tabBar setClipsToBounds:YES];
//    self.tabBar.hidden = YES;
    
    self.customTabBar.tag = 100;
    self.customTabBar.frame = CGRectMake(0, self.view.frame.size.height - 49, kScreen_widht, 49);
    [self.view addSubview:self.customTabBar];
    // ios7中，本视图有状态栏、下面为scrollView，这句让进入下一个视图后，再回来，不会出现scrollview下移20(offSet:-20)的情况；添加在viewDidLoad中
    self.automaticallyAdjustsScrollViewInsets = NO;
//    UIControl *item = [[UIControl alloc]init];
//    item.tag = 1;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.selectedIndex = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
}

#pragma mark - CustomTabBarDelegate
- (void)customTabBar:(CustomTabBar *)tabBar didSelectItem:(UIControl *)item {
    self.selectedIndex = item.tag;
}

- (void)checkLogin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autologincomplete" object:nil];
    
   
    
    
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];

}



@end
