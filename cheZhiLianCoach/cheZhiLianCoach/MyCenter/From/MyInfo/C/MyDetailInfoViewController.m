//
//  MyDetailInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyDetailInfoViewController.h"
#import "MyInfoCell.h"
#import "DatePickerViewController.h"
#import "LocationViewController.h"
#import "MyInfoTextViewCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LoginViewController.h"
#import "XBProvince.h"

@interface MyDetailInfoViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DatePickerViewControllerDelegate, LocationViewControllerDelegate, UITextViewDelegate> {
    CGFloat _y;
    CGFloat _bottom;
    CGPoint _oldOffset;
    CGFloat _keyboardTop;
    int _rows;
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
    UIColor *strColor;
    NSInteger selectRow;
    
    NSString *isChangeCity;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (nonatomic, strong) IBOutlet UIPickerView *sexPicker; // 选择器
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (strong, nonatomic) NSMutableArray *sexViewArray;
@property (strong, nonatomic) NSDictionary *stateZips;//省市
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *provinceArray;

// 选择器数组
@property (strong, nonatomic) NSArray *sexArray; // 性别
@property (strong, nonatomic) NSMutableDictionary *msgDic;//资料

@property (assign, nonatomic) NSInteger btnTag;
@property (strong, nonatomic) NSMutableArray *carSchoolArray;
@property (copy, nonatomic) NSString *schoolCarID;

// 省市区
@property (strong, nonatomic) XBProvince *selectProvince;
@property (strong, nonatomic) XBCity *selectCity;
@property (strong, nonatomic) XBArea *selectArea;

- (IBAction)clickForCommit:(id)sender;
- (IBAction)clickForCancelSelect:(id)sender;
- (IBAction)clickForSexDone:(id)sender;

@end

@implementation MyDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _carSchoolArray = [[NSMutableArray alloc] init];
    isChangeCity = @"0";
//    NSDictionary *dic1 = [NSDictionary dictionaryWithObject:@"飞翔驾校" forKey:@"name"];
//    NSDictionary *dic2 = [NSDictionary dictionaryWithObject:@"蓝天驾校" forKey:@"name"];
//    NSDictionary *dic3 = [NSDictionary dictionaryWithObject:@"平安驾校" forKey:@"name"];
//    NSDictionary *dic4 = [NSDictionary dictionaryWithObject:@"其它" forKey:@"name"];
//    _carSchoolArray = [NSMutableArray arrayWithObjects:dic1,dic2,dic3,dic4, nil];
    
    // 初始化
    _rows = 7;
    [self.commitBtn setEnabled:NO];
    self.commitBtn.alpha = 0.4;
    self.cells = [[NSMutableArray alloc] init];
    strColor = MColor(34, 192, 100);
    self.sexPicker.showsSelectionIndicator = NO;
    self.sexPicker.delegate = self;
    self.sexPicker.dataSource = self;
    self.provinceArray = [NSArray array];
    self.cityArray = [NSArray array];
    self.stateZips = [NSDictionary dictionary];
    self.msgDic = [NSMutableDictionary dictionary];
    
    [self settingInfo];
    [self addInfoCell];
    [self loadInfo];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];

}

-(void)backupgroupTap:(id)sender{
    for (int i =0; i < _rows; i++) {
        if (i == 6){
            MyInfoTextViewCell *cell = _cells[i];
            [cell.contentTextView resignFirstResponder];
        }else{
            MyInfoCell *cell = _cells[i];
            [cell.contentField resignFirstResponder];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 防止键盘遮挡输入框
    //[self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

// 页面数据
- (void)settingInfo {
    _titles = [NSArray arrayWithObjects:@"出生年月", @"所在城市", @"联系地址", @"紧急联系人", @"紧急联系电话", @"教龄", @"自我评价", nil];
    _hints = [NSArray arrayWithObjects:@"请选择出生年月", @"请选择所在城市", @"请输入联系地址", @"请输入紧急联系人姓名", @"请输入紧急联系电话", @"请输入教龄", @"请输入自我评价", nil];
}

// 添加cell
- (void)addInfoCell {
    //赋值
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    CGFloat viewHeight = 0;
    for (int i = 0; i < _rows; i++) {
       
        NSString *str = @"";
        if (i == 0){
            //出生年月
            str = userInfo[@"birthday"];
        }else if (i == 1){
            //所在城市
            str = userInfo[@"locationname"];
        }else if (i == 2){
            //联系地址
            str = userInfo[@"address"];
        }else if (i == 3){
            //紧急联系人
            str = userInfo[@"urgent_person"];
        }else if (i == 4){
            //紧急联系电话
            str = userInfo[@"urgent_phone"];
        }else if (i == 5){
            //教龄
            str = [userInfo[@"years"] description];
        }else if (i == 6){
            //自我评价
            str = [userInfo[@"selfeval"] description];
        }
        
        if ([CommonUtil isEmpty:str]) {
            str = @"";
        }
        
        _y = 85 * i;
        if (i == 6) {
            //个人评价
            MyInfoTextViewCell *textViewCell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoTextViewCell" owner:self options:nil] lastObject];
            textViewCell.frame = CGRectMake(0, _y, kScreen_widht, 106);
            textViewCell.contentTextView.delegate = self;
            textViewCell.editBtn.tag = 200 + i;
            [self.mainScrollView addSubview:textViewCell];
            [self.cells addObject:textViewCell];
            textViewCell.contentTextView.text = str;
            
            CGSize size = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth(textViewCell.contentTextView.frame), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:textViewCell.contentTextView.font } context:nil].size;
            CGFloat height = CGRectGetHeight(textViewCell.contentTextView.frame);
            if (size.height + 20 > height) {
                height = ceil(size.height) + 20;//20为误差
            }
            
            textViewCell.frame = CGRectMake(0, _y, kScreen_widht, 106 - CGRectGetHeight(textViewCell.contentTextView.frame) + height);
            
            //计算高度
            viewHeight = CGRectGetHeight(textViewCell.frame) + textViewCell.frame.origin.y;
            
        }else{
            
            MyInfoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoCell" owner:self options:nil] lastObject];
            
            cell.frame = CGRectMake(0, _y, kScreen_widht, 85);
            cell.contentField.delegate = self;
            cell.contentField.tag = 100 + i;
            [cell.contentField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            cell.editBtn.tag = 200 + i;
            cell.selectBtn.tag = 300 + i;
            [self.mainScrollView addSubview:cell];
            [_cells addObject:cell];
            cell.contentField.text = str;
            
            //计算高度
            viewHeight = CGRectGetHeight(cell.frame) + cell.frame.origin.y;
        }
        
    }
    self.mainScrollView.contentSize = CGSizeMake(0, viewHeight);
}

// 加载数据到cell
- (void)loadInfo {
    for (int i = 0; i < _rows; i++) {
        
        if (i == 6) {
            //个人评价
            MyInfoTextViewCell *curCell = _cells[i];
            curCell.titleLabel.text = _titles[i];
            curCell.contentTextView.placeholder = _hints[i];
            [curCell.editBtn addTarget:self action:@selector(clickForEditting:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            
            MyInfoCell *curCell = _cells[i];
            curCell.titleLabel.text = _titles[i];
            curCell.contentField.placeholder = _hints[i];
            [curCell.editBtn addTarget:self action:@selector(clickForEditting:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) { // 出生年月
                curCell.selectBtn.hidden = NO;
                [curCell.selectBtn addTarget:self action:@selector(clickForSelectBirthDay:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if (i == 1) { // 所在城市
                curCell.selectBtn.hidden = NO;
                [curCell.selectBtn addTarget:self action:@selector(clickForSelectCity:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if (i == 4) { // 电话号码
                curCell.contentField.keyboardType = UIKeyboardTypeNumberPad;
                [curCell.contentField addTarget:self action:@selector(formatPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
            }
            
            if (i == 5) { // 教龄
                curCell.contentField.keyboardType = UIKeyboardTypeNumberPad;
            }
        }
    }
}

// 信息被改变
- (void)textFieldDidChange:(UITextField *)sender {
    long index = sender.tag - 100;
    MyInfoCell *cell = _cells[index];
    if ([cell isKindOfClass:[MyInfoCell class]]) {
        UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
        [cell.editImageView setImage:image];
        
        if (self.commitBtn.enabled == NO) {
            self.commitBtn.enabled = YES;
            self.commitBtn.alpha = 1;
        }
    }
    
}

// 手机号码3-4-4格式
- (void)formatPhoneNumber:(UITextField*)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    NSLog(@"targetCursorPosition:%li", (long)targetCursorPosition);
    // nStr表示不带空格的号码
    NSString* nStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* preTxt = [previousTextFieldContent stringByReplacingOccurrencesOfString:@" "
                                                                           withString:@""];
    
    char editFlag = 0;// 正在执行删除操作时为0，否则为1
    
    if (nStr.length <= preTxt.length) {
        editFlag = 0;
    }
    else {
        editFlag = 1;
    }
    
    // textField设置text
    if (nStr.length > 11)
    {
        textField.text = previousTextFieldContent;
        textField.selectedTextRange = previousSelection;
        return;
    }
    
    // 空格
    NSString* spaceStr = @" ";
    
    NSMutableString* mStrTemp = [NSMutableString new];
    int spaceCount = 0;
    if (nStr.length < 3 && nStr.length > -1)
    {
        spaceCount = 0;
    }else if (nStr.length < 7 && nStr.length >2)
    {
        spaceCount = 1;
        
    }else if (nStr.length < 12 && nStr.length > 6)
    {
        spaceCount = 2;
    }
    
    for (int i = 0; i < spaceCount; i++)
    {
        if (i == 0) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(0, 3)], spaceStr];
        }else if (i == 1)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(3, 4)], spaceStr];
        }else if (i == 2)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
        }
    }
    
    if (nStr.length == 11)
    {
        [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
    }
    
    if (nStr.length < 4)
    {
        [mStrTemp appendString:[nStr substringWithRange:NSMakeRange(nStr.length-nStr.length % 3,
                                                                    nStr.length % 3)]];
    }else if(nStr.length > 3)
    {
        NSString *str = [nStr substringFromIndex:3];
        [mStrTemp appendString:[str substringWithRange:NSMakeRange(str.length-str.length % 4,
                                                                   str.length % 4)]];
        if (nStr.length == 11)
        {
            [mStrTemp deleteCharactersInRange:NSMakeRange(13, 1)];
        }
    }
//    NSLog(@"=======mstrTemp=%@",mStrTemp);
    
    textField.text = mStrTemp;
    // textField设置selectedTextRange
    NSUInteger curTargetCursorPosition = targetCursorPosition;// 当前光标的偏移位置
    if (editFlag == 0)
    {
        //删除
        if (targetCursorPosition == 9 || targetCursorPosition == 4)
        {
            curTargetCursorPosition = targetCursorPosition - 1;
        }
    }
    else {
        //添加
        if (nStr.length == 8 || nStr.length == 3)
        {
            curTargetCursorPosition = targetCursorPosition + 1;
        }
    }
    
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                              offset:curTargetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition
                                                         toPosition :targetPosition]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    return YES;
}

#pragma mark - textViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    if (_cells.count > 6) {
        MyInfoTextViewCell *cell = _cells[6];
        if ([cell isKindOfClass:[MyInfoTextViewCell class]]) {
            cell.editBtn.selected = YES;
            
            if (self.commitBtn.enabled == NO) {
                self.commitBtn.enabled = YES;
                self.commitBtn.alpha = 1;
            }
        }
    }
}

#pragma mark - 键盘遮挡输入框处理
// 开始编辑输入框，获得输入框底部在屏幕上的绝对位置
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[textField convertRect: textField.bounds toView:window]; // 在屏幕上的坐标
    _bottom = rect.origin.y + rect.size.height; // 获得输入框底部在屏幕上的绝对位置
//    _oldOffset = self.mainScrollView.contentOffset;
    return YES;
}

// 开始编辑输入框，获得输入框底部在屏幕上的绝对位置
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[textView convertRect:textView.bounds toView:window]; // 在屏幕上的坐标
    _bottom = rect.origin.y + rect.size.height; // 获得输入框底部在屏幕上的绝对位置
//    _oldOffset = self.mainScrollView.contentOffset;
    return YES;
}
#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component

{
    
    return 45.0;
    
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.sexPicker]) {
        return 1;
    }
    else {
        return 0;
    }
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.sexPicker]) {
        if(_btnTag == 0){
            return  _carSchoolArray.count;
        }else{
            return 2;
        }
        
    }
    else {
        return 0;//如果不是就返回0
    }
}

// 数据
- (void)initSexData {
    _sexArray = [NSArray arrayWithObjects:@"男", @"女", nil];
    _sexViewArray = [[NSMutableArray alloc] init];

}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    
    // 性别选择器
    if ([pickerView isEqual:self.sexPicker]) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 45)];
        
        myView.textAlignment = NSTextAlignmentCenter;
        if(_btnTag == 1){
            myView.text = [self.sexArray objectAtIndex:row];
        }else{
            NSDictionary *dic = [_carSchoolArray objectAtIndex:row];
            myView.text = dic[@"name"];
        }
        
        myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
        
        myView.textColor = MColor(161, 161, 161);
        
        myView.backgroundColor = [UIColor clearColor];
        
//        NSInteger selectRow = [self.sexPicker selectedRowInComponent:0];
        if (selectRow == row){
            myView.textColor = MColor(34, 192, 100);
        }
    }
    
    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectRow = row;
    [pickerView reloadComponent:0];
    
}

#pragma mark - DatePickerViewControllerDelegate
- (void)datePicker:(DatePickerViewController *)viewController selectedDate:(NSDate *)selectedDate{
    NSString *time = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
    
    if (_rows > 1) {
        MyInfoCell *curCell = _cells[0];
        curCell.contentField.text = time;
        
        //可以提交
        if (self.commitBtn.enabled == NO) {
            self.commitBtn.enabled = YES;
            self.commitBtn.alpha = 1;
        }
    }
    
}

#pragma mark - LocationViewControllerDelegate
- (void)location:(LocationViewController *)viewController selectDic:(NSDictionary *)selectDic{
    
    isChangeCity = @"1";
    
    self.selectProvince = selectDic[@"province"];
    self.selectCity = selectDic[@"city"];
    self.selectArea = selectDic[@"area"];
    
    NSString *addrStr = nil;
    NSString *areaStr = [self.selectArea.areaName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (self.selectProvince.isZxs) { // 直辖市
        addrStr = [NSString stringWithFormat:@"%@ - %@", self.selectProvince.provinceName, areaStr];
    } else {
        addrStr =  [NSString stringWithFormat:@"%@ - %@ - %@", self.selectProvince.provinceName, self.selectCity.cityName, areaStr];
    }
    
    if (_rows > 2) {
        MyInfoCell *curCell = _cells[1];
        curCell.contentField.text = addrStr;
        
        //可以提交
        if (self.commitBtn.enabled == NO) {
            self.commitBtn.enabled = YES;
            self.commitBtn.alpha = 1;
        }
    }
}

// 性别
- (void)selectSex:(long)index {
    [self initSexData];
    [self.sexPicker reloadAllComponents];
    self.selectView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.selectView];
}

#pragma mark - 按钮方法
- (IBAction)clickForCommit:(id)sender {
    [self updateUserData];
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

// 完成性别选择
- (IBAction)clickForSexDone:(id)sender {
    NSInteger row = [self.sexPicker selectedRowInComponent:0];
    if(_btnTag == 1){
        MyInfoCell *sexCell = _cells[1];
        sexCell.contentField.text = _sexArray[row];
    }else{
        MyInfoCell *carSchoolCell = _cells[0];
        if(row == (_carSchoolArray.count - 1)){
            carSchoolCell.selectBtn.hidden = YES;
            carSchoolCell.contentField.text = @"";
            carSchoolCell.contentField.placeholder = @"请输入您的所属驾校";
            _schoolCarID = @"";
        }else{
            carSchoolCell.selectBtn.hidden = NO;
            carSchoolCell.contentField.placeholder = @"";
            NSDictionary *dic = _carSchoolArray[row];
            carSchoolCell.contentField.text = dic[@"name"];
             _schoolCarID = dic[@"schoolid"];
        }

    }
    [self.selectView removeFromSuperview];
    
    //可以提交
    if (self.commitBtn.enabled == NO) {
        self.commitBtn.enabled = YES;
        self.commitBtn.alpha = 1;
    }
}

// 点击铅笔图标开始编辑
- (void)clickForEditting:(UIButton *)sender {
    long index = sender.tag - 200;
    if (index == 6) {
        MyInfoTextViewCell *cell = _cells[index];
        [cell.contentTextView becomeFirstResponder];
    }else{
        MyInfoCell *cell = _cells[index];
        [cell.contentField becomeFirstResponder];
    }
    
}

// 开启驾校选择器
- (void)clickForSelectSchool:(UIButton *)sender {
    [self getCarSchool]; // 获取所有驾校
    self.btnTag = 0;
}

// 开启选择器
- (void)clickForSelect:(UIButton *)sender {
    long index = sender.tag - 300;
    self.btnTag = 1;
    // 选择性别
    if (index == 1) {
        [self selectSex:index];
    }
}

//选择生日
- (void)clickForSelectBirthDay:(UIButton *)sender{
    //日期
    DatePickerViewController *viewController = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    viewController.dicTag = 99;
    viewController.delegate = self;
    UIViewController* controller = self.view.window.rootViewController;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        viewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }else{
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    [controller presentViewController:viewController animated:YES completion:^{
        viewController.view.superview.backgroundColor = [UIColor clearColor];
    }];
}

//选择城市
- (void)clickForSelectCity:(UIButton *)sender{
    //日期
    LocationViewController *viewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
    viewController.delegate = self;
    UIViewController* controller = self.view.window.rootViewController;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        viewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }else{
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    [controller presentViewController:viewController animated:YES completion:^{
        viewController.view.superview.backgroundColor = [UIColor clearColor];
    }];
}

#pragma mark - 接口

// 获取所有驾校信息
- (void)getCarSchool{
   
}

//提交个人资料
- (void)updateUserData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *coachId = userInfo[@"coachid"];
    
   
    
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
