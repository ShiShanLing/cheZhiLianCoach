//
//  SearchAddrViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SearchAddrViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SearchAddrViewController () <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *naviView;
@property (strong, nonatomic) IBOutlet UITextView *positionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *pencilImageVIew;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *addrField;


@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *searchBtn;
@property (strong, nonatomic) NSString *area;//城市
@property (strong, nonatomic) NSString *detailAddress;//详细地址
@end

@implementation SearchAddrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

-(void)backupgroupTap:(id)sender{
    [self.addrField resignFirstResponder];
    [self.positionTextView resignFirstResponder];
}

#pragma mark - textView代理
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.pencilImageVIew setImage:[UIImage imageNamed:@"icon_pencil_blue"]];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.pencilImageVIew setImage:[UIImage imageNamed:@"icon_pencil_black"]];
}

#pragma mark - textField代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.searchBtn setTitle:text forState:UIControlStateNormal];
    self.searchView.hidden = YES;
    return YES;
    
}

#pragma mark - action
- (IBAction)clickForCancel:(id)sender {
    self.searchView.hidden = YES;
}

- (IBAction)clickForSearchNavi:(id)sender {
    self.searchView.hidden = NO;
}

- (IBAction)clickForSave:(id)sender {
    
    //上传数据
    NSString *place = [self.positionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

//    if ([CommonUtil isEmpty:place]) {
//        [self makeToast:@"请选择或者输入学车地址"];
//        return;
//    }
//    
//    if ([CommonUtil isEmpty:self.area]) {
//        [self makeToast:@"请选择省市"];
//        return;
//    }
    [self saveAddress:place];
    
}

#pragma mark - 接口
- (void)saveAddress:(NSString *)place{
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/addTrainAddress", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    //=ee63ee92e55245fca333bb032a85a875&=123
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"addressName"] = @"河南省-驻马店市-平舆县-东和店镇(测试数据)";
    __weak  SearchAddrViewController  *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        NSLog(@"responseObject%@", responseObject);
        if ([resultStr isEqualToString:@"1"]) {
            [VC showAlert:responseObject[@"msg"] time:1.2];
            [VC.navigationController popViewControllerAnimated:YES];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC showAlert:@"网络出现错误.请稍后重试!" time:1.2];
        NSLog(@"error%@", error);
    }];
    
    
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
