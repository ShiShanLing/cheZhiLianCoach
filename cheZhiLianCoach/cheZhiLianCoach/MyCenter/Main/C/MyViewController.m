//
//  MyViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyViewController.h"
#import "MyEvaluationViewController.h"
#import "MyMessageViewController.h"
#import "MyInfoViewController.h"
#import "SetAddrViewController.h"
#import "SetAddrViewController.h"
#import "LoginViewController.h"
#import "SetViewController.h"
#import "CoachInfoViewController.h"
#import "CZPhotoPickerController.h"
#import "SetTeachViewController.h"
#import "AmountDetailViewController.h"
#import "MyTicketDetailViewController.h"
#import "TQStarRatingView.h"
#import "MyStudentViewController.h"
#import "LoginViewController.h"
#import "ConvertCoinViewController.h"
#import "CouponNavigateViewController.h"
#import "PurseNavigationViewController.h"

@interface MyViewController () <UITextFieldDelegate, UIScrollViewDelegate> {
    CGRect _oldFrame1;
    CGRect _oldFrame2;
    NSString *updatePrice;
    NSString *getPrice;//取现金额
}
@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) IBOutlet UIView *checkView;           // 验证教练资格视图
@property (strong, nonatomic) IBOutlet UIView *getMoneyView;        // 申请金额视图
@property (strong, nonatomic) IBOutlet UIView *commitView;          // 提交申请
@property (strong, nonatomic) IBOutlet UIView *successAlertView;    // 提交成功提示
/**
 *申请状态提示语
 */
@property (weak, nonatomic) IBOutlet UILabel *applyStateLabel;

@property (strong, nonatomic) IBOutlet UIView *priceAndAddrView;    // 选择设置价格&上车地址&教学内容
@property (strong, nonatomic) IBOutlet UIView *priceAndAddrBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceWidthConstraint;//价格宽度约束

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITextField *moneyYuanField; // 取钱

//头像
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;//通过审核页面的头像
@property (strong, nonatomic) IBOutlet UIImageView *checkLogoImageView;//未通过审核的头像
@property (strong, nonatomic) IBOutlet UILabel *checkNameLabel;

//余额
@property (strong, nonatomic) IBOutlet UIButton *moneyBtn;//余额
@property (strong, nonatomic) IBOutlet UILabel *cashLabel;          // 保证金及冻结金额
@property (strong, nonatomic) IBOutlet UILabel *xiaobaTicketLabel;//小巴券
@property (strong, nonatomic) IBOutlet UIButton *convertButton;
@property (strong, nonatomic) IBOutlet UILabel *xiaobaCoinLabel;//小巴币
@property (strong, nonatomic) IBOutlet UIButton *coinConvertButton;
@property (strong, nonatomic) IBOutlet UIView *alertPhotoView;//弹框
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;
//取钱弹框
@property (strong, nonatomic) IBOutlet UILabel *alertMoneyLabel;//余额
@property (strong, nonatomic) IBOutlet UILabel *moneyDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *rechargeView; //充值
@property (strong, nonatomic) IBOutlet UITextField *rechargeYuanTextField;
@property (strong, nonatomic) IBOutlet UIButton *rechargeBtn;

//参数
@property (strong, nonatomic) UIImage *changeLogoImage;//修改后的头像

//消息条数
@property (strong, nonatomic) IBOutlet UILabel *complaintLabel;
@property (strong, nonatomic) IBOutlet UILabel *evaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UIView *numView;
@property (strong, nonatomic) TQStarRatingView *starView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *crashLabelWidth;

@property (strong, nonatomic) IBOutlet UIView *coinRuleView;

@property (strong, nonatomic) IBOutlet UIView *ruleBackView;

@property (strong, nonatomic) IBOutlet UIView *dataBackView;

@property (weak, nonatomic) IBOutlet UILabel *auditStateLabel;

- (IBAction)clickForRecommendPrize:(id)sender;

/**
 *存储用户信息的数组
 */
@property (nonatomic, strong)NSMutableArray *userDataArray;

@end

@implementation MyViewController

-(NSMutableArray *)userDataArray {
    if (!_userDataArray) {
        _userDataArray = [NSMutableArray array];
    }

    return _userDataArray;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.mainScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.mainScrollView.contentSize = CGSizeMake(0, self.dataBackView.height + self.dataBackView.y - 60);
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self AnalysisUserData];
    [self getMessageCount];
    [self settingView];
    [self updateMoney];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    
    // 注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogOut:) name:@"LogOut" object:nil];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    [self registerForKeyboardNotifications];
    
    //设置圆角
    self.alertDetailView.layer.cornerRadius = 4;
    self.alertDetailView.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMessageCount) name:@"ReceiveTopMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAlert) name:@"openAlert" object:nil];
    
    self.moneyYuanField.delegate = self;
    
    //圆角
    self.rechargeBtn.layer.cornerRadius = 4;
    self.rechargeBtn.layer.masksToBounds = YES;
    self.convertButton.layer.cornerRadius = 2;
    self.convertButton.layer.masksToBounds = YES;
    self.coinConvertButton.layer.cornerRadius = 2;
    self.coinConvertButton.layer.masksToBounds = YES;
    
    self.ruleBackView.layer.cornerRadius = 3;
    self.ruleBackView.layer.masksToBounds = YES;
}

- (void)changeMessageCount {
    [self getMessageCount];
}

-(void)backupgroupTap:(id)sender{
    [self.moneyYuanField resignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    self.strokeImageView.hidden = NO;
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

- (void)settingView {
    
    self.getMoneyView.frame = [UIScreen mainScreen].bounds;
    
    //判断该用户是否通过审核
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *state = [userInfo[@"state"] description];//2:通过审核
    NSString *logoUrl = userInfo[@"avatarurl"];//头像
    NSString *name = userInfo[@"realname"];
    NSString *phone = userInfo[@"phone"];//手机号
    NSString *signstate = [userInfo[@"signstate"] description];
    if ([signstate intValue]==1) {
        self.starImageView.hidden = NO;
    }else{
        self.starImageView.hidden = YES;
    }
    //培训时长
    NSString *totalTime = [userInfo[@"totaltime"] description];
    totalTime = [CommonUtil isEmpty:totalTime]?@"0":totalTime;
    state = @"2";//全部显示的为已经通过审核的UI
    
    if ([state intValue] == 2) {
        self.dataView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)+80);
        [self.mainScrollView addSubview:self.dataView];
        self.mainScrollView.userInteractionEnabled=YES;
        
        NSString *money = [userInfo[@"money"] description];//余额
        
        //头像
        self.strokeImageView.hidden = YES;
        
        //昵称
        if (name.length == 0) {
           self.nameLabel.text = @"未设置";
        }else{
           self.nameLabel.text = name;
        }
        
        self.phoneLabel.text = phone;
        [self.trainTimeButton setTitle:[NSString stringWithFormat:@"   已累计培训%@学时",totalTime] forState:UIControlStateNormal];
        //余额
        if ([CommonUtil isEmpty:money]) {
            money = @"0";
        }
        self.cashLabel.text = [NSString stringWithFormat:@"%@",money];
        
        //小巴券时间
        int couponhour = [userInfo[@"couponhour"] intValue];
         self.xiaobaTicketLabel.text = [NSString stringWithFormat:@"%d",couponhour];
        
        //小巴币个数
        NSString *coinnum = [userInfo[@"coinnum"] description];
        self.xiaobaCoinLabel.text = coinnum;
        
        float score = [userInfo[@"score"] floatValue];
        UILabel *label1 = [UILabel new];
        label1.text = self.nameLabel.text;
        label1.font =  [UIFont systemFontOfSize:20];
        label1.numberOfLines = 0;        // 设置无限换行
        
        CGRect rect = self.priceAndAddrBar.bounds;
        rect.origin.y = 3;
        rect.size.height = 15;
        rect.size.width = 103;
        self.starView = [[TQStarRatingView alloc] initWithFrame:rect numberOfStar:5];
        [self.priceAndAddrBar addSubview:self.starView];
        [self.starView changeStarForegroundViewWithScore:score];
        
    }else{
        //未通过审核
        self.checkView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        [self.view addSubview:self.checkView];//显示未通过审核的页面
        [self.checkLogoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"]];
        [self performSelector:@selector(updateLogoImage:) withObject:self.checkLogoImageView afterDelay:0.1f];
        self.checkNameLabel.text = name;//名称
    }
    
}
//显示设置地址价格的弹框
- (void)openAlert{
    self.priceAndAddrView.frame = self.view.frame;
    [self.view addSubview:self.priceAndAddrView];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (void)dealloc {
    self.mainScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

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
    _oldFrame1 = self.commitView.frame;
    
//    UIView *priceCommitView = [self.setPriceView viewWithTag:100];
//    _oldFrame2 = priceCommitView.frame;

    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGFloat offset = CGRectGetMaxY(self.commitView.frame) - keyboardTop + 10;

    NSTimeInterval animationDuration = 0.3f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.commitView.frame = CGRectMake(_oldFrame1.origin.x, _oldFrame1.origin.y - offset, _oldFrame1.size.width, _oldFrame1.size.height);
//    priceCommitView.frame = CGRectMake(_oldFrame2.origin.x, _oldFrame2.origin.y - offset, _oldFrame2.size.width, _oldFrame2.size.height);
    [UIView commitAnimations];

}
// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    self.commitView.frame = _oldFrame1;
//    UIView *priceCommitView = [self.setPriceView viewWithTag:100];
//    priceCommitView.frame = _oldFrame2;
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
        
        UIImage *image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            image = [CommonUtil fixOrientation:image];
            
            [self uploadLogo:image];
        }
        
        [self.alertPhotoView removeFromSuperview];
    }];
}
#pragma mark - 按钮方法
// 通过审核
- (IBAction)clickForPass:(id)sender {
    self.hasChecked = 1;
    [self.checkView removeFromSuperview];
}

- (IBAction)closeRuleView:(id)sender {
    [self.coinRuleView removeFromSuperview];
}
// 查看小巴币/券规则
- (IBAction)clickForCoinRuleView:(id)sender {
    
    
    [self openAlert];
//  self.photoView.hidden = NO;
//  self.coinRuleView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//  [self.tabBarController.view addSubview:self.coinRuleView];
}
// 更改头像
- (IBAction)clickForChangePortrait:(id)sender {
//    self.photoView.hidden = NO;
    self.alertPhotoView.frame = self.view.frame;
    [self.view addSubview:self.alertPhotoView];
}
//关闭弹框
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertPhotoView removeFromSuperview];
}

- (IBAction)clickForCamera:(id)sender {
    self.pickPhotoController = [self photoController];
    
    if ([CZPhotoPickerController canTakePhoto]) {
        //拍照
        self.pickPhotoController.allowsEditing = YES;
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        self.pickPhotoController.allowsEditing = YES;
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (IBAction)clickForAlbum:(id)sender {
    self.pickPhotoController = [self photoController];
    //相册
    self.pickPhotoController.allowsEditing = YES;
    [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
// 申请提现
- (IBAction)clickForMoney:(id)sender {
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去钱包下的账户管理页面设置您的支付宝账户"];
        return;
    }
    
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    
    //设置价格
    
    NSString *money = [userInfo[@"money"] description];//余额
    NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
    NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
    
    // 保证金及冻结金额
    if ([CommonUtil isEmpty:gMoney]){
        gMoney = @"0";
    }
    
    if ([CommonUtil isEmpty:moneyFrozen]) {
        moneyFrozen = @"0";
    }
    
    if ([CommonUtil isEmpty:money]) {
        moneyFrozen = @"0";
    }
    
    double lestMoney = [money doubleValue] - [gMoney doubleValue];
    if(lestMoney < 0){
        lestMoney = 0;
    }
    
    money = [NSString stringWithFormat:@"%.0f", lestMoney];
    self.alertMoneyLabel.text = [NSString stringWithFormat:@"%@元", money];
    [self.alertMoneyLabel.superview  bringSubviewToFront:self.alertMoneyLabel];
}
// 兑换小巴券
- (IBAction)clickForConvertTicket:(id)sender {
    MyTicketDetailViewController *nextController = [[MyTicketDetailViewController alloc] initWithNibName:@"MyTicketDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
//查看小巴币详情
- (IBAction)clickForCoinDetail:(id)sender {
    ConvertCoinViewController *nextController = [[ConvertCoinViewController alloc] initWithNibName:@"ConvertCoinViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
// 取消取钱
- (IBAction)clickForCancel:(id)sender {
    [self.getMoneyView removeFromSuperview];
}
//查看收支详细
- (IBAction)lookDetail:(id)sender {
    AmountDetailViewController *nextController = [[AmountDetailViewController alloc] initWithNibName:@"AmountDetailViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}
//查看小巴券明细
- (IBAction)lookTicketDetail:(id)sender {
    
}
// 提交取钱
- (IBAction)clickForCommit:(id)sender {
    
    NSString *yuan = [self.moneyYuanField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:yuan]) {
        [self makeToast:@"请输入您要提现的金额"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    
    if ([yuan intValue] == 0) {
        [self makeToast:@"请输入您要提现的金额"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    [self.moneyYuanField resignFirstResponder];
    
    NSString *price = [NSString stringWithFormat:@"%d", [yuan intValue]];
    
    //设置价格
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *money = [userInfo[@"money"] description];//余额
    NSString *moneyFrozen = [userInfo[@"money_frozen"] description];//冻结金额
    NSString *gMoney = [userInfo[@"gmoney"] description];//保证金
    
    if ([CommonUtil isEmpty:money]) {
        money = @"0";
    }
    
    // 保证金及冻结金额
    if ([CommonUtil isEmpty:gMoney]){
        gMoney = @"0";
    }
    if ([CommonUtil isEmpty:moneyFrozen]) {
        moneyFrozen = @"0";
    }
    
    if ([price doubleValue] <50) {
        //提现金额不得小于50
        [self makeToast:@"请输入大于50元的数额进行提现"];
        return;
    }
    
    //判断是否有这么多金额可以取    moneyFrozen//不用减去冻结金额
    if ([price doubleValue] < [money doubleValue] - [gMoney doubleValue]) {
        //提现金额足够
        [self getMoney:price];
        getPrice = price;
        self.moneyTitleLabel.text = @"提交成功";
        self.moneyDetailLabel.text = [NSString stringWithFormat:@"您申请的%@元金额已提交成功，请等待审核，我们会在3个工作日内联系您！", price];
        
    }else{
        //提现金额不足
        [self makeToast:@"您的可提现金额不足，请重新输入"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
}
// 关闭提交成功提示
- (IBAction)clickForClose:(id)sender {
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.getMoneyView removeFromSuperview];
}

- (IBAction)clickForClosePriceAndAddr:(id)sender {
    [self.priceAndAddrView removeFromSuperview];
}
// 设置价格
- (IBAction)clickForSetPrice:(id)sender {

}

- (IBAction)clickForCloseSetPrice:(id)sender {
//    [self.setPriceView removeFromSuperview];
}
// 我的投诉
- (IBAction)clickToMyComplainView:(id)sender {
//    MyComplainViewController *targetViewController = [[MyComplainViewController alloc] initWithNibName:@"MyComplainViewController" bundle:nil];
//    [self.navigationController pushViewController:targetViewController animated:YES];
    MyStudentViewController *nextViewController = [[MyStudentViewController alloc] initWithNibName:@"MyStudentViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
// 我的评价
- (IBAction)clickToMyEvaluateView:(id)sender {
    MyEvaluationViewController *targetViewController = [[MyEvaluationViewController alloc] initWithNibName:@"MyEvaluationViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
// 我的通知
- (IBAction)clickToMyMessageView:(id)sender {
    MyMessageViewController *targetViewController = [[MyMessageViewController alloc] initWithNibName:@"MyMessageViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
// 我的资料
- (IBAction)clickToMyInfoView:(id)sender {
    MyInfoViewController *targetViewController = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
// 上车地址设置
- (IBAction)clickToSetAddrView:(id)sender {
//    [self.priceAndAddrView removeFromSuperview];
    SetAddrViewController *targetViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//发放学车券
- (IBAction)clickForSendCoupon:(id)sender {
    CouponNavigateViewController *targetViewController = [[CouponNavigateViewController alloc] initWithNibName:@"CouponNavigateViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//在线客服
- (IBAction)clickForOnlineServe:(id)sender {
   
}
#warning 暂时不知道是干什么的 监听某个事件
- (void)chatAction:(NSNotification *)notification {
    [self makeToast:@"暂未开放"];
}
// 教学内容设置
- (IBAction)clickToSetTeachView:(id)sender{
    
    SetTeachViewController *targetViewController = [[SetTeachViewController alloc] initWithNibName:@"SetTeachViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
    
}
// 进入设置界面
- (IBAction)clickToSetting:(id)sender {
    SetViewController *targetViewController = [[SetViewController alloc] initWithNibName:@"SetViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//实现消息通知方法
- (void)LogOut:(NSNotification *)notification{
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
   
}

- (IBAction)clickForCoachMsg:(id)sender {
    CoachInfoViewController *targetViewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
    targetViewController.superViewNum = @"1";
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//充值 我的钱包
 - (IBAction)clickForChongzhi:(id)sender {
    PurseNavigationViewController *nextViewController = [[PurseNavigationViewController alloc] initWithNibName:@"PurseNavigationViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (IBAction)removeChongzhi:(id)sender {
    [self.rechargeView removeFromSuperview];
}
//提交充值
- (IBAction)clickForChongzhiCommit:(id)sender {
    NSString *price = [self.rechargeYuanTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *jiaoPrice = [self.rechargeJiaoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:price]) {
        [self makeToast:@"请输入价格"];
        [self.rechargeYuanTextField becomeFirstResponder];
        return;
    }
    
    
    [self.rechargeYuanTextField resignFirstResponder];
//    [self.rechargeJiaoTextField resignFirstResponder];
    
//    if ([CommonUtil isEmpty:jiaoPrice]) {
//        updatePrice = [NSString stringWithFormat:@"%d", [price intValue]];
//    }else{
//        updatePrice = [NSString stringWithFormat:@"%d.%@", [price intValue], jiaoPrice];
//    }
    updatePrice = [NSString stringWithFormat:@"%d", [price intValue]];
    [self rechargeMoney:updatePrice];//修改价格
}

- (IBAction)clickForCloseKeyboard:(id)sender {
    [self.rechargeYuanTextField resignFirstResponder];
}
//上传头像
- (void)uploadLogo:(UIImage *)image{
    [DejalBezelActivityView activityViewForView:self.view];
    
    self.changeLogoImage = image;//修改的头像
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
}
//提现
- (void)getMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
      [DejalBezelActivityView activityViewForView:self.view];
}
//获取消息条数
- (void)getMessageCount{
    
   }
//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
  }
//充值
- (void)rechargeMoney:(NSString *)money{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
      [DejalBezelActivityView activityViewForView:self.view];
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
#pragma mark - private
- (void)alipayForPartner:(NSString *)partner seller:(NSString *)seller privateKey:(NSString *)privateKey
                 tradeNO:(NSString *)tradeNO subject:(NSString *)subject body:(NSString *)body
                   price:(NSString *)price notifyURL:(NSString *)notifyURL{
   


}
- (IBAction)clickForChangeInfo:(id)sender {
    MyInfoViewController *targetViewController = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}
//分享有礼
- (IBAction)clickForRecommendPrize:(id)sender {
    
    
}


#pragma make  数据获取
- (void)AnalysisUserData{
    //获取应用程序沙盒的Documents目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSLog(@"paths%@", paths);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filename=[plistPath stringByAppendingPathComponent:@"UserLogInData.plist"];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    NSLog(@"%@userData", userData);
    NSArray *keyArray =[userData allKeys];
    
    if (keyArray.count == 0) {
    
        
    }else {
        //http://106.14.158.95:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT/coach/api/detail?coachId=206405433894470f91db2657ae8e73e3
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/detail", kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"coachId"] =userData[@"coachId"];
        NSLog(@"URL_Dic%@", URL_Dic);
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        __block MyViewController *VC = self;
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"0"]) {
                
            }else {
                [VC AnalyticalData:responseObject];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [VC showAlert:@"请求失败请重试" time:1.0];
        }];
    }
}
//解析的用户详情信息
- (void)AnalyticalData:(NSDictionary *)dic {
    
    [self.userDataArray removeAllObjects];
    NSString *state = [NSString stringWithFormat:@"%@", dic[@"result"]];
    if ([state isEqualToString:@"1"]) {
        NSDictionary *tempDic = dic[@"data"][0];
        NSDictionary *urseDataDic = tempDic[@"coach"];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UserLogInData" ofType:@"plist"];
        
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CoachAuditStatusModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CoachAuditStatusModel *model = [[CoachAuditStatusModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        [userData removeAllObjects];
        for (NSString *key in urseDataDic) {
            if ([key isEqualToString:@"state"]) {
                [UserDataSingleton mainSingleton].approvalState =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            if ([key isEqualToString:@"coachId"]) {
                [UserDataSingleton mainSingleton].coachId =[NSString stringWithFormat:@"%@", urseDataDic[key]];
                NSLog(@"[UserDataSingleton mainSingleton].coachId%@", [UserDataSingleton mainSingleton].coachId);
            }
            if ([key isEqualToString:@"realName"]) {
                [UserDataSingleton mainSingleton].userName =[NSString stringWithFormat:@"%@", urseDataDic[key]];
                
            }
            if ([key isEqualToString:@"balance"]) {
                [UserDataSingleton mainSingleton].balance =[NSString stringWithFormat:@"%@", urseDataDic[key]];
            }
            [userData setObject:urseDataDic[key] forKey:key];
            [model setValue:urseDataDic[key] forKey:key];
        }
        [self.userDataArray addObject:model];
        //获取应用程序沙盒的Documents目录
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *plistPath1 = [paths objectAtIndex:0];
        
        //得到完整的文件名
        NSString *filename=[plistPath1 stringByAppendingPathComponent:@"UserLogInData.plist"];
        //输入写入
        [userData writeToFile:filename atomically:YES];
        
        //那怎么证明我的数据写入了呢？读出来看看
        NSMutableDictionary *userData2 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    }
    NSLog(@"userDataArray%@", self.userDataArray);
    [self refreshUI];
}


- (void)refreshUI {
    CoachAuditStatusModel *model = self.userDataArray[0];
    //判断该用户是否通过审核
    int state = model.state;
    //NSString *logoUrl = model.memberAvatar;
    NSString *name = model.realName;
    NSString *phone = model.phone;
    if (model.state == 0 || model.state == 1 || model.state == 3 ) {
        self.starImageView.hidden = YES;
        self.strokeImageView.hidden = YES;
    }else{
        self.strokeImageView.hidden = NO;
        self.starImageView.hidden = NO;
    }
    //培训时长
    NSString *totalTime = @"10";
    totalTime = [CommonUtil isEmpty:totalTime]?@"0":totalTime;
    
    if (model.state == 2) {
        [self.checkView removeFromSuperview];
        self.dataView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds)+80);
        [self.mainScrollView addSubview:self.dataView];
        self.mainScrollView.userInteractionEnabled=YES;
        
        NSString *money = @"100";//余额
        //头像
        self.strokeImageView.hidden = YES;
        //昵称
        if (name.length == 0) {
            self.nameLabel.text = @"未设置";
        }else{
            self.nameLabel.text = name;
        }
        self.phoneLabel.text = phone;
        [self.trainTimeButton setTitle:[NSString stringWithFormat:@" 已累计培训%@学时",totalTime] forState:UIControlStateNormal];
        //余额
        if ([CommonUtil isEmpty:money]) {
            money = @"0";
        }
        self.cashLabel.text = [NSString stringWithFormat:@"%@",money];
        //小巴券时间
        int couponhour = 12;
        self.xiaobaTicketLabel.text = [NSString stringWithFormat:@"%d",couponhour];
        //小巴币个数
        NSString *coinnum = @"10";
        self.xiaobaCoinLabel.text = coinnum;
        float score = 4.5;
        UILabel *label1 = [UILabel new];
        label1.text = self.nameLabel.text;
        label1.font =  [UIFont systemFontOfSize:20];
        label1.numberOfLines = 0;       // 设置无限换行
        CGRect rect = self.priceAndAddrBar.bounds;
        rect.origin.y = 3;
        rect.size.height = 15;
        rect.size.width = 103;
        self.starView = [[TQStarRatingView alloc] initWithFrame:rect numberOfStar:5];
        [self.priceAndAddrBar addSubview:self.starView];
        [self.starView changeStarForegroundViewWithScore:score];
        
    }else{
        int  state = [UserDataSingleton mainSingleton].approvalState.intValue;
        switch (state) {
            case 0:
                self.auditStateLabel.text = @"还为申请成为教练!";
                break;
            case 1:
                self.auditStateLabel.text = @"正在等待审核您的资料!";
                break;
            case 2:
                self.auditStateLabel.text = @"您的资料已经审核通过!";
                break;
            case 3:
                self.auditStateLabel.text = @"您的资料审核未通过,请重新提交!";
                self.applyStateLabel.text = model.rejectReason;
                break;
            default:
                break;
        }
        self.nameLabel.text = @"";
        self.checkView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        [self.view addSubview:self.checkView];//显示未通过审核的页面
        [self performSelector:@selector(updateLogoImage:) withObject:self.checkLogoImageView afterDelay:0.1f];
        self.checkNameLabel.text = name;//名称
        self.checkLogoImageView.hidden = NO;
        self.checkLogoImageView.image = [UIImage imageNamed:@"icon_portrait_default"];
    }


}

@end
