//
//  RecommendCodeViewController.m
//  guangda
//
//  Created by Ray on 15/7/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendCodeViewController.h"
#import "CoachInfoViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
@interface RecommendCodeViewController ()

@property (strong, nonatomic) IBOutlet UITextField *inviteCode;//邀请码
@property (strong, nonatomic) IBOutlet UIView *inviteCodeView;
@property (strong, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation RecommendCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //圆角
    self.sureButton.layer.cornerRadius = 4;
    self.sureButton.layer.masksToBounds = YES;
    
    self.inviteCodeView.layer.borderWidth = 1;
    self.inviteCodeView.layer.borderColor = MColor(222, 222, 222).CGColor;
    
}
//获取邀请列表
- (void) getRecommendRecordList{
    
   
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

//发送邀请码
- (IBAction)clickForSure:(id)sender {
    if (self.inviteCode.text.length == 0 || [self.inviteCode.text isEqualToString:@"请输入推荐码"]) {
        [self makeToast:@"请输入8位的推荐码"];
    }else{
        [self getRecommendRecordList];
    }
}

- (IBAction)clickForPop:(id)sender {
   
    
   
    
    UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"警告!" message:@"你点我干嘛" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle1 = [UIAlertAction actionWithTitle:@"请选择我" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        CoachInfoViewController *viewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    UIAlertAction *cancle2 = [UIAlertAction actionWithTitle:@"楼上是SB" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }];

    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"楼上说得对" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        
    }];
    // 3.将“取消”和“确定”按钮加入到弹框控制器中
    [alertV addAction:cancle1];
    [alertV addAction:cancle2];
    [alertV addAction:confirm];
    // 4.控制器 展示弹框控件，完成时不做操作
    [self presentViewController:alertV animated:YES completion:^{
        nil;
    }];

    
    
    
    
    
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

@end
