//
//  CouponNavigateViewController.m
//  guangda
//
//  Created by Ray on 15/9/16.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CouponNavigateViewController.h"
#import "MyTicketDetailViewController.h"
@interface CouponNavigateViewController ()
@property (strong, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UIView *sendCouponBackView;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UILabel *noAbilityLabel;

@end

@implementation CouponNavigateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendButton.enabled= NO;
    self.noAbilityLabel.hidden = NO;
    [self updateLimit];
    [self updateMoney];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)clickForCouponDetail:(id)sender {
    MyTicketDetailViewController *nextController = [[MyTicketDetailViewController alloc] initWithNibName:@"MyTicketDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
- (IBAction)clickForSendCoupon:(id)sender {
   
    
}

//更新余额
- (void)updateMoney{



}

//更新用户状态
- (void)updateLimit{
   


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
