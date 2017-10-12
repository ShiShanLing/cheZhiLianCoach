//
//  MyInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyInfoViewController.h"
#import "UserInfoViewController.h"
#import "CoachInfoViewController.h"
#import "MyDetailInfoViewController.h"
#import "ChangePwdViewController.h"
#import "TQStarRatingView.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MyInfoCell.h"
#import "SetTeachViewController.h"
#import "SetAddrViewController.h"
#import "CZPhotoPickerController.h"
#import "LoginViewController.h"
#import "DatePickerViewController.h"
#import "CoachInfoTextFieldViewController.h"
@interface MyInfoViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate,DatePickerViewControllerDelegate> {
    CGRect _oldFrame;
    CGFloat _y;
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
    NSInteger selectRow;
    NSString* pricestr;
}

@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
//@property (strong, nonatomic) IBOutlet UIView *pwdProveView;
//@property (strong, nonatomic) IBOutlet UITextField *pwdField;
//@property (strong, nonatomic) IBOutlet UIView *commitView;
//@property (strong, nonatomic) IBOutlet UIView *starView;
//@property (strong, nonatomic) IBOutlet UIView *contentView;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;

//@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//累计时长
//@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;//综合评分
//@property (strong, nonatomic) IBOutlet UIView *msgView;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *msgHeightContraint;

//选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView; // 选择器
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) UIImage *changeLogoImage;//修改后的头像

//参数
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (nonatomic, strong) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableArray *selectArray;
@property (copy, nonatomic) NSString *schoolCarID;
@property (strong, nonatomic) NSMutableDictionary *msgDic;//资料

@property (copy, nonatomic) NSString *userState;
@property (copy, nonatomic) NSString *birthdayChange;
- (IBAction)clickToCoachInfoView:(id)sender;    // 教练资格信息
//修改上车地址
- (IBAction)clickForChangeAddress:(id)sender;

//修改头像
- (IBAction)clickForChangeAvatar:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *remindLabel;
@property (strong, nonatomic) IBOutlet UIView *remindBackView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

//@property (strong, nonatomic) IBOutlet UILabel *defaultPriceLabel;
//@property (strong, nonatomic) IBOutlet UILabel *defaultSubjectLabel;
/**
 *地址
 */
@property (strong, nonatomic) IBOutlet UILabel *defaultAddressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *portraitImage;//头像
@property (strong, nonatomic) IBOutlet UILabel *realNameLabel;
/**
 *性别
 */
@property (strong, nonatomic) IBOutlet UILabel *sexLabel;//
@property (strong, nonatomic) IBOutlet UILabel *coachInfoState;//教学信息状态
@property (strong, nonatomic) IBOutlet UILabel *birthdayLabel;
/**
 *驾培教龄
 */
@property (strong, nonatomic) IBOutlet UILabel *trainTimeLabel;//
@property (strong, nonatomic) IBOutlet UILabel *selfEvaluationLabel;//个人评价

@property (strong, nonatomic) IBOutlet UIButton *nameButton;
@property (strong, nonatomic) IBOutlet UIButton *trainTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *selfEvaluationButton;

@property (strong, nonatomic) IBOutlet UIView *alertPhotoView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cells = [NSMutableArray array];
    self.selectArray = [NSMutableArray array];
    self.msgDic = [NSMutableDictionary dictionary];
    
    self.pickerView.showsSelectionIndicator = NO;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    self.portraitImage.layer.cornerRadius = self.portraitImage.bounds.size.width/2;
    self.portraitImage.layer.masksToBounds = YES;
    self.alertDetailView.layer.cornerRadius = 4;
    self.alertDetailView.layer.masksToBounds = YES;
    self.nameButton.tag = 1;
    self.trainTimeButton.tag = 2;
    self.selfEvaluationButton.tag = 3;
    [self registerForKeyboardNotifications];
    //  添加姓名，手机号码，所属驾校，性别
    //    [self addOtherView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    self.remindBackView.hidden = YES;
    self.topConstraint.constant = 0 ;
    self.defaultAddressLabel.text = @"未设置";
    //姓名
    NSString *realname = [userInfo[@"realname"] description];
    self.realNameLabel.text = realname;
    self.sexLabel.text = @"请选择";
    self.birthdayLabel.text = @"请选择";
    self.trainTimeLabel.text = @"请选择";
    self.selfEvaluationLabel.text = @"一句话评价自己";
  
    [self.portraitImage sd_setImageWithURL:[NSURL URLWithString:nil] placeholderImage:[UIImage imageNamed:@"ic_head_gray"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      
    }];
    [self getCoachDetail];
}

- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 键盘遮挡输入框处理
// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    //    if (!self.commitView.superview) {
    //        return;
    //    }
    //    _oldFrame = self.commitView.frame;
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    //    CGFloat keyboardTop = keyboardRect.origin.y;
    
    //    CGFloat offset = CGRectGetMaxY(self.commitView.frame) - keyboardTop + 10;
    
    NSTimeInterval animationDuration = 0.3f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    //    self.commitView.frame = CGRectMake(_oldFrame.origin.x, _oldFrame.origin.y - offset, _oldFrame.size.width, _oldFrame.size.height);
    [UIView commitAnimations];
    
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    //    if (!self.commitView.superview) {
    //        return;
    //    }
    //    self.commitView.frame = _oldFrame;
}

// 信息被改变
- (void)textFieldDidChange:(UITextField *)sender {
    long index = sender.tag - 100;
    MyInfoCell *cell = _cells[index];
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    [cell.editImageView setImage:image];
    
    //    if (self.saveBtn.enabled == NO) {
    //        self.saveBtn.enabled = YES;
    //        self.saveBtn.alpha = 1;
    //    }
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
// 数据
- (void)initSexData {
    self.pickerView.tag = 1;
    self.selectArray = [NSMutableArray arrayWithObjects:@"男", @"女",@"默认", nil];
}
// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    // 性别选择器
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 45)];
    myView.textAlignment = NSTextAlignmentCenter;
    
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    
    myView.textColor = MColor(161, 161, 161);
    
    myView.backgroundColor = [UIColor clearColor];
    
    if (selectRow == row){
        myView.textColor = MColor(34, 192, 100);
    }
    
    if(self.pickerView.tag == 1){
        myView.text = [self.selectArray objectAtIndex:row];
    }else{
        NSDictionary *dic = [self.selectArray objectAtIndex:row];
        myView.text = dic[@"name"];
    }
    
    return myView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectRow = row;
    [pickerView reloadComponent:0];
    
}

#pragma mark - 按钮方法
- (IBAction)clickToUserInfoView:(id)sender {
    NSLog(@"填写教练信息");
    CoachInfoTextFieldViewController *nextViewController = [[CoachInfoTextFieldViewController alloc] initWithNibName:@"CoachInfoTextFieldViewController" bundle:nil];
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 1) {
        nextViewController.viewType = @"1";
        nextViewController.textString = self.realNameLabel.text;
    }else if (button.tag == 2){
        nextViewController.viewType = @"2";
        nextViewController.textString = [self.trainTimeLabel.text substringWithRange:NSMakeRange(0, self.trainTimeLabel.text.length-1)];
    }else if (button.tag == 3){
        nextViewController.viewType = @"3";
        if ([self.selfEvaluationLabel.text isEqualToString:@"一句话评价自己"]) {
            nextViewController.textString = @"";
        }else{
            nextViewController.textString = self.selfEvaluationLabel.text;
        }
    }
    
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)clickToCoachInfoView:(id)sender {
    NSLog(@"教练资格信息");
    CoachInfoViewController *targetViewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
    targetViewController.superViewNum = @"1";
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToMyDetailInfoView:(id)sender {
    NSLog(@"个人资料");
    MyDetailInfoViewController *targetViewController = [[MyDetailInfoViewController alloc] initWithNibName:@"MyDetailInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
// 性别
- (IBAction)selectSex:(long)index {
    
    if ([self.sexLabel.text isEqualToString:@"请选择"]) {
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        selectRow = 0;
    }else if ([self.sexLabel.text isEqualToString:@"男"]){
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        selectRow = 0;
    }else if ([self.sexLabel.text isEqualToString:@"女"]){
        [self.pickerView selectRow:1 inComponent:0 animated:YES];
        selectRow = 1;
    }
    [self initSexData];
    [self.pickerView reloadAllComponents];
    self.selectView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.selectView];
    if ([self.sexLabel.text isEqualToString:@"请选择"]) {
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        selectRow = 0;
    }else if ([self.sexLabel.text isEqualToString:@"男"]){
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        selectRow = 0;
    }else if ([self.sexLabel.text isEqualToString:@"女"]){
        [self.pickerView selectRow:1 inComponent:0 animated:YES];
        selectRow = 1;
    }
}

#pragma mark - DatePickerViewControllerDelegate
- (void)datePicker:(DatePickerViewController *)viewController selectedDate:(NSDate *)selectedDate{
    
    NSString *time = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
    self.birthdayLabel.text = time;
    [self updateUserDirthday];
    self.birthdayChange = @"1";
}

//选择生日
- (IBAction)clickForSelectBirthDay:(UIButton *)sender{
    //日期
    DatePickerViewController *viewController = [[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    viewController.dicTag = 99;
    viewController.delegate = self;
    if ([self.birthdayLabel.text isEqualToString:@"请选择"]) {
        NSString *time = @"";
        viewController.pushString = time;
    }else{
        NSString *time = self.birthdayLabel.text;
        viewController.pushString = time;
    }
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
// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}
// 完成性别选择
- (IBAction)clickForSexDone:(id)sender {
    [self makeToast:@"功能未开通"];
}
//提交
- (IBAction)clickForCommit:(id)sender {
    MyInfoCell *cell = _cells[1];
    NSString *str1 = cell.contentField.text;
    [self makeToast:@"功能未开通"];
    //    [self updateUserData];
}
#pragma mark - 接口
// 获取所有驾校信息
- (void)getCarSchool{
    [DejalBezelActivityView activityViewForView:self.view];
}

//提交个人资料
- (void)updateUserData:(NSString *)key and:(id)value{
    [self makeToast:@"功能未开通"];
}

//提交个人资料
- (void)updateUserDirthday{
    [self makeToast:@"功能未开通"];
}


- (void)getCoachDetail {
    self.coachInfoState.text = @"【资格审核已提交】";
    self.coachInfoState.textColor = MColor(180, 180, 180);
    self.userState = @"1";
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (IBAction)clickForChangeAddress:(id)sender {
    SetAddrViewController *targetViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickForChangeAvatar:(id)sender {
    self.alertPhotoView.frame = self.view.frame;
    
    [self.view addSubview:self.alertPhotoView];
    
}
//关闭弹框
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertPhotoView removeFromSuperview];
}

- (IBAction)clickForCamera:(UIButton *)sender {
    
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.allowsEditing = NO;
    if (sender.tag == 1 && [CZPhotoPickerController canTakePhoto]) {
        //拍照
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
}
#pragma mark - 拍照
- (CZPhotoPickerController *)photoController {
    typeof(self) weakSelf = self;
    
    return [[CZPhotoPickerController alloc] initWithPresentingViewController:self withCompletionBlock:^(UIImagePickerController *imagePickerController, NSDictionary *imageInfoDict) {
        
        [weakSelf.pickPhotoController dismissAnimated:YES];
        weakSelf.pickPhotoController = nil;
        
        if (imagePickerController == nil || imageInfoDict == nil) {
            return;
        }
        
        UIImage *image = imageInfoDict[UIImagePickerControllerEditedImage];
        if(!image)
            image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            image = [CommonUtil fixOrientation:image];
            [self uploadLogo:image];
        }
        
        [self.alertPhotoView removeFromSuperview];
    }];
}

//上传头像
- (void)uploadLogo:(UIImage *)image{
    [self respondsToSelector:@selector(indeterminateExample)];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/floor/api/fileUpload", kURL_SHY];
    //carownerapi/ save_carowner
    AFHTTPSessionManager * managerOne = [AFHTTPSessionManager manager];
    
    managerOne.requestSerializer.HTTPShouldHandleCookies = YES;
    
    managerOne.requestSerializer  = [AFHTTPRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    managerOne.responseSerializer = [AFJSONResponseSerializer serializer];
    [managerOne.requestSerializer setTimeoutInterval:20.0];
    
    //把版本号信息传导请求头中
    [managerOne.requestSerializer setValue:[NSString stringWithFormat:@"iOS-%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"MM-Version"];
    
    [managerOne.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
    managerOne.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];
    __weak MyInfoViewController *VC  = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    [managerOne POST:URL_Str parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSData *picData = UIImageJPEGRepresentation(image, 0.5);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.png", @"id_card_front"];
        [formData appendPartWithFileData:picData name:[NSString stringWithFormat:@"file"]
                                fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            NSArray *dataArray = responseObject[@"data"];
            NSDictionary *dataDic =dataArray[0];
            NSString *image_URL = dataDic[@"URL"];
            NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/setAvatar", kURL_SHY];
            NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
            URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;;
            URL_Dic[@"avatar"] = image_URL;
            [managerOne POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"uploadProgress%@", uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"responseObject%@", responseObject);
                NSString *resultStr1 = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
                if ([resultStr1 isEqualToString:@"1"]) {
                    [VC showAlert:@"更改成功" time:1.2];
                }else {
                    [VC showAlert:responseObject[@"msg"] time:1.2];
                    
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [VC showAlert:@"更改头像网络出错!" time:1.2];
                NSLog(@"error%@", error);
            }];
        }else{
            [VC showAlert:@"图片上传失败" time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error%@", error);
        [VC showAlert:@"上传图片网络出错!" time:1.2];
        
    }];
}

- (void)savePrice {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    [DejalBezelActivityView activityViewForView:self.view];
}

@end
