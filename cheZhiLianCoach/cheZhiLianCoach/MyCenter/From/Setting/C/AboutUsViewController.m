//
//  AboutUsViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *version;

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *VersionText = [NSString stringWithFormat:@"版本%@",app_Version];
    self.version.text = VersionText;
    self.testLabel.hidden = YES;
//    if (![REQUEST_HOST isEqualToString:@"http://www.xiaobakaiche.com/dadmin/"]) {
//        self.testLabel.hidden = NO;
//    }
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.cornerRadius = 15;
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
