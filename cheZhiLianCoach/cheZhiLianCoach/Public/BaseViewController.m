/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "BaseViewController.h"

@interface BaseViewController ()
@property (nonatomic, strong)UIAlertController *alertV;
@end

@implementation BaseViewController
- (NSManagedObjectContext *)managedContext {
    if (!_managedContext) {
        //获取Appdelegate对象
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedContext = delegate.managedObjectContext;
    }
    
    return _managedContext;
}
- (AppDelegate *)AppDelegate {
    if (!_AppDelegate) {
        self.AppDelegate = [[AppDelegate alloc] init];
    }
    return _AppDelegate;
}

//此方法设置的是白色子体
//******************************************
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
//******************************************

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    if ([UserDataSingleton mainSingleton].URL_SHY.length != 0) {
        return;
    }
//    __weak BaseViewController *VC = self;
//    self.alertV = [UIAlertController alertControllerWithTitle:@"提醒!" message:@"请填写您的服务器" preferredStyle:UIAlertControllerStyleAlert];
//    [_alertV addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        textField.placeholder = @"服务器地址:";
//    }];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"填好了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        UITextField *URLTF = _alertV.textFields.firstObject;
//        [UserDataSingleton mainSingleton].URL_SHY = URLTF.text;
//        [VC validateUrl:[NSURL URLWithString:kURL_SHY]];
//    }];
//    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"爷不填!" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        [VC showAlert:@"不填打死" time:1.2];
//        [VC presentViewController:_alertV animated:YES completion:nil];
//        return;
//    }];
//    // 3.将“取消”和“确定”按钮加入到弹框控制器中
//    [_alertV addAction:okAction];
//    [_alertV addAction:noAction];
//    [self presentViewController:_alertV animated:YES completion:^{
//        nil;
//    }];
}

//判断
-(void) validateUrl: (NSURL *) candidate {
    __weak BaseViewController *VC = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:candidate];
    [request setHTTPMethod:@"HEAD"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"error %@",error);
        if (error) {
            [VC makeToast:@"服务器不可用,请重新填写!"];
            return ;
        }else{
            [VC makeToast:@"欢迎使用车智联教练内侧版,有问题及时反馈哦!"];
            return ;
        }
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClick:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//网络加载指示器
- (void)indeterminateExample {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];//加载指示器出现
}

- (void)delayMethod{
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];//加载指示器消失
    
}

#pragma make  数据获取
- (void)refreshUserData{
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
        __block BaseViewController *VC = self;
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
    
    
}

@end
