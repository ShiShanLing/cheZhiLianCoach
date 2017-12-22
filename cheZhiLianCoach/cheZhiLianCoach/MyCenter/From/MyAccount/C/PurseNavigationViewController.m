//
//  PurseNavigationViewController.m
//  guangda
//
//  Created by Ray on 15/9/16.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "PurseNavigationViewController.h"
#import "AmountDetailViewController.h"
#import "ConvertCoinViewController.h"
@interface PurseNavigationViewController ()

@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel;

@end

@implementation PurseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateMoney];
}
- (IBAction)clickForMoney:(id)sender {
    AmountDetailViewController *nextController = [[AmountDetailViewController alloc] initWithNibName:@"AmountDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
- (IBAction)clickForCoinDetail:(id)sender {
    [self showAlert:@"该功能暂未开通" time:0.8];
    return;
    ConvertCoinViewController *nextController = [[ConvertCoinViewController alloc] initWithNibName:@"ConvertCoinViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
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
