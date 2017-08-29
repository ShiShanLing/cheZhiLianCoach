//
//  FeedBackViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "FeedBackViewController.h"
#import "LoginViewController.h"

@interface FeedBackViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *submitbutton;       // 提交按钮属性
@property (strong, nonatomic) IBOutlet UITextView *feedBackTextView; // 反馈内容

- (IBAction)submitBtn:(id)sender; // 提交按钮
@property (strong, nonatomic) IBOutlet UITextField *opinionTextField;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitB) name:UITextViewTextDidChangeNotification object:nil];
    //self.feedBackTextView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
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

// 设置提交是否能点击
- (void)submitB
{
    if(self.feedBackTextView.text.length != 0)
    {
        [self.submitbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.submitbutton.enabled = YES;
    }else{
        [self.submitbutton setTitleColor:MColor(211, 211, 211) forState:UIControlStateNormal];
        self.submitbutton.enabled = NO;
    }
}

// 提交按钮操作
- (IBAction)submitBtn:(id)sender {
    NSString *feedbackcontet = self.feedBackTextView.text;
    // 调用接口
    [self submitFeedBack:feedbackcontet feedBackType:1];
    
}


-(void)textViewDidChange:(UITextView *)textView
{
   // NSLog(@"---++");
    if(self.feedBackTextView.text.length == 0)
    {
        self.opinionTextField.hidden = NO;
    }else
    {
        self.opinionTextField.hidden = YES;
    }
}
#pragma mark - 意见反馈接口
- (void)submitFeedBack:(NSString *)feedBackContent feedBackType:(int)feedBackType {
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
