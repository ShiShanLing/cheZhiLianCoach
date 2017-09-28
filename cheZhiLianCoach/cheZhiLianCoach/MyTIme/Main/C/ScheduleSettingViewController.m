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
{
    NSArray *array100;
    NSArray *array10;
    NSArray *array1;
    UILabel *myView1;
    UILabel *myView2;
    UILabel *myView3;
    NSString *minPrice;
    NSString *maxPrice;
    
    NSString *signstate;   //签约状态 ： 0 未签约，1 已签约 ，2 签约过期
    NSString *signexpired; //签约到期日期
    NSString *subject2min; //科目二范围最小值。
    NSString *subject2max; //科目二范围最大值。
    NSString *subject3min; //科目三范围最小值。
    NSString *subject3max; //科目三范围最大值。
    NSString *trainingmax; //考场训练最大值。
    NSString *trainingmin; //考场训练最小值。
    NSString *accompanymin; //陪驾范围最小值。
    NSString *accompanymax; //陪驾范围最大值。
    NSString *hirecarmax; //租车范围最大值。
    NSString *hirecarmin; //租车范围最小值。
    NSString *tastesubject2min; //体验课科目二范围最小值
    NSString *tastesubject2max; //体验课科目二范围最大值
    NSString *tastesubject3min; //体验课科目三范围最小值
    NSString *tastesubject3max; //体验课科目三范围最大值
}
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
@implementation ScheduleSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectPickerTag = @"0";
    self.selectArray = [NSMutableArray array];
    self.addressArray = [NSMutableArray array];
    self.subjectArray = [NSMutableArray array];
    self.rentBackView.hidden = YES;
    //将价格输入框变成选择框
    self.pricePickerView.delegate = self;
    self.pricePickerView.dataSource = self;
    self.priceTextField.text = @"180";
    self.priceTextField.userInteractionEnabled = NO;
    array100 = @[@"0",@"1",@"2",@"3",@"4",@"5"];                     //百位 十位 个位   已弃用
    array10 = @[@"5",@"6",@"7",@"8",@"9"];
    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
//    self.priceTextField.enabled = NO;
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //获取教练价格设置表
    [self getCoachPriceRange];
    //获取地址信息
    [self getAddressData];
    //获取教学内容
    [self getContentData];
    [self initView];
    
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
    
    //价格
    NSString *price = [self.timeDic[@"price"] description];
    price = [CommonUtil isEmpty:price]?@"":price;
    price = price;//[NSString stringWithFormat:@"%d", [price floatValue]];
    
    //地址
    NSString *address = [CommonUtil isEmpty:self.timeDic[@"addressdetail"]]?@"":self.timeDic[@"addressdetail"];
    self.addressTextField.text = address;
    
    //教学内容
    NSString *subject = [CommonUtil isEmpty:self.timeDic[@"subject"]]?@"":self.timeDic[@"subject"];
    self.contentTextField.text = subject;
    
    //价格
    NSString *rentPrice = [self.timeDic[@"cuseraddtionalprice"] description];
    self.carRent.text = rentPrice;
    
    self.addressId = self.timeDic[@"addressid"];
    self.subjectId = self.timeDic[@"subjectid"];

    if ([self.subjectId intValue] == 4) {
        self.rentBackView.hidden = NO;
        self.isRentConstraint.constant = 81;
    }else{
        self.rentBackView.hidden = YES;
        self.isRentConstraint.constant = 0;
    }
    
    NSString *isfreecourse = [self.timeDic[@"isfreecourse"] description];
    if ([isfreecourse boolValue]) {
        self.experienceClass.selected = YES;
    }else{
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
    
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 45.0;
    
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.pricePickerView) {
        return 3;
    }
    return 1;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pricePickerView) {
        if (component == 0) {
            return array100.count;
        }
        if (component == 1) {
            return array10.count;
        }
        if (component == 2) {
            return array1.count;
        }
    }
    return self.selectArray.count;
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (pickerView == self.pricePickerView) {
        if (component == 0) {
            myView1 = nil;
            myView1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView1.textAlignment = NSTextAlignmentCenter;
            myView1.text = [array100 objectAtIndex:row];
            myView1.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView1.textColor = [UIColor whiteColor];
            myView1.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView1;
        }
        if (component == 1) {
            myView2 = nil;
            myView2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView2.textAlignment = NSTextAlignmentCenter;
                myView2.text = [array10 objectAtIndex:row];
            myView2.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView2.textColor = [UIColor whiteColor];
            myView2.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView2;
        }
        if (component == 2) {
            myView3 = nil;
            myView3 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
            myView3.textAlignment = NSTextAlignmentCenter;
            myView3.text = [array1 objectAtIndex:row];
            myView3.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
            myView3.textColor = [UIColor whiteColor];
            myView3.backgroundColor = [UIColor clearColor];
            self.price = [NSString stringWithFormat:@"%@%@%@",myView1.text,myView2.text,myView3.text];
            return myView3;
        }
        return nil;
    }
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
    if (pickerView == self.pricePickerView) {
        //限制价格的区间，在50~500之间
        if (component == 0) {
            if ([array100[row] isEqualToString:@"5"]) {
                array10 = @[@"0"];
                array1 = @[@"0"];
                [self.pricePickerView reloadComponent:1];
                [self.pricePickerView reloadComponent:2];
                
            }else{
                if ([array100[row] isEqualToString:@"0"]) {
                    array10 = @[@"5",@"6",@"7",@"8",@"9"];
                    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    [self.pricePickerView reloadComponent:1];
                    [self.pricePickerView reloadComponent:2];
                }else{
                    array10 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    array1 = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
                    [self.pricePickerView reloadComponent:1];
                    [self.pricePickerView reloadComponent:2];
                }
            }
        }
        [self.pricePickerView reloadAllComponents];
    }
    
}

#pragma mark - 页面特性
// 开始编辑，铅笔变蓝
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.f];
    if ([textField isEqual:self.priceTextField] || [textField isEqual:self.carRent]) {
        self.pricePencilBtn.selected = YES;
        self.comfirmBtn.selected = YES;
//        CGRect frame1 = self.priceTextField.frame;
//        UIView *view1 = self.priceTextField.superview;
//        CGRect frame2 = view1.frame;
//        UIView *view2 = view1.superview;
//        CGRect frame3 = view2.frame;
//        CGFloat offset = (frame1.origin.y + frame2.origin.y + frame3.origin.y) + 32 - (self.view.frame.size.height - 216.0) + 64;
//        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//        if (offset>0){
//            NSTimeInterval animationDuration = 0.30;
//            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//            [UIView setAnimationDuration:animationDuration];
//            [self.view setFrame:CGRectMake(0, -offset, self.viewRect.size.width, self.viewRect.size.height)];
//            [UIView commitAnimations];
//        }
    }
}

// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.priceTextField]) {
        if ([self.priceTextField.text intValue] <= [maxPrice intValue] && [self.priceTextField.text intValue] >=[minPrice intValue]) {
            self.pricePencilBtn.selected = NO;
//            self.view.frame = self.viewRect;
        }else{
            [self makeToast:[NSString stringWithFormat:@"请输入%@~%@之间的单价",minPrice,maxPrice]];
//            [[UIMenuController sharedMenuController] setMenuVisible: YES animated: YES];
        }
    }
    
    if ([textField isEqual:self.carRent]) {
        if ([self.carRent.text intValue] <= [hirecarmax intValue] && [self.carRent.text intValue] >=[hirecarmin intValue]) {
            self.pricePencilBtn.selected = NO;
            //            self.view.frame = self.viewRect;
        }else{
            [self makeToast:[NSString stringWithFormat:@"请输入%@~%@之间的单价",hirecarmin,hirecarmax]];
            //            [[UIMenuController sharedMenuController] setMenuVisible: YES animated: YES];
        }
    }
    
}
#pragma mark - private
- (void)backupgroupTap:(id)sender{
    [self.priceTextField resignFirstResponder];
    [self.carRent resignFirstResponder];
}
#pragma mark - action
- (void)clickForChoose:(id)sender {
    
  

}

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
    [self.selectView2 removeFromSuperview];
}

- (IBAction)clickForSelect:(id)sender {
    if ([self.selectPickerTag intValue] == 1) {
        self.selectPickerTag = @"0";
        NSString *str = [self.price substringToIndex:1];
        if ([str isEqualToString:@"0"]) {
            self.price = [self.price substringFromIndex:1];
        }
        self.comfirmBtn.selected = YES;

        [self.selectView2 removeFromSuperview];
    }else{
        NSInteger row = [self.selectPickerView selectedRowInComponent:0];
        NSDictionary *dic = [self.selectArray objectAtIndex:row];
        
        if (self.selectPickerView.tag == 0) {
            //地址
            self.addressId = dic[@"id"];
            self.addressTextField.text = dic[@"name"];
        }else if (self.selectPickerView.tag == 1){
            self.pricePencilBtn.hidden = NO;
            //教学内容
            self.subjectId = dic[@"id"];
            self.contentTextField.text = dic[@"name"];
            if ([self.subjectId intValue]==4) {
                self.rentBackView.hidden = NO;
                self.isRentConstraint.constant = 81;
            }else{
                self.rentBackView.hidden = YES;
                self.isRentConstraint.constant = 0;
            }
            if ([self.subjectId intValue] == 1||[self.subjectId intValue] == 2) {
                self.experienceClass.hidden = NO;
                self.experienceClass.selected = NO;
                if ([self.subjectId intValue]==1) {//1:科目二 2：科目三 3：考场训练 4：陪驾
                    maxPrice = subject2max;
                    minPrice = subject2min;
                }else if ([self.subjectId intValue]==2){
                    maxPrice = subject3max;
                    minPrice = subject3min;
                }
                if (maxPrice == minPrice) {
                    self.timePriceLabel.text = @"课时单价（单位：元/小时，价格无法修改）";
                    self.priceTextField.enabled = NO;
                    self.pricePencilBtn.hidden = YES;
                }else{
                    self.timePriceLabel.text = [NSString stringWithFormat:@"课时单价（单位：元/小时，价格区间：%@元～%@元）",minPrice,maxPrice];
                    self.priceTextField.enabled = YES;
                    self.pricePencilBtn.hidden = NO;
                }
            }else{
                self.experienceClass.hidden = YES;
                self.experienceClass.selected = NO;
                if ([self.subjectId intValue]==3){
                    maxPrice = trainingmax;
                    minPrice = trainingmin;
                }else if ([self.subjectId intValue]==4){
                    maxPrice = accompanymax;
                    minPrice = accompanymin;
                }
                if (maxPrice == minPrice) {
                    self.timePriceLabel.text = @"课时单价（单位：元/小时，价格无法修改）";
                    
                    self.priceTextField.enabled = NO;
                    self.pricePencilBtn.hidden = YES;
                }else{
                    self.timePriceLabel.text = [NSString stringWithFormat:@"课时单价（单位：元/小时，价格区间：%@元～%@元）",minPrice,maxPrice];
                    self.priceTextField.enabled = YES;
                    self.pricePencilBtn.hidden = NO;
                }
                if ([self.priceTextField.text intValue]==0) {
                    //价格
                    NSString *price = [self.timeDic[@"price"] description];
                    price = [CommonUtil isEmpty:price]?@"":price;
                    price = price;//[NSString stringWithFormat:@"%d", [price floatValue]];
                    
                    self.priceTextField.enabled = YES;
                    if ([self.subjectId intValue]==1) {//1:科目二 2：科目三 3：考场训练 4：陪驾
                        maxPrice = subject2max;
                        minPrice = subject2min;
                    }else if ([self.subjectId intValue]==2){
                        maxPrice = subject3max;
                        minPrice = subject3min;
                    }
                    if (maxPrice == minPrice) {
                        self.timePriceLabel.text = @"课时单价（单位：元/小时，价格无法修改）";
                        
                        self.pricePencilBtn.hidden = YES;
                        self.priceTextField.enabled = NO;
                    }else{
                        self.timePriceLabel.text = [NSString stringWithFormat:@"课时单价（单位：元/小时，价格区间：%@元～%@元）",minPrice,maxPrice];
                        
                        self.priceTextField.enabled = YES;
                        self.pricePencilBtn.hidden = NO;
                    }
                    self.priceTextField.enabled = NO;
                    [self.priceTextField becomeFirstResponder];
                }
            }
            
        }
        [self.selectView removeFromSuperview];
        self.comfirmBtn.selected = YES;
        self.selectPickerTag = @"0";
        [self.selectView2 removeFromSuperview];
        if ([self.priceTextField.text intValue] > [maxPrice intValue]) {
            
        }else if ([self.priceTextField.text intValue] < [minPrice intValue]){
            
        }
        if ([self.carRent.text intValue] > [hirecarmax intValue]) {
            self.carRent.text = hirecarmax;
        }else if ([self.carRent.text intValue] < [hirecarmin intValue]){
            self.carRent.text = hirecarmin;
        }
    }
}

- (IBAction)clickForConfirm:(id)sender {
    if (self.comfirmBtn.selected) {
        [self checkOpenClass];
    }
}

- (void)checkOpenClass {
    
    
}
#pragma mark - 接口
//获取地址信息
- (void)getAddressData{
   }
//获取教学内容
- (void)getContentData{
   
}
//获取教练的价格区间
- (void)getCoachPriceRange{
   
}
//提交修改信息
- (void)comfirmMsg{
    NSString *price = [self.priceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rentPrice = [self.carRent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *state = [self.timeDic[@"state"] description];
    NSString *subject = [self.contentTextField.text description];
    NSString *addressdetail = [self.addressTextField.text description];
    if ([CommonUtil isEmpty:state]) {
        state = @"";
    }
    NSString *cancelstate = [self.timeDic[@"cancelstate"] description];
    if ([CommonUtil isEmpty:cancelstate]) {
        cancelstate = @"";
    }
    NSArray *timeArray = [self.time componentsSeparatedByString:@"、"];
    
    NSMutableArray *msgArray = [NSMutableArray array];
    for (NSString *str in timeArray) {
        NSDate *strDate = [CommonUtil getDateForString:str format:@"HH:00"];
        NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[hourStr description] forKey:@"hour"];
        [dic setObject:[state description] forKey:@"state"];
        [dic setObject:[cancelstate description] forKey:@"cancelstate"];
        [dic setObject:[price description] forKey:@"price"];
        if (!self.carRent.hidden) {
            [dic setObject:rentPrice forKey:@"cuseraddtionalprice"];
            [dic setObject:rentPrice forKeyedSubscript:@"addtionalprice"];
        }else{
            [dic setObject:@"0" forKey:@"cuseraddtionalprice"];
            [dic setObject:@"0" forKeyedSubscript:@"addtionalprice"];
        }
        [dic setObject:@"1" forKey:@"isrest"];
        [dic setObject:[self.addressId description] forKey:@"addressid"];
        [dic setObject:[self.subjectId description] forKey:@"subjectid"];
        [msgArray addObject:dic];
    }
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"正在保存..."];
    
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:self.timeDic];
    [mutableDic setObject:price forKey:@"price"];
    if (self.experienceClass.selected) {
        NSString *isfreecourse = @"1";
        [mutableDic setObject:isfreecourse forKey:@"isfreecourse"];
    }else{
        NSString *isfreecourse = @"0";
        [mutableDic setObject:isfreecourse forKey:@"isfreecourse"];
    }
    [mutableDic setObject:[self.subjectId description] forKey:@"subjectid"];
    [mutableDic setObject:subject forKey:@"subject"];
    [mutableDic setObject:[self.addressId description] forKey:@"addressid"];
    [mutableDic setObject:addressdetail forKey:@"addressdetail"];
    self.timeDic = mutableDic;
    
    NSMutableArray *testArray = [NSMutableArray arrayWithArray:self.allDayArray];
    for (int i=0; i<testArray.count; i++) {
        NSDictionary *timeDic = testArray[i];
        NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
        NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
        
        for (int j=0; j<timeArray.count; j++) {
            NSMutableDictionary *dic2 = [NSMutableDictionary dictionaryWithDictionary:mutableDic];
            if (!self.carRent.hidden) {
                [dic2 setObject:rentPrice forKey:@"cuseraddtionalprice"];
                [dic2 setObject:rentPrice forKeyedSubscript:@"addtionalprice"];
            }
            if ([timeArray[j] isEqualToString:str]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:mutableDic];
                [dic setObject:[timeDic[@"hour"] description] forKey:@"hour"];
                [testArray replaceObjectAtIndex:i withObject:dic];
            }
        }
    }
    
    self.allDayArray = testArray;
    
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

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
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
        [self.carRent resignFirstResponder];
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *rentPrice = [self.carRent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!self.carRent.hidden) {
            NSMutableArray *mutableArray1 = [NSMutableArray arrayWithArray:self.allDayArray];
            for (int i=0; i<self.allDayArray.count; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.allDayArray[i]];
                [dic setValue:rentPrice forKey:@"addtionalprice"];
                [dic setValue:rentPrice forKey:@"cuseraddtionalprice"];
                [mutableArray1 replaceObjectAtIndex:i withObject:dic];
            }
            self.allDayArray  = mutableArray1;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeDaySchedule" object:array];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


@end
