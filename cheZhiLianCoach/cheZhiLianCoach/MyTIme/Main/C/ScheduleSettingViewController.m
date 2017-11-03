//
//  ScheduleSettingViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/4/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ScheduleSettingViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface ScheduleSettingViewController ()<UITextFieldDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *timeScrollView;//时间点scrollView
@property (strong, nonatomic) IBOutlet UISwitch *stateSwitch;//状态开关
@property (strong, nonatomic) IBOutlet UILabel *timeStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *priceTextField;//价格
@property (strong, nonatomic) IBOutlet UIButton *pricePencilBtn;
@property (strong, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;//上车地址

@property (strong, nonatomic) IBOutlet UITextField *carRent;//车辆租金
@property (strong, nonatomic) IBOutlet UIView *rentBackView;

@property (strong, nonatomic) IBOutlet UIButton *addressPencilBtn;
@property (strong, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *contentTextField;//教学内容
@property (strong, nonatomic) IBOutlet UIButton *contentPencilBtn;
@property (strong, nonatomic) IBOutlet UIButton *comfirmBtn;

//选择框
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIPickerView *selectPickerView;
@property (strong, nonatomic) IBOutlet UIView *selectView2;
@property (strong, nonatomic) IBOutlet UIPickerView *pricePickerView;
@property (strong, nonatomic) NSString *price;//价格

//参数
@property (strong, nonatomic) NSMutableArray *selectArray;//选中的时间段
@property (strong, nonatomic) NSMutableArray *addressArray;//地址
@property (strong, nonatomic) NSMutableArray *subjectArray;//科目
@property (strong, nonatomic) NSString *addressId;//地址id
@property (strong, nonatomic) NSString *subjectId;//科目id

@property (strong, nonatomic) NSString *selectPickerTag;//选中的标记

@property (nonatomic) CGRect viewRect;
@property (weak, nonatomic) IBOutlet UILabel *timePriceLabel;//时间状态描述文字
@property (strong, nonatomic) IBOutlet UILabel *rentTitleLabel;

- (IBAction)clickForback:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *experienceClass;
@end
@implementation ScheduleSettingViewController{
    //选中的科目
    NSInteger index;
}

- (NSMutableArray *)allDayArray {
    if (!_allDayArray) {
        _allDayArray = [NSMutableArray array];
    }
    return _allDayArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectPickerTag = @"0";
    self.selectArray = [NSMutableArray array];
    self.addressArray = [NSMutableArray array];
    self.subjectArray = [NSMutableArray array];
    self.rentBackView.hidden = YES;

    self.priceTextField.text = @"180";
    self.priceTextField.userInteractionEnabled = NO;

//    self.priceTextField.enabled = NO;
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self  initView];
    [self.experienceClass setTitleColor:MColor(28, 28, 28) forState:UIControlStateNormal];
    [self.experienceClass setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.experienceClass setImage:[UIImage imageNamed:@"btn_checkbox_unchecked"] forState:UIControlStateNormal];
    [self.experienceClass setImage:[UIImage imageNamed:@"btn_checkbox_checked"] forState:UIControlStateSelected];
    [self.experienceClass addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
    self.experienceClass.hidden = YES;
}

#pragma mark - 监听
//当键盘出现或改变时调用

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    self.mainScrollView.contentOffset = CGPointMake(0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.viewRect = self.view.frame;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)initView{
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.detailView.frame = CGRectMake(0, 0, width, CGRectGetHeight(self.detailView.frame));
    [self.mainScrollView addSubview:self.detailView];
    //------------------赋值-------------------
    //时间
    CGSize size = [CommonUtil sizeWithString:self.time fontSize:18 sizewidth:MAXFLOAT sizeheight:CGRectGetHeight(self.timeLabel.frame)];
    CGFloat maxWidth = ceil(size.width);
    self.timeLabel.frame = CGRectMake(0, 0, maxWidth, CGRectGetHeight(self.timeScrollView.frame));
    self.timeLabel.text = self.time;
    [self.timeScrollView addSubview:self.timeLabel];
    self.timeScrollView.contentSize = CGSizeMake(maxWidth, CGRectGetHeight(self.timeScrollView.frame));
    NSString *price;
    //价格
    if (_bai2 == _hei2) {
       price  = [NSString stringWithFormat:@"%.2f",self.bai2];
    }else {
        price = [NSString stringWithFormat:@"白天%.2f一个小时,夜里%.2f一个小时",_bai2,_hei2];
    }
    //地址
    self.addressTextField.text = @"暂无数据";
    //教学内容
    self.contentTextField.text = @"科目二";
    index = 0;
    //价格
    self.priceTextField.text = price;
    {//这里面的东西不要动,,目前就这样
        self.rentBackView.hidden = YES;
        self.isRentConstraint.constant = 0;
        self.experienceClass.selected = NO;
    }
        //打开状态
        self.timeStateLabel.text = @"开课状态，若关闭，以上时间点屏蔽任何 学员选课！";
        //时间单价状态
        self.priceTitleLabel.textColor = MColor(37, 37, 37);
        self.priceTextField.textColor = MColor(37, 37, 37);
        self.pricePencilBtn.hidden = NO;
        //上车地址状态
        self.addressTitleLabel.textColor = MColor(37, 37, 37);
        self.addressTextField.textColor = MColor(37, 37, 37);
        self.addressPencilBtn.hidden = NO;
        //教学内容状态
        self.contentPencilBtn.hidden = NO;
        self.contentTextField.textColor = MColor(37, 37, 37);
        self.contentTitleLabel.textColor = MColor(37, 37, 37);
        self.comfirmBtn.selected = YES;
    
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
// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
    myView.textAlignment = NSTextAlignmentCenter;
    NSDictionary *dic = [self.selectArray objectAtIndex:row];
    myView.text = dic[@"name"];
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    myView.textColor = [UIColor whiteColor];
    myView.backgroundColor = [UIColor clearColor];
    return myView;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    index = row;
}
#pragma mark - 页面特性
// 开始编辑，铅笔变蓝
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.priceTextField] || [textField isEqual:self.carRent]) {
        self.pricePencilBtn.selected = YES;
        self.comfirmBtn.selected = YES;
    }
}
// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
#pragma mark - private
- (void)backupgroupTap:(id)sender{
    [self.priceTextField resignFirstResponder];
    [self.carRent resignFirstResponder];
}
#pragma mark - action
- (void)clickForChoose:(id)sender {


}
//
- (IBAction)clickForChangeState:(id)sender {
    UISwitch *swi = (UISwitch *)sender;
    if (swi.isOn) {
        //打开状态
        self.timeStateLabel.text = @"开课状态，若关闭，以上时间点屏蔽任何 学员选课！";
        //时间单价状态
        self.priceTitleLabel.textColor = MColor(37, 37, 37);
        self.priceTextField.textColor = MColor(37, 37, 37);
        self.pricePencilBtn.hidden = NO;
        //上车地址状态
        self.addressTitleLabel.textColor = MColor(37, 37, 37);
        self.addressTextField.textColor = MColor(37, 37, 37);
        self.addressPencilBtn.hidden = NO;
        //教学内容状态
        self.contentPencilBtn.hidden = NO;
        self.contentTextField.textColor = MColor(37, 37, 37);
        self.contentTitleLabel.textColor = MColor(37, 37, 37);
    }else{
        //关闭状态
        self.timeStateLabel.text = @"未开课，以上时间点屏蔽任何学员选课！";
        //时间单价状态
        self.priceTitleLabel.textColor = MColor(210, 210, 210);
        self.priceTextField.textColor = MColor(210, 210, 210);
        self.pricePencilBtn.hidden = YES;
        
        //上车地址状态
        self.addressTitleLabel.textColor = MColor(210, 210, 210);
        self.addressTextField.textColor = MColor(210, 210, 210);
        self.addressPencilBtn.hidden = YES;
        
        //教学内容状态
        self.contentPencilBtn.hidden = YES;
        self.contentTextField.textColor = MColor(210, 210, 210);
        self.contentTitleLabel.textColor = MColor(210, 210, 210);
    }
    
    self.comfirmBtn.selected = YES;
}
//价格
- (IBAction)clickForPrice:(id)sender {
    
    
}
//选择地址
- (IBAction)clickForChooseAddress:(id)sender {
    
    
}
//教学内容
- (IBAction)clickForContent:(id)sender {
        [self.selectArray removeAllObjects];
    
    for (int i= 0; i< 2; i++) {
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        NSArray *nameArray = @[@"科目二", @"科目三"];
        NSArray *idArray = @[@"0", @"1"];
        [dataDic setObject:nameArray[i] forKey:@"name"];
        [dataDic setObject:idArray[i] forKey:@"id"];
        [self.selectArray addObject:dataDic];
    }
    
    for (int i=0; i<self.selectArray.count; i++) {
        NSDictionary *dic = self.selectArray[i];
        NSString *arrayId = [dic[@"id"] description];
        NSString *subjectid = [self.timeDic[@"subjectid"] description];
        if ([arrayId intValue] == [subjectid intValue]) {
            [self.selectPickerView selectRow:i inComponent:0 animated:YES];
        }
    }
        self.selectPickerView.tag = 1;
        self.selectView.frame = self.view.frame;
        [self.view addSubview:self.selectView];
        [self.selectPickerView reloadAllComponents];
}

- (IBAction)clickForRemoveSelect:(id)sender {
    self.selectPickerTag = @"0";
    [self.selectView removeFromSuperview];
}

- (IBAction)clickForSelect:(id)sender {
    NSString *price;
    //价格
   
   //如果是科目二
    if (index == 0) {
        //教学内容
        self.contentTextField.text = @"科目二";
        if (_bai2 == _hei2) {
            price  = [NSString stringWithFormat:@"%.2f",self.bai2];
        }else {
            price = [NSString stringWithFormat:@"白天%.2f一个小时,夜里%.2f一个小时",_bai2,_hei2];
        }
        //价格
        self.priceTextField.text = price;
    }else {//否者就是科目三
        self.contentTextField.text = @"科目三";
        if (_bai3 == _hei3) {
            price  = [NSString stringWithFormat:@"%.2f",self.bai3];
        }else {
            price = [NSString stringWithFormat:@"白天%.2f一个小时,夜里%.2f一个小时",_bai3,_hei3];
        }
        //价格
        self.priceTextField.text = price;
    }
    [self.selectView removeFromSuperview];
}

- (IBAction)clickForConfirm:(id)sender {
    if (self.comfirmBtn.selected) {
        [self checkOpenClass];
    }
}

- (void)checkOpenClass {
    NSMutableArray *selectedTimeArray = [NSMutableArray array];
    NSString *priceStr ;
    NSString *coachNameStr;
    for (NSArray * timeArray in self.allDayArray) {
        for (CoachTimeListModel *model in timeArray) {
            if (model.state == 4) {
                priceStr = [NSString stringWithFormat:@"%.0f", model.unitPrice];;
                [selectedTimeArray addObject:[NSString stringWithFormat:@"%ld%@", (long)[model.startTime timeIntervalSince1970], @"000"]];
                [selectedTimeArray addObject:[NSString stringWithFormat:@"%ld%@", (long)[model.endTime timeIntervalSince1970], @"000"]];
            }
        }
    }
    [self performSelector:@selector(indeterminateExample)];
    NSString *timeArraayStr = [selectedTimeArray componentsJoinedByString:@","];
    timeArraayStr = [timeArraayStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    timeArraayStr =[timeArraayStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    timeArraayStr =[timeArraayStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/openClass", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"]= [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"time"]= timeArraayStr;
    URL_Dic[@"subType"]= [NSString stringWithFormat:@"%ld", index==0?2:3];
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak  ScheduleSettingViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [VC performSelector:@selector(delayMethod)];
        //    NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC makeToast:@"提交成功"];
            [VC.navigationController popViewControllerAnimated:YES];
        }else {
            [VC makeToast:@"提交失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC performSelector:@selector(delayMethod)];
        NSLog(@"error%@", error);
    }];
    
    
}
//提交修改信息
- (void)comfirmMsg{
    NSString *price = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rentPrice = [self.carRent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *state = [self.timeDic[@"state"] description];
    NSString *subject = [self.contentTextField.text description];
    NSString *addressdetail = [self.addressTextField.text description];
}

// 将字典或者数组转化为JSON串
- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (IBAction)clickForback:(id)sender {
    if (self.comfirmBtn.selected == YES) {   //添加一个退出的提示，防止教练在不经意的情况下退出了。
        [self.priceTextField resignFirstResponder];
        [self.carRent resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请点击保存让您的修改生效" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"放弃", nil];
        [alert show];
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDaySchedule" object:array];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self checkOpenClass];
    }else if(buttonIndex == 1){
        [self.priceTextField resignFirstResponder];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
