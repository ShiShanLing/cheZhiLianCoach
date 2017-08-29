//
//  ConvertCoinViewController.m
//  guangda
//
//  Created by Ray on 15/7/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ConvertCoinViewController.h"
#import "CoinRecordListViewController.h"
#import "CoinRecordListTableViewCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"

#define kCoinRecordList 10


@interface ConvertCoinViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient,UIAlertViewDelegate>
{
    NSString *buttonTag;
    NSArray *coinaffiliationlist;
    int pageNum;
    BOOL hasTask;//是否有进行中的任务
    BOOL isRefresh;//是否刷新
    NSMutableArray *coinRecordList;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel1;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel2;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel3;

@property (strong, nonatomic) IBOutlet UIButton *nodataView;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) IBOutlet UIView *ruleView;//规则页面

@property (strong, nonatomic) IBOutlet UIView *cheakView;//兑换页面
@property (strong, nonatomic) IBOutlet UILabel *convertID;//兑换订单号
@property (strong, nonatomic) IBOutlet UILabel *convertPeople;//兑换人
@property (strong, nonatomic) IBOutlet UILabel *ownerLabel;//发放人
@property (strong, nonatomic) IBOutlet UILabel *convertCount;//兑换数量
@property (strong, nonatomic) IBOutlet UILabel *moneyCount;//折算金额
@property (strong, nonatomic) IBOutlet UILabel *orderTime;//申请时间


@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *coinNumTextfield;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn1;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn2;
@property (strong, nonatomic) IBOutlet UIButton *convertBtn3;

@property (strong, nonatomic) IBOutlet UIView *alertView;


@property (strong, nonatomic) IBOutlet UIView *ruleBackView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewFromConstraint;
- (IBAction)clickForClose:(id)sender;
@end

@implementation ConvertCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self massageDic:nil];
    self.backView.layer.borderColor = MColor(222, 222, 222).CGColor;
    self.backView.layer.borderWidth = 0.5;
    
    self.convertBtn1.layer.cornerRadius = 2;
    self.convertBtn1.layer.masksToBounds = YES;
    self.convertBtn2.layer.cornerRadius = 2;
    self.convertBtn2.layer.masksToBounds = YES;
    self.convertBtn3.layer.cornerRadius = 2;
    self.convertBtn3.layer.masksToBounds = YES;
    
    
    NSString *realname = @"10";
    NSString *coinnum = @"100";
    
    NSString *titleLabelStr = [NSString stringWithFormat:@"%@教练小巴币：%@个",realname,coinnum];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(realname.length+6,coinnum.length)];
    self.titleLabel1.attributedText = string;
    

    self.titleLabel2.attributedText = string;
    self.titleLabel3.attributedText = string;
    
    [self.convertBtn1 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn1 setEnabled:YES];
    
    [self.convertBtn2 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn2 setEnabled:YES];
    [self.convertBtn3 setBackgroundImage:[UIImage imageNamed:@"unEnable.png"] forState:UIControlStateDisabled];
    [self.convertBtn3 setEnabled:YES];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;

    coinRecordList = [[NSMutableArray alloc]init];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    self.nodataView.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshTaskData" object:nil];
    
    self.ruleBackView.layer.cornerRadius = 3;
    self.ruleBackView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateMoney];
    isRefresh = YES;
    if ([[CommonUtil currentUtil] isLogin:NO]){
        [self refreshData];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isRefresh = NO;
}

- (void)refreshData{
    if(isRefresh){
        [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
        [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self pullToRefreshTriggered:self.pullToRefresh];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kCoinRecordList;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"CoinRecordListTableViewCell";
    CoinRecordListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CoinRecordListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    //receivertype :0平台 1驾校 2教练 3学员
    NSString *receivertype = @"2";
    NSString *ownername = @"光大驾校";
    NSString *payertype = @"0";
    NSString *coinnum = @"10";
    NSString *addtime = @"2017-07-28";
    NSString *payername = @"测试数据";
    
    NSString *coinFrom = [[NSString alloc]init];//小巴币支付方
    NSString *coinWay = [[NSString alloc]init];//小巴币方式
    NSString *coinTime = [[NSString alloc]init];//小巴币记录时间
    NSString *coinNumStr = [[NSString alloc]init];//小巴币额度
    
    
    
    coinTime = [NSString stringWithFormat:@"%@",addtime];
    
    if ([receivertype intValue] == 2) {
        if ([payertype intValue] == 0) {
            coinFrom = @"支付方：小巴平台";
        }else if ([payertype intValue] == 1){
            coinFrom = @"支付方：驾校";
        }else if ([payertype intValue] == 2){
            NSDictionary *dic1 = [CommonUtil getObjectFromUD:@"userInfo"];
            coinFrom = [NSString stringWithFormat:@"支付方：%@教练",[dic1[@"realname"] description]];
        }else if ([payertype intValue] == 3){
            if (payername) {
                coinFrom =[NSString stringWithFormat:@"支付方：%@",payername];
            }else{
                coinFrom =@"支付方：学员";
            }
        }
        coinNumStr = [NSString stringWithFormat:@"+%@",coinnum];
        coinWay = @"订单支付";
        cell.cheakBtn.hidden = YES;
    }
    if ([payertype intValue] == 2) {
        coinFrom = [NSString stringWithFormat:@"发放方：%@",ownername];
        coinNumStr = [NSString stringWithFormat:@"-%@",coinnum];
        coinWay = @"小巴币兑换";
        cell.cheakBtn.hidden = NO;
        [cell.cheakBtn addTarget:self action:@selector(clickForCheak:) forControlEvents:UIControlEventTouchUpInside];
        cell.cheakBtn.tag = indexPath.row;
    }
    cell.coinForm.text = coinFrom;
    cell.coinTime.text = coinTime;
    cell.coinNum.text = coinNumStr;
    cell.coinType.text = coinWay;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)clickForCheak:(UIButton *)button
{
    NSString *receivertype = @"教练";
    NSString *ownername = @"光大驾校";
    NSString *payertype = @"测试数据";
    NSString *coinnum = @"10";
    NSString *addtime = @"2017-07-28";
    NSString *payername = @"测试数据";
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSDictionary *dic = coinRecordList[button.tag];
    NSString *coinrecordid = [dic[@"coinrecordid"] description];
    //将兑换单号补齐到11位
    NSMutableString *string1 = [[NSMutableString alloc]init];
    if (coinrecordid.length <11) {
        for (int i=0; i<11-coinrecordid.length; i++) {
            [string1 appendString:@"0"];
        }
    }
    [string1 appendString:coinrecordid];
    coinrecordid = string1;
    self.convertID.text = [NSString stringWithFormat:@"兑换订单号：%@",@"123456"];
    self.convertPeople.text = [NSString stringWithFormat:@"兑换人：%@",@"你才是我谁"];
    self.ownerLabel.text = [NSString stringWithFormat:@"发放方：%@",@"中华任命共和国"];
    self.convertCount.text = [NSString stringWithFormat:@"兑换数量：%@个",@"无限"];
    self.moneyCount.text = [NSString stringWithFormat:@"折算金额：%@元",@"无限"];
    self.orderTime.text = [NSString stringWithFormat:@"申请时间：%@",@"随意"];
    self.cheakView.frame = self.view.frame;
    [self.view addSubview:self.cheakView];
}
- (IBAction)clickForClose:(id)sender {
    [self.alertView removeFromSuperview];
}

#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
    //    NSLog(@"%f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y <= 5) {
        [self getDataFinish];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    pageNum = 0;
    [self getCoinRecord];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getCoinRecord];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    [timer invalidate];
    [self.view endEditing:YES];
}

//- (void) textFieldDidChange:(UITextField *) TextField{
//    if (self.coinNumTextfield.text.length >0) {
//        [self.convertBtn1 setEnabled:YES];
//    }
//    else {
//        [self.convertBtn1 setEnabled:NO];
//    }
//}

- (IBAction)clickForCloseAlertView:(id)sender {
    [self.cheakView removeFromSuperview];
}

//兑换规则
- (IBAction)clickForRule:(id)sender {
    self.ruleView.frame = self.view.frame;
    [self.view addSubview:self.ruleView];
}
- (IBAction)removeRuleView:(id)sender {
    [self.ruleView removeFromSuperview];
}

- (IBAction)clickForConvertCoin:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定兑换所有小巴币吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    UIButton *button = (UIButton *)sender;
    buttonTag = [NSString stringWithFormat:@"%ld",(long)button.tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self getAPPLYCOIN];
    }
}

#pragma mark - 接口
- (void)getAPPLYCOIN  //兑换小巴币
{
    
  }

- (void)getCoinRecord  //小巴币获取记录
{

}

//更新余额
- (void)updateMoney{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
   
}

- (NSDictionary *)massageDic:(NSDictionary *)dic {
    NSString *realname = @"石";
    NSString *type = @"1";
    NSString *titleLabelStr;
    NSMutableAttributedString *string;
    NSString *coinnum = [dic[@"coin"] description];//小巴币个数
    if ([type intValue] == 0) {
        titleLabelStr = [NSString stringWithFormat:@"平台小巴币：%@个",@"100"];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(6,coinnum.length)];
    }else if ([type intValue] == 1){
        titleLabelStr = [NSString stringWithFormat:@"所属驾校小巴币：%@个",@"100"];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8,coinnum.length)];
    }else if ([type intValue] == 2){
        titleLabelStr = [NSString stringWithFormat:@"石教练小巴币：%@个",@"200"];
        string = [[NSMutableAttributedString alloc] initWithString:titleLabelStr];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(realname.length+6,coinnum.length)];
    }
    
    NSDictionary *messageDic = [NSDictionary dictionaryWithObjectsAndKeys:string,@"string",coinnum,@"coin",type,@"type", nil];
    
    return messageDic;
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
