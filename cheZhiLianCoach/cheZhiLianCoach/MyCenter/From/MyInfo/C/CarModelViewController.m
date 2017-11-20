//
//  CarModelViewController.m
//  guangda
//
//  Created by Ray on 15/8/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CarModelViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface CarModelViewController ()
@property (strong, nonatomic) NSMutableDictionary *msgDic;//参数
@property (strong, nonatomic) IBOutlet UIButton *C1Button;
@property (strong, nonatomic) IBOutlet UIButton *C2Button;

@end

@implementation CarModelViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestCarTypeData];
}

- (void)requestCarTypeData {
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/gainCarType",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    __weak  CarModelViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
    [self.C1Button setImage:[UIImage imageNamed:@"ic_c1car"] forState:UIControlStateNormal];
    [self.C1Button setImage:[UIImage imageNamed:@"ic_selected_c1car"] forState:UIControlStateSelected];
    [self.C2Button setImage:[UIImage imageNamed:@"ic_c2car"] forState:UIControlStateNormal];
    [self.C2Button setImage:[UIImage imageNamed:@"ic_selected_c2car"] forState:UIControlStateSelected];
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *modelid = [userInfo[@"modelid"]description];//准教车型id
    NSArray *array = [modelid componentsSeparatedByString:@","];
    for (int i=0; i<array.count; i++) {
        NSString *model = array[i];
        if ([model intValue] == 17) {
            self.C1Button.selected = YES;
        }
        if ([model intValue] == 18) {
            self.C2Button.selected = YES;
        }
    }
}
- (IBAction)clickForC1:(id)sender {
    self.C2Button.selected = self.C1Button.selected;
    if (self.C1Button.selected) {
        self.C1Button.selected = NO;
    }else{
        self.C1Button.selected = YES;
    }
}
- (IBAction)clickForC2:(id)sender {
    self.C1Button.selected = self.C2Button.selected;
    if (self.C2Button.selected) {
        self.C2Button.selected = NO;
    }else{
        self.C2Button.selected = YES;
    }
}
- (IBAction)commitCarmodel:(id)sender {
    if (self.C1Button.selected || self.C2Button.selected) {
        [self pushCarModel];
    }else{
        [self makeToast:@"请至少选择一种车型"];
    }
}

- (void)pushCarModel{
   
    
    NSString *carStr;
    if (self.C1Button.selected) {
        
        self.blockCar(@"C1",@"1");
    }
    if (self.C2Button.selected) {
        self.blockCar(@"C2",@"2");
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
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
