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
    
    switch (self.viewType.intValue) {
        case 1:
            if (self.inputTextfield.text.length > 0) {
                [self updateUserName];
            }else{
                [self showAlert:@"不能提交空白资料" time:1.0];
            }
            break;
        case 2:
            if (self.inputTextfield.text.length > 0) {
                [self upDateDrivingAge];
            }else{
                [self showAlert:@"不能提交空白资料" time:1.0];
            }
            break;
        case 3:
            if (self.inputTextView.text.length > 0) {
                [self upDatePersonalAssessment];
            }else{
                [self showAlert:@"不能提交空白资料" time:1.0];
            }
            break;
            
        default:
            break;
    }
}
#pragma mark - 接口
//提交个人资料
- (void)updateUserName{
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

- (void)upDateDrivingAge {
//    [self showAlert:@"等待添加选择器!" time:1.0];
 //   return;
    [self respondsToSelector:@selector(indeterminateExample)];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/setTeachAge",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"teachAge"] = self.inputTextfield.text;
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
            [VC AnalysisUserData];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC respondsToSelector:@selector(delayMethod)];
        [VC showAlert:@"更改姓名请求失败!"time:1.2];
        NSLog(@"error%@", error);
    }];
}

- (void)upDatePersonalAssessment {
    
    [self respondsToSelector:@selector(indeterminateExample)];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/addPersonalDesc",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"description"] = self.inputTextView.text;
    NSLog(@"URL_Dic%@", URL_Dic);
    
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
            [VC AnalysisUserData];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC respondsToSelector:@selector(delayMethod)];
        [VC showAlert:@"更改个人评价请求失败!"time:1.2];
        NSLog(@"error%@", error);
    }];
}


#pragma make  数据获取
- (void)AnalysisUserData{
    //获取应用程序沙盒的Documents目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSLog(@"paths%@", paths);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filename=[plistPath stringByAppendingPathComponent:@"UserLogInData.plist"];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    NSLog(@"%@userData", userData);
    NSArray *keyArray =[userData allKeys];
    
    if (keyArray.count == 0) {
        
        
    }else {
        //http://106.14.158.95:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT/coach/api/detail?coachId=206405433894470f91db2657ae8e73e3
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/detail", kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"coachId"] =userData[@"coachId"];
        NSLog(@"URL_Dic%@", URL_Dic);
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        __block CoachInfoTextFieldViewController *VC = self;
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"0"]) {
                
            }else {
                [VC AnalyticalData:responseObject];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [VC showAlert:@"请求失败请重试" time:1.0];
        }];
    }
}
//解析的用户详情信息
- (void)AnalyticalData:(NSDictionary *)dic {
    NSString *state = [NSString stringWithFormat:@"%@", dic[@"result"]];
    if ([state isEqualToString:@"1"]) {
        NSDictionary *tempDic = dic[@"data"][0];
        NSDictionary *urseDataDic = tempDic[@"coach"];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogInData" ofType:@"plist"];
        
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CoachAuditStatusModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CoachAuditStatusModel *model = [[CoachAuditStatusModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        [userData removeAllObjects];
        for (NSString *key in urseDataDic) {
            if ([key isEqualToString:@"state"]) {
                [UserDataSingleton mainSingleton].approvalState =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            if ([key isEqualToString:@"coachId"]) {
                [UserDataSingleton mainSingleton].coachId =[NSString stringWithFormat:@"%@", urseDataDic[key]];
                NSLog(@"[UserDataSingleton mainSingleton].coachId%@", [UserDataSingleton mainSingleton].coachId);
            }
            if ([key isEqualToString:@"realName"]) {
                [UserDataSingleton mainSingleton].userName =[NSString stringWithFormat:@"%@", urseDataDic[key]];
                
            }
            if ([key isEqualToString:@"balance"]) {
                [UserDataSingleton mainSingleton].balance =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            if ([key isEqualToString:@"carTypeId"]) {
                [UserDataSingleton mainSingleton].carTypeId =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            [userData setObject:urseDataDic[key] forKey:key];
            [model setValue:urseDataDic[key] forKey:key];
        }
        [UserDataSingleton mainSingleton].coachModel = model;
        
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        
        //得到完整的文件名
        NSString *filename=[plistPath1 stringByAppendingPathComponent:@"UserLogInData.plist"];
        //输入写入
        [userData writeToFile:filename atomically:YES];
        
        //那怎么证明我的数据写入了呢？读出来看看
        NSMutableDictionary *userData2 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
