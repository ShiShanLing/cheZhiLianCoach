//
//  GoComplaintViewController.m
//  guangda
//
//  Created by Dino on 15/4/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GoComplaintViewController.h"
#import "UIPlaceHolderTextView.h"
#import "LoginViewController.h"

@interface GoComplaintViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *dataArr;   // 存放服务器的数据
    NSMutableArray *reasonArr; // 存放原因
    NSMutableArray *reasonIdArr; // 存放原因Id
}

@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *complaintTextview;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *pickComplaintClassView;
@property (strong, nonatomic) IBOutlet UILabel *showReasonLabel; // 显示选择的原因


- (IBAction)sumbitBtn:(id)sender; // 提交按钮

@end

@implementation GoComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArr = [[NSMutableArray alloc] init];
    reasonArr = [[NSMutableArray alloc] init];
    reasonIdArr = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    self.complaintTextview.placeholder = @"说点什么吧~";
    self.complaintTextview.placeholderColor = MColor(210, 210, 210);
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}


-(void)backupgroupTap:(id)sender{
    [self.complaintTextview resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 获取投诉原因
- (void)getReasons
{
    [reasonArr removeAllObjects];
    [reasonIdArr removeAllObjects];
    for(int i = 0;i < dataArr.count;i++)
    {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *content = [dic objectForKey:@"content"];
        NSString *reason = [dic objectForKey:@"setid"];
        [reasonArr addObject:content];
        [reasonIdArr addObject:reason];
    }
}

- (IBAction)chooseComplaintClass:(id)sender
{
    [self getReason:1];// 调用获取原因接口
}
- (IBAction)sureChooseClassClick:(id)sender {
    if(reasonIdArr.count == 0){
        self.showReasonLabel.text = @"请选择投诉原因";
        
    }else{
     NSInteger row = [self.pickerView selectedRowInComponent:0]; // 获取pickerView的cell
    self.showReasonLabel.text = [reasonArr objectAtIndex:row];
        self.showReasonLabel.textColor = MColor(32, 180, 120);
    }
    [self.pickComplaintClassView removeFromSuperview];
}

#pragma mark - UIPickerView
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.pickerView]) {
        return 1;
    }
    else {
        return 0;
    }
    //return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
   // return 4;
    if ([pickerView isEqual:self.pickerView]) {
        return dataArr.count;
    }
    else {
        return 0;
    }
    //return dataArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //return @"学员态度差";
    NSString *str = @"";
    
    // 性别选择器
    if ([pickerView isEqual:self.pickerView]) {
        str = [reasonArr objectAtIndex:row];
    }
    return str;
}

// 提交按钮
- (IBAction)sumbitBtn:(id)sender {
     NSInteger row = [self.pickerView selectedRowInComponent:0]; // 获取pickerView的cell
    if(reasonArr.count == 0){
        [self makeToast:@"请选择投诉原因"];
        return ;
    }
//    NSString *strContent = [reasonArr objectAtIndex:row];
    NSString *strReason = [reasonIdArr objectAtIndex:row];
    
    NSString *content = [self.complaintTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([CommonUtil isEmpty:content]) {
        [self makeToast:@"请输入投诉内容"];
        return;
    }
    
    [self sumbitReason:strReason complainContent:content orderId:self.taskReasonId];
}
#pragma mark - 接口
- (void)getReason:(int )type {
  
}
#pragma mark - 接口
- (void)sumbitReason:(NSString *)reasonId complainContent:(NSString *)complainContent orderId:(NSInteger)orderId{
   
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end
