//
//  LoginViewController.m
//  guangda
//
//  Created by Dino on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CoachInfoViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *loginContentView;
@property (weak, nonatomic) IBOutlet UITextField *drivingNameTF;//驾校名字
@property (strong, nonatomic) IBOutlet UITextField *userName;   // 账号
@property (strong, nonatomic) IBOutlet UITextField *passWord;   // 密码
@property (weak, nonatomic) IBOutlet UILabel *chooseDrving;

@property (strong, nonatomic) IBOutlet UIView *loginDetailsView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtnOutlet;

//选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView; // 选择器
@property (strong, nonatomic) NSMutableArray *selectArray;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation LoginViewController {
    NSInteger selectRow;
    NSString  *drivingID;//所选择的
}
// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

// 完成驾校选择
- (IBAction)clickForDone:(UIButton *)sender {
    self.drivingNameTF.text = self.selectArray[selectRow][@"storeName"];
    drivingID = self.selectArray[selectRow][@"storeId"];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"chooseDriving" ofType:@"plist"];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [userData removeAllObjects];
    userData =[NSMutableDictionary dictionaryWithDictionary:self.selectArray[selectRow]];
    //获取应用程序沙盒的Documents目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    
    //得到完整的文件名
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"chooseDriving.plist"];
    //输入写入
    [userData writeToFile:filename atomically:YES];
    
    //那怎么证明我的数据写入了呢？读出来看看
    NSMutableDictionary *userData2 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    NSLog(@"查看是否存储成功%@", userData2);
    [self.selectView removeFromSuperview];
}
//选择驾校
- (IBAction)handleChooseDriing:(id)sender {
    [self.pickerView reloadAllComponents];
    self.selectView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.selectView];
}
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)tap {
    
    [self.selectView removeFromSuperview];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSexData];
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    
    [self.selectView addGestureRecognizer:singleFingerOne];

    self.chooseDrving.userInteractionEnabled = YES;
    self.drivingNameTF.userInteractionEnabled = NO;
    self.selectArray = [NSMutableArray array];
    self.pickerView.showsSelectionIndicator = NO;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    // Do any additional setup after loading the view from its nib.
    self.loginContentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.scrollView addSubview:self.loginContentView];
    [self.drivingNameTF  setValue:MColor(173, 173, 173) forKeyPath:@"_placeholderLabel.textColor"];
    self.drivingNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.userName setValue:MColor(173, 173, 173) forKeyPath:@"_placeholderLabel.textColor"];
    [self.passWord setValue:MColor(173, 173, 173) forKeyPath:@"_placeholderLabel.textColor"];
    self.loginBtnOutlet.layer.cornerRadius = 3;
    self.userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passWord.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.vcodeButton.layer.cornerRadius = 3;
    [self.vcodeButton setTitle:@"  获取\n验证码" forState:UIControlStateNormal];
    
    [self.vcodeButton didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        [self.vcodeButton setBackgroundColor:MColor(210, 210, 210)];
        [self.vcodeButton setTitleColor:MColor(37, 37, 37) forState:UIControlStateNormal];
        NSString *title = @"";
        if(second < 10){
            title = [NSString stringWithFormat:@"    %d\"\n后重获",second];
        }else if(second > 99){
            title = [NSString stringWithFormat:@"  %d\"\n后重获",second];
        }else{
            title = [NSString stringWithFormat:@"   %d\"\n后重获",second];
        }
        return title;
    }];
    [self.vcodeButton didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        [countDownButton setBackgroundColor:MColor(247, 148, 29)];
        [countDownButton setTitleColor:MColor(255, 255, 255) forState:UIControlStateNormal];
        return @"  重获\n验证码";
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBtnStatus) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelClick:) name:@"closeSelfView" object:nil];
    
    if(![CommonUtil isEmpty:self.errMessage]){
        [self makeToast:self.errMessage];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.userName) {
        if (range.location==11)
        {
            return  NO;
        }
        else
        {
            return YES;
        }
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma make  用户登录按钮点击时间

- (IBAction)loginClick:(id)sender {
    NSString *password = [self.passWord.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *phone = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
    if([CommonUtil isEmpty:password])
    {
        [self makeToast:@"请输入验证码"];
        return ;
    }
    [self login:phone passWord:password];
    
    
}
// 取消
- (IBAction)cancelClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}

// 密码显示明文
- (IBAction)showPwdClick:(id)sender {
    self.passWord.secureTextEntry = !self.passWord.secureTextEntry;
}

#pragma mark - 监听
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    int _height = [UIScreen mainScreen].bounds.size.height;
    
    int chazhi = (_height - self.loginDetailsView.bounds.size.height) / 2;
    
    self.scrollView.contentOffset = CGPointMake(0, height - chazhi+20-10);
    
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
- (void)checkBtnStatus
{
    if ((self.userName.text.length != 0)
        && (self.passWord.text.length != 0))
    {
        self.loginBtnOutlet.backgroundColor = MColor(32, 180, 120);
        
    }else{
        self.loginBtnOutlet.backgroundColor = MColor(210, 210, 210);
        
    }
}
//获取验证码
- (IBAction)clickForGetVcode:(JKCountDownButton *)sender {
    
    
    NSString *phone = [self.userName.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
    [self performSelector:@selector(indeterminateExample)];
    
    sender.enabled = NO;
    //button type要 设置成custom 否则会闪动
    [sender startWithSecond:60];
    
    
    [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        return @"点击重新获取";
    }];
    //http://106.14.158.95:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT/floor/api/verifyCode?mobile=13646712075
    NSString *URL_Str = [NSString stringWithFormat:@"%@/floor/api/verifyCode", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"mobile"] = phone;
    NSLog(@"%@", URL_Dic);
    __weak LoginViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"验证码responseObject%@", responseObject);
        [VC performSelector:@selector(delayMethod)];
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
                NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
                return title;
            }];
        }else {
            [VC makeToast:@"验证码获取失败请重试"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC performSelector:@selector(delayMethod)];
        [VC makeToast:@"网路超时请重试!"];
        NSLog(@"error%@", error);
    }];
}
//登录接口
- (void)login:(NSString *)userName passWord:(NSString *) passWord {
    
    [self performSelector:@selector(indeterminateExample)];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/login",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"mobile"] = userName;
    URL_Dic[@"mobileCode"] = passWord;
    URL_Dic[@"schoolId"] = drivingID;
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak LoginViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"登录responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        [VC performSelector:@selector(delayMethod)];
        if ([resultStr isEqualToString:@"1"]) {
            [VC AnalyticalDataDetails:responseObject];
        }else {
            [VC makeToast:responseObject[@"msg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC  makeToast:@"网络超时请重试!"];
        [VC  performSelector:@selector(delayMethod)];
        NSLog(@"error%@", error);
    }];
    
}
//存储用户信息到本地plis 文件一份 用于个界面对用户信息的更改和 获取
- (void)AnalyticalDataDetails:(NSDictionary *)dic {
    
    NSString *state = [NSString stringWithFormat:@"%@", dic[@"result"]];
    if ([state isEqualToString:@"1"]) {
        NSArray *userDataArray = dic[@"data"];
        if (userDataArray.count == 0) {
            [self makeToast:@"数据异常,请联系工作人员"];
            return;
        }
        NSDictionary *userDataDic = dic[@"data"][0];
        NSDictionary *userDic = userDataDic;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogInData" ofType:@"plist"];
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        [userData removeAllObjects];
        
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/detail", kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"coachId"] =userDic[@"coachId"];
        NSLog(@"AppDelegate里面获取用户详情 URL_Dic%@ userDic%@", URL_Dic, userDic);
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        [session.requestSerializer setTimeoutInterval:5];
        __weak LoginViewController *VC = self;
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress%@", uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取用户详情responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"0"]) {
                
            }else {
                [VC AnalyticalDetailsData:responseObject];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSLog(@"用户详情获取error%@", error);
        }];
        
    }
}
//解析的登录过后的数据
- (void)AnalyticalDetailsData:(NSDictionary *)dic {
    NSString *state = [NSString stringWithFormat:@"%@", dic[@"result"]];
    if ([state isEqualToString:@"1"]) {
        NSDictionary *tempDic = dic[@"data"][0];
        NSDictionary *urseDataDic = tempDic[@"coach"];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogInData" ofType:@"plist"];
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        [userData removeAllObjects];
        for (NSString *key in urseDataDic) {
            if ([key isEqualToString:@"state"]) {
                [UserDataSingleton mainSingleton].approvalState =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            if ([key isEqualToString:@"coachId"]) {
                [UserDataSingleton mainSingleton].coachId =[NSString stringWithFormat:@"%@", urseDataDic[key]];
                
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
        }
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        
        //得到完整的文件名
        NSString *filename=[plistPath1 stringByAppendingPathComponent:@"UserLogInData.plist"];
        //输入写入
        [userData writeToFile:filename atomically:YES];
        
        //那怎么证明我的数据写入了呢？读出来看看
        NSMutableDictionary *userData2 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
        NSLog(@"查看是否存储成功%@", userData2);
    }
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app jumpToMainViewController];
}

- (IBAction)handleDirectLogin:(UIButton *)sender {
    
    // 用户密码都不为空调用接口
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app jumpToMainViewController];
    
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}
// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.selectArray.count;
}
// 数据
- (void)initSexData {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    //得到完整的文件名
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"chooseDriving.plist"];
    //那怎么证明我的数据写入了呢？读出来看看
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    
    NSArray *datacount = [userData allKeys];
    if (datacount != 0) {
        self.drivingNameTF.text = userData[@"storeName"];
        drivingID = userData[@"storeId"];
    }
    
    self.pickerView.tag = 1;
    NSString *URL_Str = [NSString stringWithFormat:@"%@/store/api/getAllSchoolList",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    __weak  LoginViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC ParsingDrivingData:responseObject];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}

- (void) ParsingDrivingData:(NSDictionary *)data {
    NSArray *dataArray = data[@"data"];
    if (dataArray.count == 0) {
        [self showAlert:@"驾校信息获取失败,暂时无法登陆" time:1.0];
        return;
    }
    for (NSDictionary *dic in dataArray) {
        NSMutableDictionary *MDIC = [NSMutableDictionary dictionary];
        [MDIC setValue:dic[@"storeId"] forKey:@"storeId"];
        [MDIC setValue:dic[@"storeName"] forKey:@"storeName"];
        [self.selectArray addObject:MDIC];
    }
}
// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    // 性别选择器
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 45)];
    myView.textAlignment = NSTextAlignmentCenter;
    
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    
    myView.textColor = MColor(161, 161, 161);
    
    myView.backgroundColor = [UIColor clearColor];
    
    if (selectRow == row){
        myView.textColor = MColor(34, 192, 100);
    }
        myView.text = [self.selectArray objectAtIndex:row][@"storeName"];
    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectRow = row;
    NSLog(@"selectRow%ld", (long)selectRow);
    [pickerView reloadComponent:0];
    
}

@end
