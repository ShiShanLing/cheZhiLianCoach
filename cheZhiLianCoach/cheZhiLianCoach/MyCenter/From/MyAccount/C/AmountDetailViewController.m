//
//  AmountDetailViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AmountDetailViewController.h"
#import "DSPullToRefreshManager.h"
#import "AmountTableViewCell.h"
#import "AccountManagerViewController.h"
#import "LoginViewController.h"

#define korderNum 10

@interface AmountDetailViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient,UITextFieldDelegate>{
    CGRect _oldFrame1;
    CGRect _oldFrame2;
}


@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新

//交易记录
@property (strong, nonatomic) NSMutableArray *amountArray;
@property (strong, nonatomic) NSString *totalPrice;//总金额
@property (strong, nonatomic) NSString *fMoney;//冻结金额
@property (strong, nonatomic) NSString *gmoney;//保证金额

@property (strong, nonatomic) IBOutlet UIButton *rechargButton;
@property (strong, nonatomic) IBOutlet UIButton *applyButton;

- (IBAction)clickForRecharge:(id)sender;
- (IBAction)clickForApply:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *rechargeView;
- (IBAction)clickForCloseAlert:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *rechargeCommitBtn;
@property (strong, nonatomic) IBOutlet UITextField *rechargeYuanTextField;

@property (strong, nonatomic) IBOutlet UILabel *headAlertMoneyLabel;  //总金额
@property (strong, nonatomic) IBOutlet UILabel *canBeCashLabel;    //可提现金额
@property (strong, nonatomic) IBOutlet UILabel *frozenMoneyLabel;  //冻结金额

@property (strong, nonatomic) IBOutlet UIView *getMoneyView;        // 申请金额视图
@property (strong, nonatomic) IBOutlet UIView *commitView;          // 提交申请
@property (strong, nonatomic) IBOutlet UIView *successAlertView;    // 提交成功提示
@property (strong, nonatomic) IBOutlet UIView *rechargeBackView;//充值底部白view

@property (strong, nonatomic) IBOutlet UITextField *moneyYuanField; // 取钱

//取钱弹框
@property (strong, nonatomic) IBOutlet UILabel *alertMoneyLabel;//余额
@property (strong, nonatomic) IBOutlet UILabel *moneyDetailLabel;  //申请是否成功的提示
@property (strong, nonatomic) IBOutlet UILabel *moneyTitleLabel;  //是否提交成功的字段

- (IBAction)clickForAccountManager:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *commitBackView;   //返回按钮
@property (strong, nonatomic) IBOutlet UIButton *commitButton;   //提现按钮
@property (strong, nonatomic) IBOutlet UIImageView *noMoneyImage;  //余额不足的图片
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel;  //警告
@property (strong, nonatomic) IBOutlet UILabel *attentionLabel2;

@property (strong, nonatomic) IBOutlet UIView *addMoneyBackView;
@property (strong, nonatomic) IBOutlet UIView *apply_rechargeView;
@end

@implementation AmountDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.amountArray = [NSMutableArray array];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:NO];
    [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self pullToRefreshTriggered:self.pullToRefresh];
    
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    
    self.rechargButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.rechargButton.layer.borderWidth = 0.5;
    self.apply_rechargeView.layer.cornerRadius = CGRectGetHeight(self.apply_rechargeView.frame)/2;
    self.apply_rechargeView.layer.masksToBounds = YES;
    self.apply_rechargeView.layer.borderWidth = 0.5;
    self.apply_rechargeView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _rechargeCommitBtn.layer.cornerRadius = 3;
    _rechargeCommitBtn.layer.masksToBounds = YES;
    self.rechargeCommitBtn.layer.borderWidth = 1;
    self.rechargeCommitBtn.layer.borderColor = MColor(188, 188, 188).CGColor;
    [self.rechargeCommitBtn setTitleColor:MColor(188, 188, 188) forState:UIControlStateDisabled];
    [self.rechargeCommitBtn setBackgroundImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateDisabled];
    [self.rechargeYuanTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.rechargeCommitBtn.enabled = NO;
    self.rechargeBackView.layer.cornerRadius = 3;
    self.rechargeBackView.layer.masksToBounds = YES;
    
    self.commitBackView.layer.borderColor = MColor(188, 188, 188).CGColor;
    self.commitBackView.layer.borderWidth = 1;
    self.addMoneyBackView.layer.borderColor = MColor(188, 188, 188).CGColor;
    self.addMoneyBackView.layer.borderWidth = 1;
    
    self.commitView.layer.cornerRadius = 3;
    self.commitView.layer.masksToBounds = YES;
    self.successAlertView.layer.cornerRadius = 3;
    self.successAlertView.layer.masksToBounds = YES;
    
    self.commitButton.layer.borderWidth = 1;
    self.commitButton.layer.borderColor = MColor(188, 188, 188).CGColor;
    self.commitButton.layer.cornerRadius = 3;
    self.commitButton.layer.masksToBounds = YES;
    [self.commitButton setTitleColor:MColor(188, 188, 188) forState:UIControlStateDisabled];
    [self.commitButton setBackgroundImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateDisabled];
    self.commitButton.enabled = NO;
    self.noMoneyImage.hidden = YES;
    self.moneyYuanField.delegate = self;
    [self.moneyYuanField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.attentionLabel2.hidden = YES;
    [self registerForKeyboardNotifications];
    
    //缺少一句话
    self.getMoneyView.frame = [UIScreen mainScreen].bounds;

}


- (void) textFieldDidChange:(UITextField *) TextField{
    if (TextField == self.moneyYuanField) {
        if (self.moneyYuanField.text.length > 0) {
            self.commitButton.enabled = YES;
            self.commitButton.layer.borderWidth = 0;
        }else{
            self.commitButton.enabled = NO;
            self.commitButton.layer.borderWidth = 1;
        }
    }else if (TextField == self.rechargeYuanTextField){
        if (self.rechargeYuanTextField.text.length > 0) {
            self.rechargeCommitBtn.enabled = YES;
            self.rechargeCommitBtn.layer.borderWidth = 0;
        }else{
            self.rechargeCommitBtn.enabled = NO;
            self.rechargeCommitBtn.layer.borderWidth = 1;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showTableHeaderView];
}

- (void)requestTradingData {
    //http://106.14.158.95:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT?coachId=1a0bc1131b7c47fcb2514386674aa051
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findAccountLog", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    __weak  AmountDetailViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        [VC.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [VC.pullToRefresh setPullToRefreshViewVisible:YES];
        if ([resultStr isEqualToString:@"1"]) {
            [VC parsingTradingData:responseObject];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];

}
- (void)parsingTradingData:(NSDictionary *)dataDic {
    [self.amountArray removeAllObjects];
    NSArray *dataArray = dataDic[@"data"];
    if (dataArray.count  == 0) {
        [self showAlert:@"暂时没有交易记录!" time:1.2];
        return;
    }
    for (NSDictionary *modelDic in dataArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"TradingRecordModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        TradingRecordModel *model = [[TradingRecordModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        for (NSString *key in modelDic) {
            [model setValue:modelDic[key] forKey:key];
        }
        [self.amountArray addObject:model];
    }
    NSLog(@"amountArray%@", self.amountArray);
    [self.mainTableView reloadData];
    
}

// 监听键盘弹出通知
- (void) registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 键盘弹出，控件偏移
- (void) keyboardWillShow:(NSNotification *) notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    if(self.rechargeView.superview){
        _oldFrame1 = self.rechargeView.frame;

        CGFloat offset = keyboardTop - (SCREEN_HEIGHT - 193) / 2;
        
        if(offset > 0){
            NSTimeInterval animationDuration = 0.3f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            self.rechargeView.frame = CGRectMake(_oldFrame1.origin.x, _oldFrame1.origin.y - offset / 2, _oldFrame1.size.width, _oldFrame1.size.height);
            [UIView commitAnimations];
        }
    }
    
    if(self.getMoneyView.superview){
        _oldFrame2 = self.getMoneyView.frame;
        CGFloat offset = keyboardTop - (SCREEN_HEIGHT - 238) / 2;
        
        if(offset > 0){
            NSTimeInterval animationDuration = 0.3f;
            [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            self.getMoneyView.frame = CGRectMake(_oldFrame2.origin.x, _oldFrame2.origin.y - offset / 2, _oldFrame2.size.width, _oldFrame2.size.height);
            [UIView commitAnimations];
        }
    }
}

// 键盘收回，控件恢复原位
- (void) keyboardWillHidden:(NSNotification *) notif {
    if(self.rechargeView.superview)
        self.rechargeView.frame = _oldFrame1;
     if(self.getMoneyView.superview)
        self.getMoneyView.frame = _oldFrame2;
}


#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self requestTradingData];
    [_pullToRefresh tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    
    [self requestTradingData];
}


- (void)getDataFinish{
    
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.amountArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *dic = [self.amountArray objectAtIndex:indexPath.row];
    TradingRecordModel *model =self.amountArray [indexPath.row];
    
    NSString *amount = [NSString stringWithFormat:@"%.2f", model.balanceChange];//数量
    NSString *str = [NSString stringWithFormat:@"(课程总额%@元", amount];
//    NSString *type = @"1";//数量
//    NSString *amount_out1 =@"0";//平台抽成
//    NSString *amount_out2 = @"0";//驾校抽成
  
    
//
//
//                str = [NSString stringWithFormat:@"%@，其中%@元车智联平台抽成", str, amount_out1];
//
//
//
//                str = [NSString stringWithFormat:@"%@，其中%@元驾校抽成", str, amount_out2];
//
//
//            str = [NSString stringWithFormat:@"%@)", str];
 
    CGFloat height = 60;
    CGSize size = [CommonUtil sizeWithString:str fontSize:12 sizewidth:CGRectGetWidth([UIScreen mainScreen].bounds) - 23 sizeheight:MAXFLOAT];
        height += ceilf(size.height) + 15;

    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellident = @"AmountTableViewCell";
    AmountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    TradingRecordModel *model =self.amountArray [indexPath.row];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AmountTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    NSString *time = [CommonUtil getStringForDate:model.createTime];
    NSString *type = @"1";
    NSString *amount = [NSString stringWithFormat:@"%.2f", model.balanceChange];
    cell.width = [NSString stringWithFormat:@"%f", CGRectGetWidth([UIScreen mainScreen].bounds)];
    [cell setType:type time:time amount:amount];
    [cell setDesDic:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//显示tableHeaderView
- (void)showTableHeaderView{
    //金额
    NSString *money = [NSString stringWithFormat:@"%@元", @"100"];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:money];
    [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0,self.totalPrice.length)];
    self.headAlertMoneyLabel.attributedText = str1;
    
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float fMoney =[self.fMoney floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    self.canBeCashLabel.text = [NSString stringWithFormat:@"%.0f",80.0];;
    self.frozenMoneyLabel.text = [NSString stringWithFormat:@"%.0f" ,20.0];;
    
}

- (IBAction)clickForRecharge:(id)sender {
    if(self.rechargeView.superview){
        [self.rechargeView removeFromSuperview];
    }
    
    self.rechargeView.frame = self.view.frame;
    [self.view addSubview:self.rechargeView];
    
}

- (IBAction)clickForApply:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去账户管理页面设置您的支付宝账户"];
        return;
    }
    
    self.commitView.hidden = NO;
    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    NSString *titleString = [NSString stringWithFormat:@"账户余额 %.0f 元",v];
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:titleString];
    [str1 addAttribute:NSForegroundColorAttributeName value:MColor(247, 61, 68) range:NSMakeRange(5, [NSString stringWithFormat:@"%.0f",v ].length)];
    [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28] range:NSMakeRange(5,[NSString stringWithFormat:@"%.0f",v ].length)];
    self.alertMoneyLabel.attributedText = str1;
    [self.alertMoneyLabel.superview  bringSubviewToFront:self.alertMoneyLabel];
    
    if ([self.totalPrice intValue]<50) {
        self.attentionLabel.hidden = YES;
        self.attentionLabel2.hidden = NO;
        self.commitBackView.hidden = YES;
        self.commitButton.hidden = YES;
        self.noMoneyImage.hidden = NO;
    }else{
        self.attentionLabel.hidden = NO;
        self.attentionLabel2.hidden = YES;
        self.commitBackView.hidden = NO;
        self.commitButton.hidden = NO;
        self.noMoneyImage.hidden = YES;
    }
    
}

- (IBAction)clickForCloseAlert:(id)sender {
    self.rechargeYuanTextField.text = @"";
    if(self.rechargeView.superview){
        [self.rechargeView removeFromSuperview];
    }
    
    self.moneyYuanField.text = @"";
    if(self.getMoneyView.superview){
        [self.getMoneyView removeFromSuperview];
    }
}

- (IBAction)clickForCloseKeybord:(id)sender {
    [self.rechargeYuanTextField resignFirstResponder];
    [self.moneyYuanField resignFirstResponder];
}

//提交充值
- (IBAction)clickForChongzhiCommit:(id)sender {
    NSString *price = [self.rechargeYuanTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([CommonUtil isEmpty:price]) {
        [self makeToast:@"请输入价格"];
        [self.rechargeYuanTextField becomeFirstResponder];
        return;
    }
    
    
    [self.rechargeYuanTextField resignFirstResponder];
    
    //[self rechargeMoney:price];//修改价格
}

// 提交取钱
- (IBAction)clickForApplyCommit:(id)sender {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *aliaccount = userInfo[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去账户管理页面设置您的支付宝账户"];
        return;
    }
    
    //可提现金额 已冻结金额
    float totalPricef=[self.totalPrice floatValue];
    float gmoney= [self.gmoney floatValue];
    float v= totalPricef-gmoney;
    if(v < 0){
        v = 0;
    }
    self.moneyYuanField.text = [NSString stringWithFormat:@"%f",v];
    
    //    self.commitView.hidden = YES;
    //    self.successAlertView.hidden = NO;
    
    NSString *yuan = [self.moneyYuanField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    

    
    NSString *price = [NSString stringWithFormat:@"%d", [yuan intValue]];
    
    //设置价格
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
        [self makeToast:@"可提现金额大于50元才可以提现哦"];
        return;
    }
    
    //判断是否有这么多金额可以取
    if ([price doubleValue] <= [money doubleValue] - [gMoney doubleValue]) {
        //提现金额足够
       // [self getMoney:price];
        self.moneyTitleLabel.text = @"提交成功";
        self.moneyDetailLabel.text = [NSString stringWithFormat:@"您申请的%@元金额已提交成功，请等待审核，我们会在3个工作日内联系您！", price];
        
    }else{
        //提现金额不足
        [self makeToast:@"您的可提现金额不足，请重新输入"];
        [self.moneyYuanField becomeFirstResponder];
        return;
    }
    
    self.commitView.hidden = YES;
    //    self.successAlertView.hidden = YES;
    [self.view addSubview:self.getMoneyView];
    
}





- (void)alipayForPartner:(NSString *)partner seller:(NSString *)seller privateKey:(NSString *)privateKey
                 tradeNO:(NSString *)tradeNO subject:(NSString *)subject body:(NSString *)body
                   price:(NSString *)price notifyURL:(NSString *)notifyURL{
   
}

- (IBAction)clickForAccountManager:(id)sender {
    AccountManagerViewController *nextViewController = [[AccountManagerViewController alloc] initWithNibName:@"AccountManagerViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
