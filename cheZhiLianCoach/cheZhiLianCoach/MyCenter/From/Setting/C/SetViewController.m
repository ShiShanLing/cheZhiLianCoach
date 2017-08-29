//
//  SetViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SetViewController.h"
#import "FeedBackViewController.h"
#import "AboutUsViewController.h"
#import "LoginViewController.h"
#import "CoachRuleViewController.h"
@interface SetViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *taskChangedSwitch;

- (IBAction)newTaskChanged:(id)sender;

- (IBAction)clickFeedBack:(id)sender;
- (IBAction)clickAboutUs:(id)sender;
- (IBAction)clickLogOff:(id)sender;
- (IBAction)clickForRule:(id)sender;
- (IBAction)clickService:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.logoutButton.layer.cornerRadius = 4.0;
    self.logoutButton.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 设置是否接受新任务通知
- (IBAction)newTaskChanged:(id)sender {
    if(_taskChangedSwitch.on == YES)
    {
        // 将数据存到字典
        NSDictionary *taskChangedDict = [NSDictionary dictionaryWithObject:@"0" forKey:@"boolkey"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:taskChangedDict key:@"boolChanged"];
        // 调用接口
        [self taskChanged:0];
    }else{
        NSDictionary *taskChangedDict = [NSDictionary dictionaryWithObject:@"1" forKey:@"boolkey"];
        // 将解析出来的数据保存到本地
        [CommonUtil saveObjectToUD:taskChangedDict key:@"boolChanged"];
        [self taskChanged:1];
    }
}

// 进入意见反馈界面
- (IBAction)clickFeedBack:(id)sender {
    FeedBackViewController *targetViewController = [[FeedBackViewController alloc] initWithNibName:@"FeedBackViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

// 进入关于我们界面
- (IBAction)clickAboutUs:(id)sender {
    AboutUsViewController *targetViewController = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:NO];
}

// 响应方法
- (void)sendNotification{
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 退出登录
- (IBAction)clickLogOff:(id)sender {
    [CommonUtil logout];
    
    [self sendNotification];
    
}

- (IBAction)clickForRule:(id)sender {
    CoachRuleViewController *viewController = [[CoachRuleViewController alloc] initWithNibName:@"CoachRuleViewController" bundle:nil];
    viewController.fromVC = @"1";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)clickService:(id)sender {
    CoachRuleViewController *viewController = [[CoachRuleViewController alloc] initWithNibName:@"CoachRuleViewController" bundle:nil];
    viewController.fromVC = @"2";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)clickForCompanyDrive:(id)sender {
    CoachRuleViewController *viewController = [[CoachRuleViewController alloc] initWithNibName:@"CoachRuleViewController" bundle:nil];
    viewController.fromVC = @"3";
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 接受新任务通知接口
- (void)taskChanged:(int)newTaskNoTi {
  
}

@end
