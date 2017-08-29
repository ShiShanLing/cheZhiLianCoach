//
//  UserInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MyInfoCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LoginViewController.h"

@interface UserInfoViewController ()<UITextFieldDelegate> {
    CGFloat _y;
    int _rows;
    CGFloat _bottom;
    CGPoint _oldOffset;
    CGFloat _keyboardTop;
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (nonatomic, strong) NSArray *testInfo;
- (IBAction)clickForSave:(id)sender;
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rows = 2;
    [self.saveBtn setEnabled:NO];
    self.saveBtn.alpha = 0.4;
    self.cells = [[NSMutableArray alloc] init];
    [self settingInfo];
    [self addInfoCell];
    [self loadInfo];
    
    // 防止键盘遮挡输入框
//    [self registerForKeyboardNotifications];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}

-(void)backupgroupTap:(id)sender{
    for (int i =0; i < _rows; i++) {
        MyInfoCell *cell = _cells[i];
        [cell.contentField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 页面数据
- (void)settingInfo {
    _titles = [NSArray arrayWithObjects:@"姓名", @"手机号码", nil];
    _hints = [NSArray arrayWithObjects:@"请输入姓名", @"请输入手机号码", nil];
    _testInfo = [NSArray arrayWithObjects:@"李文豪", @"186 9822 3336", nil];
}

// 添加cell
- (void)addInfoCell {
    for (int i = 0; i < _rows; i++) {
        MyInfoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MyInfoCell" owner:self options:nil] lastObject];
        _y = 85 * i;
        cell.frame = CGRectMake(0, _y, kScreen_widht, 85);
        cell.contentField.delegate = self;
        cell.contentField.tag = 100 + i;
        [cell.contentField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        cell.editBtn.tag = 200 + i;
        [self.mainScrollView addSubview:cell];
        [_cells addObject:cell];
    }
}

- (void)loadInfo {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    for (int i = 0; i < _rows; i++) {
        MyInfoCell *curCell = _cells[i];
        curCell.titleLabel.text = _titles[i];
        curCell.contentField.placeholder = _hints[i];
        if (i == 0) {
            //姓名
            NSString *name = userInfo[@"realname"];
            if ([CommonUtil isEmpty:name]) {
                name = @"";
            }
            curCell.contentField.text = name;
        }else if (i == 1){
            //手机号码
            NSString *phone = [userInfo[@"phone"] description];
            if ([CommonUtil isEmpty:phone]) {
                phone = @"";
            }
            curCell.contentField.text = phone;
            [self formatPhoneNumber:curCell.contentField];//格式化电话格式
        }
        
        [curCell.editBtn addTarget:self action:@selector(clickForEditting:) forControlEvents:UIControlEventTouchUpInside];
        
        // 手机号码
        if (i == 1) {
            curCell.contentField.keyboardType = UIKeyboardTypeNumberPad;
            [curCell.contentField addTarget:self action:@selector(formatPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
        }
    }
}

#pragma mark - 输入框代理
// 信息被改变
- (void)textFieldDidChange:(UITextField *)sender {
    long index = sender.tag - 100;
    MyInfoCell *cell = _cells[index];
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    [cell.editImageView setImage:image];
    
    if (self.saveBtn.enabled == NO) {
        self.saveBtn.enabled = YES;
        self.saveBtn.alpha = 1;
    }
}

// 手机号码3-4-4格式
- (void)formatPhoneNumber:(UITextField*)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
//    NSLog(@"targetCursorPosition:%li", (long)targetCursorPosition);
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

#pragma mark - 键盘遮挡输入框处理
// 监听键盘弹出通知
//- (void) registerForKeyboardNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
//}

//- (void)unregNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//}

// 开始编辑输入框，获得输入框底部在屏幕上的绝对位置
-(void)textFieldDidBeginEditing:(UITextField *)textField {
//    [self registerForKeyboardNotifications];
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[textField convertRect: textField.bounds toView:window]; // 在屏幕上的坐标
    _bottom = rect.origin.y + rect.size.height; // 获得输入框底部在屏幕上的绝对位置
}

// 键盘弹出，获得键盘高度，计算界面需要偏移的距离
//- (void) keyboardWillShow:(NSNotification *) notification {
//    _oldOffset = self.mainScrollView.contentOffset;
//    [self unregNotification];
//    NSDictionary *userInfo = [notification userInfo];
//    
//    // Get the origin of the keyboard when it's displayed.
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
//    CGRect keyboardRect = [aValue CGRectValue];
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
//    _keyboardTop = keyboardRect.origin.y;
//    
//    // 计算出需要偏移的距离offset，即输入框bottom与键盘top的距离
//    float offset = _bottom - _keyboardTop;
//    if(offset > 0) { // offset为正，说明输入框被键盘遮挡
//        CGSize size = self.mainScrollView.contentSize;
//        size.height += _keyboardTop;
//        self.mainScrollView.contentSize = size;
//        
//        
//        NSTimeInterval animationDuration = 0.3f;
//        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//        [UIView setAnimationDuration:animationDuration];
//        offset += 75;
//        self.mainScrollView.contentOffset = CGPointMake(0, _oldOffset.y + offset);
//        [UIView commitAnimations];
//        
//    }
//}
//
////键盘隐藏，将视图恢复到原始状态
//- (void) keyboardWillHidden:(NSNotification *) notif {
//    self.mainScrollView.contentOffset = _oldOffset;
//    
//    CGSize size = self.mainScrollView.contentSize;
//    size.height += _keyboardTop;
//    self.mainScrollView.contentSize = size;
//}

#pragma mark - 按钮方法
- (IBAction)clickForSave:(id)sender {
   
    if (self.cells.count <= 1) {
        return;
    }
    
    MyInfoCell *curCell = _cells[0];
    NSString *name = [curCell.contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    MyInfoCell *curCell2 = _cells[1];
    NSString *phone = [curCell2.contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:name]) {
        [self makeToast:@"请输入真实姓名"];
        [curCell.contentField becomeFirstResponder];
        return;
    }
    
    if ([CommonUtil isEmpty:phone]) {
        [self makeToast:@"请输入手机号码"];
        [curCell2.contentField becomeFirstResponder];
        return;
    }
    
    [self changeUserMsg];
    
}

- (void)clickForEditting:(UIButton *)sender {
    long index = sender.tag - 200;
    MyInfoCell *cell = _cells[index];
    [cell.contentField becomeFirstResponder];
}


#pragma mark - 接口
- (void)changeUserMsg{
    if (self.cells.count <= 1) {
        return;
    }
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    MyInfoCell *curCell = _cells[0];
    NSString *name = [curCell.contentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    curCell = _cells[1];
    NSString *phone = curCell.contentField.text;
   
    [DejalBezelActivityView activityViewForView:self.view];
}

- (void) backLogin {
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
