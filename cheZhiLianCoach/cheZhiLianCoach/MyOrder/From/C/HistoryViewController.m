//
//  HistoryViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "DSButton.h"
#import "UIPlaceHolderTextView.h"
#import "GoComplaintViewController.h"
#import "TQStarRatingView.h"
#import "LoginViewController.h"

@interface HistoryViewController ()<UITableViewDataSource, UITableViewDelegate, DSBottomPullToMoreManagerClient, DSPullToRefreshManagerClient, UITextViewDelegate, StarRatingViewDelegate>{
    int pageNum;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) IBOutlet UIView *myCommentDetailsView;        // 我的评价详情
@property (strong, nonatomic) IBOutlet UIView *studentCommentDetailsView;   // 学员评价详情
@property (strong, nonatomic) IBOutlet UIButton *noDataBtn;//没有数据按钮

//学员评价
@property (strong, nonatomic) IBOutlet UIView *studentStarView;
@property (strong, nonatomic) TQStarRatingView *studentStarRatingView;//学员星级
@property (strong, nonatomic) IBOutlet UILabel *studentScoreLabel;//学员综合评分
@property (strong, nonatomic) IBOutlet UITextView *studentTextView;//学员评价内容

//我的评价
@property (strong, nonatomic) IBOutlet UILabel *myScoreLabel;//我的综合评分
@property (strong, nonatomic) IBOutlet UIView *myStarView1;//评分1
@property (strong, nonatomic) IBOutlet UIView *myStarView2;
@property (strong, nonatomic) IBOutlet UIView *myStarView3;
@property (strong, nonatomic) IBOutlet UITextView *myTextView;//我的评价内容
@property (strong, nonatomic) TQStarRatingView *myStarRatingView1;
@property (strong, nonatomic) TQStarRatingView *myStarRatingView2;
@property (strong, nonatomic) TQStarRatingView *myStarRatingView3;

//评分星星
@property (strong, nonatomic) IBOutlet UIView *scoreStarView3;
@property (strong, nonatomic) IBOutlet UIView *scoreStarView2;
@property (strong, nonatomic) IBOutlet UIView *scoreStarView1;
@property (strong, nonatomic) TQStarRatingView *starRatingView1;
@property (strong, nonatomic) TQStarRatingView *starRatingView2;
@property (strong, nonatomic) TQStarRatingView *starRatingView3;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel1;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel2;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel3;

@property (strong, nonatomic) IBOutlet UIView *goCommentView;           // 去点评view
@property (strong, nonatomic) IBOutlet UIView *commentBottomView;       // 评价弹窗下半部分
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *commentTextView;
@property (strong, nonatomic) IBOutlet DSButton *gouBtn;        // 勾
@property (strong, nonatomic) IBOutlet UIView *commentContentView;      // 评价的内部内容View

//参数
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (strong, nonatomic) NSMutableDictionary *scoreDic;//分数
@property (strong, nonatomic) NSMutableArray *taskList;                 //任务信息
@property (strong, nonatomic) NSMutableDictionary *rowDic;                 // 每一行的状态list
@property (strong, nonatomic) NSMutableArray *nowTaskList;//这一页的任务单数据
@property (strong, nonatomic) NSIndexPath *closeIndexPath;//关闭的indexPath
@property (strong, nonatomic) NSIndexPath *openIndexPath;//打开的indexPath

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    //参数初始化
    self.taskList = [NSMutableArray array];
    self.rowDic = [NSMutableDictionary dictionary];
    self.scoreDic = [NSMutableDictionary dictionary];
    self.noDataBtn.hidden = YES;
    
    self.commentTextView.delegate = self;
    
    self.nowTaskList = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.pullToMore setPullToMoreViewVisible:NO];
 
    [self addStartEvaluate];
    //设置默认分数
    [self.scoreDic setObject:@"5" forKey:@"score1"];
    [self.scoreDic setObject:@"5" forKey:@"score2"];
    [self.scoreDic setObject:@"5" forKey:@"score3"];
    
    }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
    [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self pullToRefreshTriggered:self.pullToRefresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addStartEvaluate{
    //添加评价页面
    self.starRatingView1 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView1.bounds numberOfStar:5];
    self.starRatingView1.couldClick = YES;//可点击
    self.starRatingView1.delegate = self;
    self.starRatingView1.isFill = YES;//整数显示
//    [self.starRatingView1 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView1 addSubview:self.starRatingView1];
    
    
    self.starRatingView2 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView2.bounds numberOfStar:5];
    self.starRatingView2.couldClick = YES;//可点击
    self.starRatingView2.delegate = self;
    self.starRatingView2.isFill = YES;//整数显示
//    [self.starRatingView2 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView2 addSubview:self.starRatingView2];
    
    self.starRatingView3 = [[TQStarRatingView alloc] initWithFrame:self.scoreStarView3.bounds numberOfStar:5];
    self.starRatingView3.couldClick = YES;//可点击
    self.starRatingView3.isFill = YES;//整数显示
    self.starRatingView3.delegate = self;
//    [self.starRatingView3 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.scoreStarView3 addSubview:self.starRatingView3];
    
    
    //我的评价详情
    self.myStarRatingView1 = [[TQStarRatingView alloc] initWithFrame:self.myStarView1.bounds numberOfStar:5];
    self.myStarRatingView1.couldClick = NO;//可点击
    self.myStarRatingView1.delegate = self;
    self.myStarRatingView1.isFill = NO;//整数显示
//    [self.myStarRatingView1 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.myStarView1 addSubview:self.myStarRatingView1];
    
    
    self.myStarRatingView2 = [[TQStarRatingView alloc] initWithFrame:self.myStarView2.bounds numberOfStar:5];
    self.myStarRatingView2.couldClick = NO;//可点击
    self.myStarRatingView2.delegate = self;
    self.myStarRatingView2.isFill = NO;//整数显示
//    [self.myStarRatingView2 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.myStarView2 addSubview:self.myStarRatingView2];
    
    self.myStarRatingView3 = [[TQStarRatingView alloc] initWithFrame:self.myStarView3.bounds numberOfStar:5];
    self.myStarRatingView3.couldClick = NO;//可点击
    self.myStarRatingView3.isFill = NO;//整数显示
    self.myStarRatingView3.delegate = self;
//    [self.myStarRatingView3 changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.myStarView3 addSubview:self.myStarRatingView3];
    
//    self.myTextView.delegate = self;
//    [self.myTextView setEditable:NO];
//    self.myTextView.textColor = [UIColor whiteColor];
//    self.myTextView.font = [UIFont systemFontOfSize:24];
//    self.myTextView.textAlignment = NSTextAlignmentCenter;
    
    //学员评价详情
    self.studentStarRatingView = [[TQStarRatingView alloc] initWithFrame:self.studentStarView.bounds numberOfStar:5];
    self.studentStarRatingView.couldClick = NO;//可点击
    self.studentStarRatingView.isFill = NO;//整数显示
    self.studentStarRatingView.delegate = self;
//    [self.studentStarRatingView changeStarForegroundViewWithPoint:CGPointMake(0, 0)];
    [self.studentStarView addSubview:self.studentStarRatingView];
    
//    self.studentTextView.delegate = self;
//    [self.studentTextView setEditable:NO];
//    self.studentTextView.textColor = [UIColor whiteColor];
//    self.studentTextView.font = [UIFont systemFontOfSize:24];
//    self.studentTextView.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"row%ld", indexPath.row];
    NSString *state = [self.rowDic objectForKey:key];
    if ([state intValue] == 1) {
        return 274;
    }else{
        //关闭
        return 70;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"historyCell";
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"HistoryTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    NSString *date = @"2017-8-21";//日期
    NSString *startTime = @"2017-06-22";
    NSString *endTime = @"2017-8-21";
    NSString *total = @"测试";
    //头像
    NSString *logo = @"logo.jpg";
    NSString *studentState = @"1";//0.未认证 1.认证.
    
    if ([studentState intValue] == 1) {
        //已认证
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image != nil) {
                cell.logoImageView.layer.cornerRadius = cell.logoImageView.bounds.size.width/2;
                cell.logoImageView.layer.masksToBounds = YES;

                
            }
        }];
        
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }else{
        cell.logoImageView.image = [UIImage imageNamed:@"logo_default_nopass"];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }
    
    //格式化日期
    if ([CommonUtil isEmpty:startTime]) {
        startTime = @"00:00";
    }else{
        startTime = [CommonUtil getStringForDate:[CommonUtil getDateForString:startTime format:@"yyyy-MM-dd HH:mm:ss"] format:@"HH:mm"];
    }
    if ([CommonUtil isEmpty:endTime]) {
        endTime = @"00:00";
    }else{
        endTime = [CommonUtil getStringForDate:[CommonUtil getDateForString:endTime format:@"yyyy-MM-dd HH:mm:ss"] format:@"HH:mm"];
    }
    
    //支付方式   1：现金 2：小巴券 3：小巴币
    NSString *paytype = @"1";
    if ([paytype intValue] == 1) {
        cell.payerType.hidden = NO;
        cell.payerType.image = [UIImage imageNamed:@"moneyPay-90"];
    }else if ([paytype intValue] == 2) {
        cell.payerType.hidden = NO;
        cell.payerType.image = [UIImage imageNamed:@"couponPay-90"];
    }else if ([paytype intValue] == 3) {
        cell.payerType.hidden = NO;
        cell.payerType.image = [UIImage imageNamed:@"coinPay-90"];
    }else{
        cell.payerType.hidden = YES;
    }
    
    //是否是陪驾订单
    NSString *subjectname = @"1";
    if (subjectname.length == 0 || !subjectname) {
        cell.accompanyDriveBtn.hidden = YES;
        cell.rentLabel.hidden = YES;
    }else{
        cell.accompanyDriveBtn.hidden = NO;
        cell.rentLabel.hidden = NO;
        //陪驾是否需要教练带车
        NSString *attachcar = @"1";
        if ([attachcar boolValue]) {
            cell.rentLabel.text = @"教练带车";
        }else{
            cell.rentLabel.text = @"学员带车";
        }
    }
    
    //任务时间
    NSString *time = [NSString stringWithFormat:@"%@ %@~%@  %@元", date, startTime, endTime,total];
    NSMutableAttributedString *timeStr = [[NSMutableAttributedString alloc] initWithString:time];
    [timeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(date.length + 1, startTime.length)];
    [timeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(time.length - endTime.length- total.length - 3, endTime.length)];
    [timeStr addAttribute:NSForegroundColorAttributeName value:MColor(210, 210, 210) range:NSMakeRange(time.length - endTime.length - total.length - 4, 1)];
    [timeStr addAttribute:NSForegroundColorAttributeName value:MColor(32, 180, 120) range:NSMakeRange(time.length - total.length - 1, total.length)];
    [timeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(time.length - total.length - 1, total.length)];
    cell.timeLabel.attributedText = timeStr;
    
    //地址
    NSString *address = @"杭州市上城区婺江路望江家园西园";
    cell.addressLabel.text = address;
    
    NSString *key = [NSString stringWithFormat:@"row%ld", indexPath.row];
    NSString *state = [self.rowDic objectForKey:key];
    if ([state intValue] == 1) {
        //打开
//        cell.studentDetailsView.hidden = NO;
        [self showDetailsCell:cell];
        
        /*****  详细信息  ******/
        
        // 投诉
        NSString *phone =@"13646712075";
        cell.complaintBtn.phone = phone;
        [cell.complaintBtn addTarget:self action:@selector(complaintClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 联系
        cell.contactBtn.phone = phone;
        [cell.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //姓名
        NSString *name = @"张**";
//        cell.nameLabel.text = [NSString stringWithFormat:@"学员姓名 %@", name];
        [cell.nameButton setTitle:[NSString stringWithFormat:@"学员姓名 %@", name] forState:UIControlStateNormal];
        [cell.nameButton setBackgroundColor:[UIColor clearColor]];
        //判断学员是否评价过
        NSDictionary *studentScoreDic =nil;
        if (studentScoreDic == nil || studentScoreDic.count == 0) {
            //没有评价过
            [cell.nameButton setImage:[UIImage imageNamed:@"学员未评"] forState:UIControlStateNormal];
        }else{
            //已经评价过
            [cell.nameButton setImage:[UIImage imageNamed:@"学员已评"] forState:UIControlStateNormal];
        }
        [cell.nameButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -54, 0, 54)];
        [cell.nameButton setImageEdgeInsets:UIEdgeInsetsMake(0, cell.nameButton.titleLabel.bounds.size.width, 0, -cell.nameButton.titleLabel.bounds.size.width)];
        
        //联系电话
        cell.phoneLabel.text = [NSString stringWithFormat:@"联系电话 %@", phone];
        
        //学员证号
        NSString *cardNum =@"903hsy3jff72y1jfk";
        cell.studentNumLabel.text = [NSString stringWithFormat:@"学员证号 %@", cardNum];
        
        //判断我是否已经评价过
        NSDictionary *coachDic = nil;
        if (coachDic == nil || coachDic.count == 0) {
            //没有评价过
            cell.goCommentClick.hidden = NO;
            cell.myCommentDetailsBtn.hidden = YES;
        }else{
            //已经评价过
            cell.goCommentClick.hidden = YES;
            cell.myCommentDetailsBtn.hidden = NO;
            
            //设置星级
            NSString *starNum = [coachDic[@"score"] description];
            [cell.myStarRatingView changeStarForegroundViewWithPoint:CGPointMake([starNum doubleValue]/5*CGRectGetWidth(cell.myStarView.frame), 0)];
            
        }
        
        
        cell.myCommentDetailsBtn.tag = indexPath.row;
        [cell.myCommentDetailsBtn addTarget:self action:@selector(myCommentDetailShow:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.studentCommentDetailsBtn.tag = indexPath.row;
        [cell.studentCommentDetailsBtn addTarget:self action:@selector(studentCommentDetailsShow:) forControlEvents:UIControlEventTouchUpInside];
        [cell.goCommentClick addTarget:self action:@selector(goCommentStudent) forControlEvents:UIControlEventTouchUpInside];
        NSString *disagree = @"1"; //学员取消订单，但是教练没有同意
        if ([disagree boolValue]) {
            cell.cancelLabel.hidden = NO;
            cell.myCommentDetailsBtn.hidden = YES;
            cell.goCommentClick.hidden = YES;
            cell.studentTitleLabel.hidden = YES;
        }else{
            cell.cancelLabel.hidden = YES;
        }
    }else{
        //关闭
//        cell.studentDetailsView.hidden = YES;
        [self hideDetailsCell:cell];
    }
    NSString *disagree = @"1"
    ; //学员取消订单，但是教练没有同意
    if ([disagree boolValue]) {
        cell.backgroundColor = MColor(253, 243, 144);
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndexPath = indexPath;
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
    if (self.openIndexPath == nil || [self.openIndexPath isEqual:indexPath]) {
        //本来这一行就是打开状态或者所有行都处于关闭状态
        self.openIndexPath = indexPath;
        
        NSString *key = [NSString stringWithFormat:@"row%ld", (long)indexPath.row];
        NSString *state = [self.rowDic objectForKey:key];
        if ([state intValue] == 1){
            //打开状态，变成关闭状态
            [self.rowDic setObject:@"0" forKey:key];//设置为关闭状态
        }else{
            //关闭状态，变成打开状态
            [self.rowDic setObject:@"1" forKey:key];//设置为打开状态
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        //这一行不是打开状态,打开这一行
        self.closeIndexPath = self.openIndexPath;
        self.openIndexPath = indexPath;
        
        NSString *key = [NSString stringWithFormat:@"row%ld", (long)indexPath.row];
        NSString *state = [self.rowDic objectForKey:key];
        if ([state intValue] == 1){
            //打开状态，变成关闭状态
            [self.rowDic setObject:@"0" forKey:key];//设置为关闭状态
        }else{
            //关闭状态，变成打开状态
            [self.rowDic setObject:@"1" forKey:key];//设置为打开状态
        }
        
        key = [NSString stringWithFormat:@"row%ld", (long)self.closeIndexPath.row];
        [self.rowDic setObject:@"0" forKey:key];//设置为关闭状态
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.closeIndexPath, self.openIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    [tableView reloadData];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]
                           animated:YES
                     scrollPosition:UITableViewScrollPositionMiddle];
}

//更新用户头像，显示六边形
- (void)updateUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}

//更新未通过验证用户头像，显示六边形
- (void)updateNoPassUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [UIImage imageNamed:@"logo_default_nopass"];
}


// details收起
- (void)hideDetailsCell:(HistoryTableViewCell *)cell
{
    cell.studentDetailsView.hidden = YES;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_right"];
    cell.iconTop.constant = 32;
    cell.iconRight.constant = 11;
    cell.iconWidth.constant = 9;
    cell.iconHeight.constant = 15;
}

// details展开
- (void)showDetailsCell:(HistoryTableViewCell *)cell
{
    cell.studentDetailsView.hidden = NO;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_down"];
    cell.iconTop.constant = 35;
    cell.iconRight.constant = 8;
    cell.iconWidth.constant = 14;
    cell.iconHeight.constant = 9;
}

#pragma mark - Button Action
// 联系
- (void)contactClick:(DSButton *)sender
{
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
}

// 投诉
- (void)complaintClick:(DSButton *)sender
{
//    GoComplaintViewController *viewController = [[GoComplaintViewController alloc] initWithNibName:@"GoComplaintViewController" bundle:nil];
//    viewController.taskReasonId = sender.tag;
//    [self.navigationController pushViewController:viewController animated:YES];
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
}

// 我的评价详情
- (void)myCommentDetailShow:(UIButton *)sender
{
    
    if (sender.tag >= self.taskList.count) {
        return;
    }
    NSDictionary *dic = [self.taskList objectAtIndex:sender.tag];
    NSDictionary *coachscore = dic[@"coachscore"];
    
    //设置星级
    [self.myStarRatingView1 changeStarForegroundViewWithPoint:CGPointMake([coachscore[@"score1"] doubleValue]/5*CGRectGetWidth(self.myStarView1.frame), 0)];
    [self.myStarRatingView2 changeStarForegroundViewWithPoint:CGPointMake([coachscore[@"score2"] doubleValue]/5*CGRectGetWidth(self.myStarView2.frame), 0)];
    [self.myStarRatingView3 changeStarForegroundViewWithPoint:CGPointMake([coachscore[@"score3"] doubleValue]/5*CGRectGetWidth(self.myStarView3.frame), 0)];
    
    NSString *score = [coachscore[@"score"] description];
    score = [CommonUtil isEmpty:score]?@"0":score;
    self.myScoreLabel.text = [NSString stringWithFormat:@"综合评分%@分", score];
    
    //设置评价
    self.myTextView.text = coachscore[@"content"];
    [self.myTextView scrollsToTop];
    
    
    self.myCommentDetailsView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.myCommentDetailsView];
    
}

//移除我的评价详情
- (IBAction)removeMyCommentDetails:(UIButton *)sender
{
    
    [self.myCommentDetailsView removeFromSuperview];
    [self.studentCommentDetailsView removeFromSuperview];
}

// 学员评价详情
- (void)studentCommentDetailsShow:(UIButton *)sender
{
    if (sender.tag >= self.taskList.count) {
        return;
    }
    NSDictionary *dic = [self.taskList objectAtIndex:sender.tag];
    NSDictionary *studentscore = dic[@"studentscore"];
    
    //设置星级
    [self.studentStarRatingView changeStarForegroundViewWithPoint:CGPointMake([studentscore[@"score"] doubleValue]/5*CGRectGetWidth(self.studentStarView.frame), 0)];
    
    NSString *score = [studentscore[@"score"] description];
    score = [CommonUtil isEmpty:score]?@"0":score;
    self.studentScoreLabel.text = [NSString stringWithFormat:@"综合评分%@分", score];
    
    //设置评价
    self.studentTextView.text = studentscore[@"content"];
    [self.studentTextView scrollsToTop];
    
    self.studentCommentDetailsView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.studentCommentDetailsView];
}

#pragma mark 去点评事件
// 给学员评价
- (void)goCommentStudent
{
    self.goCommentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.goCommentView];
}

#pragma mark 取消评价
- (IBAction)cancelComment:(id)sender {
    [self.goCommentView removeFromSuperview];
    [self clearEvaluate];
}

#pragma mark 提交评价
- (IBAction)sureComment:(id)sender {
    NSString *str = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (str.length == 0) {
//        [self makeToast:@"请说点什么吧。。"];
//        return;
//    }
    
    //判断该学员是否填写过资料
    NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.row];
    
    [self ComfirmComment:str orderId:[dic[@"orderid"] description]];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.gouBtn.enabled = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

#pragma mark - StarRatingViewDelegate
-(void)starRatingView:(TQStarRatingView *)view score:(float)score{
    NSString *scoreStr = [NSString stringWithFormat:@"%.f", score*5];
    if ([view isEqual:self.starRatingView1]) {
        
        self.scoreLabel1.text = [NSString stringWithFormat:@"学习态度%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score1"];
        
    }else if ([view isEqual:self.starRatingView2]){
        
        self.scoreLabel2.text = [NSString stringWithFormat:@"技能掌握%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score2"];
    }else if ([view isEqual:self.starRatingView3]){
        
        self.scoreLabel3.text = [NSString stringWithFormat:@"遵章守时%@分", scoreStr];
        [self.scoreDic setObject:scoreStr forKey:@"score3"];
    }
    
    self.gouBtn.enabled = YES;
}

#pragma mark - 键盘监听
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)notification {
    //    scrollFrame = self.view.frame;
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.frame;
    
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
    CGRect textFrame = self.commentTextView.superview.frame;
    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame) + self.commentContentView.frame.origin.y + 10;
    
    if(textFieldY < keyboardTop){
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    newTextViewFrame.origin.y = keyboardTop - textFieldY;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.goCommentView.frame = newTextViewFrame;
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.goCommentView.frame = self.view.frame;
    [UIView commitAnimations];
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.commentTextView resignFirstResponder];
}

#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    pageNum = 0;
    [self getTaskList];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getTaskList];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
//    if (self.taskList.count == 0) {
//        self.noDataBtn.hidden = NO;
//    }else{
//        self.noDataBtn.hidden = YES;
//    }
}

#pragma mark - 接口
- (void)getTaskList{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
  }

#pragma mark 提交评论
- (void)ComfirmComment:(NSString *)comment orderId:(NSString *)orderId{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
      [DejalBezelActivityView activityViewForView:self.view];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - private
//清空评价信息
- (void)clearEvaluate{
    [self.starRatingView1 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView1.frame), 0)];
    [self.starRatingView2 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView2.frame), 0)];
    [self.starRatingView3 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView3.frame), 0)];
    
    self.scoreLabel1.text = @"学习态度5分";
    self.scoreLabel2.text = @"技能掌握5分";
    self.scoreLabel3.text = @"遵章守时5分";
    
    self.commentTextView.text = @"";
    self.gouBtn.enabled = NO;
}
@end
