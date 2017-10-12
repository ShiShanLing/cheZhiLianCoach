//
//  CoachInfoTextFieldViewController.m
//  guangda
//
//  Created by Ray on 15/8/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachInfoTextFieldViewController.h"
#import "LoginViewController.h"
@interface CoachInfoTextFieldViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputTextfield;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIView *inputBackView;
@property (strong, nonatomic) IBOutlet UITextView *inputTextView;

@property (strong, nonatomic) NSMutableDictionary *msgDic;//资料
@end

@implementation CoachInfoTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.msgDic = [NSMutableDictionary dictionary];
    
    self.inputTextfield.delegate = self;
    self.inputTextView.delegate = self;
    self.inputBackView.hidden = YES;
    //1：姓名   2：驾培教龄  3：个人评价
    if ([self.viewType intValue] == 1) {
        self.titleLabel.text = @"姓名";
        self.inputTextfield.placeholder = @"请输入真实姓名";
        if (self.textString.length>0) {
            self.inputTextfield.text = self.textString;
        }
        self.inputTextfield.keyboardType = UIKeyboardTypeDefault;
    }else if ([self.viewType intValue] == 2){
        self.titleLabel.text = @"驾培教龄";
        self.inputTextfield.placeholder = @"请输入真实驾培教龄";
        if (self.textString.length>0) {
            self.inputTextfield.text = self.textString;
        }
        self.inputTextfield.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([self.viewType intValue] == 3){
        self.inputBackView.hidden = NO;
        self.titleLabel.text = @"个人评价";
        if (self.textString.length>0) {
//            NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
//            NSString *selfeval = userInfo[@"selfeval"];
//            self.inputTextView.text = selfeval;
            self.inputTextView.text = self.textString;
        }else{
            self.inputTextView.text = @"";
        }
        //        self.inputTextfield.placeholder = @"请输入真实姓名";
    }
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self registerForKeyboardNotifications];
}

- (IBAction)clickForCommit:(id)sender {
    if (self.inputTextfield.text.length > 0) {
            [self updateUserData];
    }else{
        [self makeToast:@"不能提交空白资料"];
    }
}

#pragma mark - 接口
//提交个人资料
- (void)updateUserData{
    [self respondsToSelector:@selector(indeterminateExample)];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/setRealName",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"realName"] = self.inputTextfield.text;
    __weak  CoachInfoTextFieldViewController   *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        [VC respondsToSelector:@selector(delayMethod)];
        if ([resultStr isEqualToString:@"1"]) {
            [VC showAlert:responseObject[@"msg"] time:1.2];
            [VC.navigationController popViewControllerAnimated:YES];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC respondsToSelector:@selector(delayMethod)];
        [VC showAlert:@"更改姓名请求失败!"time:1.2];
        NSLog(@"error%@", error);
    }];

}

//提交个人资料
- (void)updateUserData:(NSString *)key and:(id)value{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = userInfo[@"coachid"];
   
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}


-(void)backupgroupTap:(id)sender{
    [self.inputTextfield resignFirstResponder];
}


#pragma mark - 键盘遮挡输入框处理
// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    //    CGFloat keyboardTop = keyboardRect.origin.y;
    
    //    CGFloat offset = CGRectGetMaxY(self.commitView.frame) - keyboardTop + 10;
    
    NSTimeInterval animationDuration = 0.3f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //    self.commitView.frame = CGRectMake(_oldFrame.origin.x, _oldFrame.origin.y - offset, _oldFrame.size.width, _oldFrame.size.height);
    [UIView commitAnimations];
    
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
  
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
