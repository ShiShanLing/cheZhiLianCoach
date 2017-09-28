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

@end
