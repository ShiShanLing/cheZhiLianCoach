//
//  AccountManagerViewController.m
//  guangda
//
//  Created by guok on 15/6/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "LoginViewController.h"

@interface AccountManagerViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)clickForSubmit:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *inpputViewBg;

@property (strong, nonatomic) IBOutlet UITextField *accountInputView;

@property (strong, nonatomic) IBOutlet UIButton *closeKeyBoard;
- (IBAction)clickForCloseKeyBoard:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *clearAccountButton;
- (IBAction)clickForClearAccount:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *applySwitch;

- (IBAction)switchChanged:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *applyTypeTipLabel;
@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inpputViewBg.layer.cornerRadius = 5;
    self.inpputViewBg.layer.borderWidth = 1;
    self.inpputViewBg.layer.borderColor = [MColor(199, 199, 199) CGColor];
    
    
    //提交按钮默认不可以点击
    self.submitButton.alpha = 0.4;
    self.submitButton.enabled = NO;
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    if(![CommonUtil isEmpty:aliaccount]){
        self.accountInputView.text = aliaccount;
    }
    
    UIImage *image1 = [[UIImage imageNamed:@"btn_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *image2 = [[UIImage imageNamed:@"btn_red_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.clearAccountButton setBackgroundImage:image1 forState:UIControlStateNormal];;
    [self.clearAccountButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    
    //注册监听，防止键盘遮挡视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
    int cashtype = [user_info[@"cashtype"] intValue];
    if(cashtype == 0){
        self.applySwitch.on = NO;
        self.applyTypeTipLabel.text = @"您现在提现的金额将会直接转到您的支付宝账户";
    }else{
        self.applySwitch.on = YES;
        self.applyTypeTipLabel.text = @"您现在提现的金额将会转到您所在的驾校";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.closeKeyBoard.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.closeKeyBoard.hidden = YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *input = [toBeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(![CommonUtil isEmpty:input] && ![input isEqualToString:aliaccount]){
        self.submitButton.alpha = 1;
        self.submitButton.enabled = YES;
    }else{
        self.submitButton.alpha = 0.4;
        self.submitButton.enabled = NO;
    }
    return  YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickForSubmit:(id)sender {
    [DejalBezelActivityView activityViewForView:self.view];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/addCoachAlipay", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"alipay"] = self.accountInputView.text;
    __weak  AccountManagerViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        [DejalBezelActivityView removeView];
        if ([resultStr isEqualToString:@"1"]) {
            [VC showAlert:responseObject[@"msg"] time:1.2];
            [VC.navigationController popViewControllerAnimated:YES];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [DejalBezelActivityView removeView];
        NSLog(@"error%@", error);
    }];
}

- (IBAction)clickForClearAccount:(id)sender{
    
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    [DejalBezelActivityView activityViewForView:self.view];
}

- (IBAction)clickForCloseKeyBoard:(id)sender {
    [self.accountInputView resignFirstResponder];
}

- (IBAction)switchChanged:(id)sender {
    UISwitch *s = (UISwitch*)sender;
    int setvalue = 0;
    if(s.on){
        setvalue = 1;
    }
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"userInfo"];
    
    NSString *uri = @"/cmy?action=ChangeApplyType";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"coachid"] forKey:@"coachid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:[NSString stringWithFormat:@"%d",setvalue] forKey:@"setvalue"];
   
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    
}
@end
