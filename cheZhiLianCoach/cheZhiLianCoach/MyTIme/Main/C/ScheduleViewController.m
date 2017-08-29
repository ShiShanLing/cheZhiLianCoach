//
//  ScheduleViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DateButton.h"
#import "DSPullToRefreshManager.h"
#import "ScheduleSettingViewController.h"
#import "SetAddrViewController.h"
#import "CustomTabBar.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CoachInfoViewController.h"

#define TIME_BLOCKWEITH SCREEN_WIDTH/320*66 // 时间块的宽度
#define TIME_BLOCKHIGTH SCREEN_WIDTH/320*70 // 时间块的高度

@interface ScheduleViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, CustomTabBarDelegate, UIAlertViewDelegate>{
    BOOL isCloseDate;
    CGRect dateFrame;
    BOOL isShowCalendar;
    BOOL isReload2Section;
    BOOL isUpdateDate;
    BOOL needRefresh;
    int maxdays;
    BOOL needSetDefault;
    BOOL firstIN;
    
    BOOL showAlert;
}

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *leftBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightBtn;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) UIView *dateView;//日历vieww
@property (strong, nonatomic) UIView *monthDayView;//月份view
@property (strong, nonatomic) IBOutlet UIView *weekView;//日期栏
@property (strong, nonatomic) UIButton *openBtn;

@property (strong, nonatomic) DSPullToRefreshManager *refreshManager;//下拉刷新

//订单是否可以取消
@property (strong, nonatomic) IBOutlet UIView *orderMsgView;
@property (strong, nonatomic) IBOutlet UILabel *orderDescLabel;
@property (strong, nonatomic) IBOutlet UISwitch *orderSwitch;
@property (strong, nonatomic) IBOutlet UILabel *openOrCloseLabel;
@property (strong, nonatomic) IBOutlet UISwitch *openOrCloseSwitch;

//参数
@property (strong, nonatomic) NSMutableArray *DefaultSchedule;//默认的课程安排
@property (strong, nonatomic) NSMutableArray *calenderArray;
@property (strong, nonatomic) NSDate *nowDate;
@property (strong, nonatomic) NSDate *selectDate;//选中的日期
@property (strong, nonatomic) NSDate *endDate;//结束时间
@property (strong, nonatomic) NSMutableArray *selectTimeArray;//选中的时间 8:00,9:00
@property (strong, nonatomic) NSMutableArray *allTimeArray;//早上
@property (strong, nonatomic) NSMutableArray *morningAllTimeArray;//早上
@property (strong, nonatomic) NSMutableArray *afternoonAllTimeArray;//下午
@property (strong, nonatomic) NSMutableArray *eveningAllTimeArray;//晚上
@property (strong, nonatomic) NSString *cancelPermission;
@property (strong, nonatomic) NSString *nowHour;//现在时间点

@property (strong, nonatomic) IBOutlet UIButton *setDefaultButton;

- (IBAction)clickForSetDefaultCheck:(id)sender;

/*
 calenderDic 格式
 date: 日期
 list: 时间点数组
 
 */
@property (strong, nonatomic) NSMutableDictionary *calenderDic;


@property (strong, nonatomic) NSMutableDictionary *stateDic;//时间状态对象

@property (strong, nonatomic) IBOutlet UIView *defaultAlertView;
@property (strong, nonatomic) IBOutlet UIButton *defaultSetButton;
@property (strong, nonatomic) IBOutlet UIButton *defaultCancelButton;

- (IBAction)clickForDefaultAlert:(id)sender;   //设为默认开课   弃用

@property (strong, nonatomic) IBOutlet UIView *openOrCloseClassView;
@property (strong, nonatomic) IBOutlet UIButton *writeScheduleButton;
@property (strong, nonatomic) IBOutlet UIButton *sureIssueButton;
@property (strong, nonatomic) IBOutlet UIButton *stopClassButton;

@property (strong, nonatomic) IBOutlet DateButton *allSelectButton;
@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cancelPermission = @"1";//默认不可设置
    isUpdateDate = YES;
    maxdays = 9;
    needSetDefault = NO;
    self.calenderDic = [NSMutableDictionary dictionary];
    self.nowDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:[NSDate date] format:@"yyyy-MM-dd"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    self.selectDate = self.nowDate;
    self.endDate = [CommonUtil addDate2:self.nowDate year:0 month:0 day:maxdays];
    self.startTime = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
    self.dateLabel.text = [CommonUtil getStringForDate:self.nowDate format:@"yyyy年M月"];
    isCloseDate = NO;
    isShowCalendar = YES;
    isReload2Section = NO;//显示第二行的sectionHeader
    self.selectTimeArray = [NSMutableArray array];
    self.morningAllTimeArray = [NSMutableArray arrayWithObjects:@"5:00", @"6:00", @"7:00", @"8:00", @"9:00", @"10:00", @"11:00", nil];
    self.afternoonAllTimeArray = [NSMutableArray arrayWithObjects:@"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00",nil];
    self.eveningAllTimeArray = [NSMutableArray arrayWithObjects:@"19:00", @"20:00", @"21:00", @"22:00", @"23:00", nil];
    self.allTimeArray = [NSMutableArray arrayWithObjects:@"5:00", @"6:00", @"7:00", @"8:00", @"9:00", @"10:00", @"11:00",@"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00",@"19:00", @"20:00", @"21:00", @"22:00", @"23:00", nil];
    [self initViews];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;

    [self showTableHeaderView];
    [self compareBeforeDate:self.selectDate nowDate:self.nowDate];
    
    //下拉刷新
    self.refreshManager = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.mainTableView withClient:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDaySchedule:) name:@"changeDaySchedule" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSchedule) name:@"refreshSchedule" object:nil];
    
    self.defaultSetButton.layer.cornerRadius = 5;
    self.defaultSetButton.layer.masksToBounds = YES;
    self.defaultCancelButton.layer.cornerRadius = 5;
    self.defaultCancelButton.layer.masksToBounds = YES;
    
    self.openOrCloseClassView.hidden = YES;
    self.writeScheduleButton.layer.cornerRadius = 5;
    self.writeScheduleButton.layer.masksToBounds = YES;
    self.writeScheduleButton.hidden = YES;
    self.sureIssueButton.layer.cornerRadius = 5;
    self.sureIssueButton.layer.masksToBounds = YES;
    self.sureIssueButton.hidden = YES;
    self.stopClassButton.layer.cornerRadius = 5;
    self.stopClassButton.layer.masksToBounds = YES;
    self.stopClassButton.hidden = YES;
    self.defaultAlertView.frame = CGRectMake(0, 0, kScreen_widht, kScreen_heigth);
    
    needRefresh = YES;
    firstIN = YES;
    
    [self.allSelectButton setTitleColor:MColor(28, 28, 28) forState:UIControlStateNormal];
    [self.allSelectButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.allSelectButton setImage:[UIImage imageNamed:@"btn_checkbox_unchecked"] forState:UIControlStateNormal];
    [self.allSelectButton setImage:[UIImage imageNamed:@"btn_checkbox_checked"] forState:UIControlStateSelected];
    [self.allSelectButton addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
    self.allSelectButton.date = @"-1";
    
}

//获取当日课程表
- (void)changeDaySchedule:(id)dictionary{
    needRefresh = NO;
    NSMutableArray *array = nil;
    if ([dictionary isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)dictionary;
        if ([CommonUtil isEmpty:notification.object]) {
            return;
        }
        array = [NSMutableArray arrayWithArray:notification.object];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.calenderArray];
        for (int i=0; i<self.calenderArray.count; i++) {
            NSDictionary *dic = self.calenderArray[i];
            NSString *date = dic[@"date"];
            NSString *hour = dic[@"hour"];
            for (int j=0; j<array.count; j++) {
                NSDictionary *arrayDic = array[j];
                NSString *arrayDate = arrayDic[@"date"];
                NSString *arrayHour = arrayDic[@"hour"];
                if ([date isEqualToString:arrayDate] && [hour isEqualToString:arrayHour]) {
                    [mutableArray replaceObjectAtIndex:i withObject:arrayDic];
                }
            }
        }
        self.calenderArray = mutableArray;
        
    } else {
        array = [NSMutableArray arrayWithArray:dictionary];
    }
    
    if (array != nil && array.count > 0) {
        [self handelDaySchedule:array];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    showAlert = YES;
    if (self.selectDate != nil) {
        NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        //获取数据
        if(needRefresh){
            [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];//手动下拉
            [self.refreshManager tableViewReloadStart:[NSDate date] Animated:YES];
            [self getScheduleList];
        }
    }
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    needRefresh = YES;
    
}


//刷新数据
- (void)refreshSchedule{
    if (self.mainTableView.contentOffset.y != 0) {
        [self.mainTableView setContentOffset:CGPointMake(0, 0)];
    }
    //获取数据
    if(needRefresh){
        [self.mainTableView setContentOffset:CGPointMake(0, -60) animated:YES];//手动下拉
        [self.refreshManager tableViewReloadStart:[NSDate date] Animated:YES];
        [self getScheduleList];
        self.openOrCloseClassView.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    needRefresh = NO;
}

- (void)initViews{
    
    //星期几frame
    int weekWidth = kScreen_widht / 7;
    
    //星期
    for (int i = 0; i < 7; i++) {
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*weekWidth, 0, weekWidth, 25)];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        weekLabel.textColor = MColor(136, 136, 136);
        weekLabel.font = [UIFont systemFontOfSize:12];
        [self.weekView addSubview:weekLabel];
        
        if (i == 0) {
            //日
            weekLabel.text = @"日";
        }else if (i == 1){
            //一
            weekLabel.text = @"一";
        }else if (i == 2){
            //二
            weekLabel.text = @"二";
        }else if (i == 3){
            //三
            weekLabel.text = @"三";
        }else if (i == 4){
            //四
            weekLabel.text = @"四";
        }else if (i == 5){
            //五
            weekLabel.text = @"五";
        }else if (i == 6){
            //六
            weekLabel.text = @"六";
        }
        
    }
    
    self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.openBtn setBackgroundColor:[UIColor blackColor]];
    [self.openBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    [self.openBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateSelected];
    [self.openBtn addTarget:self action:@selector(clickForOpenClose:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - tableView代理
#pragma mark tableSection
//section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//section高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat height = 0;
    
    int weekHeight = ceil(kScreen_widht / 7);
    
    height = weekHeight;
    
    if (!isShowCalendar) {
        //不显示日历
        height = 0;
    }
    if (section == 1) {
        if (!isReload2Section) {
            //不显示第二行的section
            height = 0;
        }else{
            NSDictionary * coachInfo = [CommonUtil getObjectFromUD:@"userInfo"];
            NSString *state = [coachInfo[@"state"] description];
            if (![state isEqualToString:@"2"]) {
                height += 16+32;
            }else{
                height += 16;
            }
            
        }
        
    }else{
        //
        if (isReload2Section) {
            //不显示第一行的section
            height = 0;
        }
    }
    return height;
}
//sectionHeader的样式
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;{
    
    /************** 日期栏 ****************/
    self.dateView = [[UIView alloc] init];
    /*****  日历页面  *****/
    
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    
    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    
    NSInteger weekCount = 1;
    long weekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(weekday-1)];//获取选中日期的星期天的日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //星期几frame
    int weekHeight = weekWidth;
    
    /*******  月份view ******/
    self.monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [self.dateView addSubview:self.monthDayView];
    
    CGFloat dayY = 0;
    
    for (int i = 0; i < weekCount*7; i++) {
        
        int index = -1;
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
            }
        }
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        int month = [CommonUtil getMonthOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        int status = 0;//0:正常工作，1：未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"] intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [self.monthDayView addSubview:view];
        
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    //日历view高度
    self.dateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.monthDayView.frame.origin.y + CGRectGetHeight(self.monthDayView.frame) + 16);
    if (isReload2Section && section == 1){
        self.openBtn.frame = CGRectMake(0, dayY, SCREEN_WIDTH, 16);
        [self.dateView addSubview:self.openBtn];
        NSDictionary * coachInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *state = [coachInfo[@"state"] description];
        if (![state isEqualToString:@"2"]) {
            UIView *signView = [[UIView alloc]initWithFrame:CGRectMake(0, dayY+16, SCREEN_WIDTH, 32)];
            signView.backgroundColor = MColor(249, 239, 210);
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20, 11, 6, 9)];
            imageView.image = [UIImage imageNamed:@"ic_arrowForSchedule"];
            [signView addSubview:imageView];
            UIButton *remindButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, signView.width, signView.height)];
            [remindButton addTarget:self action:@selector(clickCoachInfo) forControlEvents:UIControlEventTouchUpInside];
            remindButton.titleLabel.font = [UIFont systemFontOfSize:12];
            [remindButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [remindButton setTitle:@"     还未通过教练认证，学员无法找到您，马上认证" forState:UIControlStateNormal];
            [remindButton setTitleColor:MColor(252, 89, 0) forState:UIControlStateNormal];
            [signView addSubview:remindButton];
            [self.dateView addSubview:signView];
        }
    }
    self.dateView.backgroundColor = [UIColor blackColor];
    return self.dateView;
}
#pragma mark sectionFooterView
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        if (isReload2Section) {
            //不显示第一行的section
            return 0;
        }
        NSDictionary * coachInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *state = [coachInfo[@"state"] description];
        if (![state isEqualToString:@"2"]) {
            return 16+32;
        }else{
            return 16;
        }
        
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
//    view.backgroundColor = [UIColor blackColor];
    self.openBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 16);
    [view addSubview:self.openBtn];
    NSDictionary * coachInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *state = [coachInfo[@"state"] description];
    if (![state isEqualToString:@"2"]) {
        UIView *signView = [[UIView alloc]initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 32)];
        signView.backgroundColor = MColor(249, 239, 210);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20, 11, 6, 9)];
        imageView.image = [UIImage imageNamed:@"ic_arrowForSchedule"];
        [signView addSubview:imageView];
        UIButton *remindButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, signView.width, signView.height)];
        [remindButton addTarget:self action:@selector(clickCoachInfo) forControlEvents:UIControlEventTouchUpInside];
        remindButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [remindButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [remindButton setTitle:@"     还未通过教练认证，学员无法找到您，马上认证" forState:UIControlStateNormal];
        [remindButton setTitleColor:MColor(252, 89, 0) forState:UIControlStateNormal];
        [signView addSubview:remindButton];
        [view addSubview:signView];
    }
    return view;
}
#pragma mark tableHeaderView
//显示日期
- (void)showTableHeaderView{
    //如果选中的日期是第一周，那么就不需要tableHeaderView
    long selectWeek = [CommonUtil getWeekOfDate:self.selectDate];
    if (selectWeek == 1) {//是第一周
        self.mainTableView.tableHeaderView = nil;
        return;
    }
    
    /************** 日期栏 ****************/
    UIView *dateView = [[UIView alloc] init];
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    
    //获取1号所在星期的星期日的日期
    long weekday = [CommonUtil getWeekdayOfDate:firstDate];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:firstDate year:0 month:0 day:0-(weekday-1)];//获取星期天的日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取结束时间，选中日期所在周的前一个星期六
    long selectWeekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *endDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(selectWeekday)];//获取选中日期的星期六的日期
    endDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:endDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    //获取月初到结束日期相差几个礼拜,也就是获取结束日期在这个月第几周
    NSInteger weekCount = [CommonUtil getWeekOfDate:endDate];
    
    //星期几frame
    int weekHeight = weekWidth;
    
    /*******  月份view ******/
    UIView *monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [dateView addSubview:monthDayView];
    
    CGFloat dayY = 0;
    
    for (int i = 0; i < weekCount*7; i++) {
        
        int index = -1;
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
                break;
            }
        }
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        int month = [CommonUtil getMonthOfDate:beginDate];
        int status = 0;//全天状态 0开课  1未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"] intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [monthDayView addSubview:view];
        
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    
    //日历view高度
    dateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, monthDayView.frame.origin.y + CGRectGetHeight(monthDayView.frame));
    dateView.backgroundColor = [UIColor blackColor];
    self.mainTableView.tableHeaderView = dateView;
}
#pragma mark tableFooterView
- (void)showTableFooterView{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic != nil) {
        
        view.frame = CGRectMake(0, 100, SCREEN_WIDTH, self.openOrCloseClassView.frame.size.height);
        
        self.mainTableView.tableFooterView = view;
    }
}
#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        //剩下的日期
        NSDate *lastDate = [CommonUtil getLastDayOfDate:self.selectDate];
        long lastWeek = [CommonUtil getWeekOfDate:lastDate];
        long selectWeed = [CommonUtil getWeekOfDate:self.selectDate];
        return lastWeek - selectWeed;
    }else{
        return 3;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        int weekHeight = ceil(SCREEN_WIDTH / 7.0);
        return  weekHeight;
    }
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    if (indexPath.row == 0) {
        //+ 11 + 18  代表开课不开课标记的高度
        //上午
        return (TIME_BLOCKHIGTH + 3) * 2 + 36;//4行时间 第一个21底部注解与时间距离,22:注解的高度 18：注解跟下划线的距离
    }else if (indexPath.row == 1){
        //下午
        return (TIME_BLOCKHIGTH + 3) * 2 + 16;//4行时间
    }else {
        //晚上
        return (TIME_BLOCKHIGTH + 3) * 1 + 16;//3行时间
    }
    //    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForDateRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
    
    /************** 日期栏 ****************/
    //星期几frame
    int weekWidth = ceil(SCREEN_WIDTH / 7.0);
    
    //获取这一行的星期天所在日期
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    
    //获取1号所在星期的星期日的日期
    NSDate *date = [CommonUtil addDate2:self.selectDate year:0 month:0 day:7*(indexPath.row+1)];
    long weekday = [CommonUtil getWeekdayOfDate:date];//今天是星期几
    NSDate *beginDate = [CommonUtil addDate2:date year:0 month:0 day:0-(weekday-1)];//获取这一行的星期天所在日期
    beginDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取结束时间，选中日期所在周的前一个星期六
    long selectWeekday = [CommonUtil getWeekdayOfDate:self.selectDate];//今天是星期几
    NSDate *endDate = [CommonUtil addDate2:self.selectDate year:0 month:0 day:0-(selectWeekday-2)];//获取选中日期的星期六的日期
    endDate = [CommonUtil getDateForString:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd HH:mm:ss"] format:@"yyyy-MM-dd 00:00:00"];//格式化日期
    
    //获取月末时间
    NSDate *lastDate = [CommonUtil getLastDayOfDate:firstDate];
    //获取月初到结束日期相差几个礼拜,也就是获取结束日期在这个月第几周
    NSInteger weekCount = 1;
    
    //星期几frame
    int weekHeight = weekWidth;
    
    /*******  月份view ******/
    UIView *monthDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekCount*weekHeight)];
    [cell.contentView addSubview:monthDayView];
    
    CGFloat dayY = 0;
    
    for (int i = 0; i < weekCount*7; i++) {
        
        //判断日期
        NSInteger day = [CommonUtil getdayOfDate:beginDate];
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [CommonUtil getMonthOfDate:beginDate];
        
        int status = 0;//0:正常工作，1：未开课
        NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSDictionary dictionary];
        }
        NSArray *array = dic[@"list"];
        
        NSDictionary *stateDic = nil;
        for (NSDictionary *dateDic in array) {
            int hour = [dateDic[@"hour"] intValue];
            if (hour == 0) {
                stateDic = dateDic;
                break;
            }
        }
        
        if (stateDic == nil) {
            //没有全天状态，今天为开课状态
            status = 0;
        }else{
            int state = [stateDic[@"state"]intValue];//全天状态 0开课  1未开课
            if (state == 1) {
                status = 1;
            }else{
                status = 0;
            }
        }
        
        NSString *beginTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
        int index = -1;
        //获取该日期在数据的第几个位置
        for (int j = 0; j < self.calenderArray.count; j++) {
            NSString *dateStr = [self.calenderArray objectAtIndex:j];
            if ([beginTime isEqualToString:dateStr]){
                index = j;
                break;
            }
        }
        
        //画出日期画面
        UIView *view = [self showDateButtonView:weekWidth dayStr:dayStr beginDate:beginDate status:status index:index lastDate:lastDate firstDate:firstDate month:month];
        view.frame = CGRectMake(i%7*weekWidth, dayY, weekWidth, weekHeight);
        [monthDayView addSubview:view];
        
        beginDate = [CommonUtil addDate2:beginDate year:0 month:0 day:1];
        //计算Y轴距离
        if (i>0 && (i+1)%7==0) {
            dayY += weekHeight;
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //日期
        UITableViewCell *cell = [self tableView:tableView cellForDateRowAtIndexPath:indexPath];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeCell"];
    
    CGFloat y = 0;
    if (indexPath.row == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0)];
        view.backgroundColor = MColor(243, 243, 243);
        [cell.contentView addSubview:view];
        
        y = 0;
    }
    
    //上划线
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    underline.backgroundColor = MColor(244, 244, 244);
    [cell.contentView addSubview:underline];
    
    //获取数据
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    if (indexPath.row == 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120*2)/6, 10, 180, 11)];
        imageView.image = [UIImage imageNamed:@"notice_image"];
        [cell.contentView addSubview:imageView];
        NSDictionary *selectDic = dic[@"selectState"];
        NSString *allSelect = [selectDic objectForKey:@"allSelect"];//0:不是全选 1：全选
        //按钮状态//0:不是全选 1：全选
        if ([allSelect integerValue] == 0) {
            //是全选
            self.allSelectButton.selected = NO;
        }else{
            self.allSelectButton.selected = YES;
        }
        
        y = 20;
    }else{
        y = 0;
    }
    
    //显示按钮
    UIView *selectView = [[UIView alloc] init];//按钮区域
    [cell.contentView addSubview:selectView];
    
    //获取开始时间
    NSDate *date = [CommonUtil getDateForString:@"5:00" format:@"H:00"];
    if (indexPath.row == 1) {
        date = [CommonUtil getDateForString:@"13:00" format:@"H:00"];
    }else if (indexPath.row == 2){
        //晚上
        date = [CommonUtil getDateForString:@"20:00" format:@"H:00"];
    }
    
    /* ----   显示按钮   ------*/
    int count = 9; //7 个时间点 1个底部
    if (indexPath.row == 1) {
        //下午
        count = 8;
    }else if (indexPath.row == 2){
        //晚上
        count = 5;
    }
    
    CGFloat marginX = ceil((SCREEN_WIDTH - 120*2)/6);
    CGFloat buttonY = 6;
    
    //按钮状态
    NSString *key1 = @"selectState";
    NSDictionary *selectDic = [dic objectForKey:key1];
    for (int i = 0; i < count; i++) {
        
        if (i == count-1) {
        }else{
            if (i > 0 && i/4 >= 1) {
                buttonY = (TIME_BLOCKHIGTH+TIME_BLOCKWEITH/7*1.6);
            }else{
                buttonY = 6;
            }
            
            if (i > 0 && i%4 == 0) {
                marginX = ceil((SCREEN_WIDTH - 120*2)/6);
            }
            
            if (i > 0 && (i + 1) %4 == 0) {
                marginX = ceil((SCREEN_WIDTH - 120*2)/6)  + (TIME_BLOCKWEITH+10)*3;
            }
            
            if (i > 0 && (i + 2) %4 == 0) {
                marginX = ceil((SCREEN_WIDTH - 120*2)/6)  + (TIME_BLOCKWEITH+10)*2;
            }
            
            if (i > 0 && (i + 3) %4 == 0) {
                marginX = ceil((SCREEN_WIDTH - 120*2)/6)  + (TIME_BLOCKWEITH+10)*1;
            }
            
            //时间按
            NSString *time = [CommonUtil getStringForDate:date format:@"H:00"];
            date = [CommonUtil addTime:date hour:1 minute:0 second:0];
            
            /////////////////  时间view  /////////////////
            //时间view
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(marginX, buttonY, TIME_BLOCKWEITH, TIME_BLOCKHIGTH)];
            contentView.backgroundColor = [UIColor clearColor];
            
            [selectView addSubview:contentView];
            
            //时间
            UIView *timeDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TIME_BLOCKWEITH, CGRectGetHeight(contentView.frame))];
            timeDetailView.backgroundColor = MColor(174, 174, 174);
            timeDetailView.layer.cornerRadius = 4;
            timeDetailView.layer.borderColor = MColor(243, 243, 243).CGColor;
            [contentView addSubview:timeDetailView];
            
            //体验课
            UIImageView *experienceClassView = [[UIImageView alloc]initWithFrame:CGRectMake(TIME_BLOCKWEITH-22, TIME_BLOCKHIGTH-22, 22, 22)];
            experienceClassView.backgroundColor = [UIColor clearColor];
            experienceClassView.image = [UIImage imageNamed:@"体验课"];
            experienceClassView.hidden = YES;
            [contentView addSubview:experienceClassView];
            
            //时间显示
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (TIME_BLOCKHIGTH-62)/2, TIME_BLOCKWEITH, 26)];
            timeLabel.font = [UIFont systemFontOfSize:17];
            timeLabel.textAlignment = NSTextAlignmentCenter;
            
            timeLabel.textColor = MColor(68, 68, 68);
            timeLabel.text = time;
            [timeDetailView addSubview:timeLabel];
            
            UIImageView *selectLabel = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x + CGRectGetWidth(timeLabel.frame)-8, ceil((CGRectGetHeight(timeLabel.frame) - 14)/2)-8, 16, 16)];
            selectLabel.backgroundColor = [UIColor clearColor];
            selectLabel.image = [UIImage imageNamed:@"blackRight"];
            selectLabel.hidden = YES;
            [contentView addSubview:selectLabel];
            
            UIImageView *alreadyOrder = [[UIImageView alloc] initWithFrame:CGRectMake(-0.5, 0, 20, 20)];
            alreadyOrder.backgroundColor = [UIColor clearColor];
            alreadyOrder.image = [UIImage imageNamed:@"约"];
            alreadyOrder.hidden = YES;
            [contentView addSubview:alreadyOrder];
            
            //科目内容
            UILabel *teachTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,  timeLabel.height+timeLabel.y-6,CGRectGetWidth(timeDetailView.frame), 26)];
            
            teachTypeLabel.textColor = MColor(68, 68, 68);
            teachTypeLabel.textAlignment = NSTextAlignmentCenter;
            teachTypeLabel.font = [UIFont systemFontOfSize:13];
            NSString *subject = @"未设置";
            [contentView addSubview:teachTypeLabel];
            
            //价格显示
            UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(0, TIME_BLOCKHIGTH-20-(TIME_BLOCKHIGTH-62)/2, CGRectGetWidth(timeDetailView.frame), 16)];
            [contentView addSubview:priceView];
            
            //获取价格 和科目
            NSString *price = @"0";
            NSString *subjectid = @"0";
            NSString *isrest = @"2";
            NSString *bookedername = @"";
            NSString *isfreecourse;
            NSArray *array = dic[@"list"];
            NSString *timeStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:time format:@"H:00"] format:@"H"];
            for (NSDictionary *arrDic in array) {
                NSString *hour = arrDic[@"hour"];
                if ([timeStr intValue] == [hour intValue]) {
                    price = [arrDic[@"price"] description];
                    subject = [arrDic[@"subject"] description];
                    isrest = [arrDic[@"isrest"] description];
                    subjectid = [arrDic[@"subjectid"] description];
                    bookedername = [arrDic[@"bookedername"] description];
                    isfreecourse = [arrDic[@"isfreecourse"] description];
                    if ([CommonUtil isEmpty:subjectid]) {
                        subjectid = @"0";
                    }
                    if ([CommonUtil isEmpty:price]) {
                        price = @"0";
                    }else{
                        price = [NSString stringWithFormat:@"%.0f", [price floatValue]];
                    }
                    break;
                }
            }
//            if ([subjectid intValue]==1) {
//                subject = @"科目二";
//            }else if ([subjectid intValue]==2){
//                subject = @"科目三";
//            }else if ([subjectid intValue]==3){
//                subject = @"考场演练";
//            }
            teachTypeLabel.text = [NSString stringWithFormat:@"%@",subject];
            
            //价格label显示
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(priceView.frame), 26)];
            
            priceLabel.textColor = MColor(68, 68, 68);
            priceLabel.textAlignment = NSTextAlignmentCenter;
            priceLabel.font = [UIFont systemFontOfSize:13];
            priceLabel.text = [NSString stringWithFormat:@"￥%@", price];
            [priceView addSubview:priceLabel];
            
            //点击按钮
            DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame));
            button.tag = indexPath.row;
            button.date = time;
            button.isrest = isrest;
            button.index = [NSString stringWithFormat:@"%d", i];
            button.tag = indexPath.row;
            [button addTarget:self action:@selector(clickForChoose:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
            
            //按钮状态 0:全选 1：不是全选
            NSArray *selectArray = [selectDic objectForKey:@"selectArray"];
            NSArray *restArray = [selectDic objectForKey:@"restArray"];//未开课的时间
            for (NSString *selectTime in selectArray) {
                if ([time isEqualToString:selectTime]) {
                    button.selected = YES;
                    selectLabel.hidden = NO;
                }
            }
            
            if ([isfreecourse boolValue]) {
                experienceClassView.hidden = NO;
                experienceClassView.image = [UIImage imageNamed:@"体验课"];
            }else{
                experienceClassView.hidden = YES;
            }
            
            //设置已开课的时间
            NSMutableArray *unrestArray = [selectDic objectForKey:@"unrestArray"];//已开课时间
            for (NSString *unrestTime in unrestArray) {
                if ([time isEqualToString:unrestTime]) {
                    timeDetailView.backgroundColor = MColor(80, 203, 140);
                    timeLabel.textColor = [UIColor whiteColor];
                    priceLabel.textColor = MColor(22, 127, 83);
                    teachTypeLabel.textColor = MColor(22, 127, 83);
                    alreadyOrder.hidden = YES;
                    timeDetailView.layer.borderWidth = 0;
                    if ([subjectid intValue] == 4) {
                        timeDetailView.backgroundColor = MColor(60, 190, 250);
                        priceLabel.textColor = MColor(26, 116, 157);
                        teachTypeLabel.textColor = MColor(26, 116, 157);
                    }
                    if ([isfreecourse boolValue]) {
                        experienceClassView.image = [UIImage imageNamed:@"体验课"];
                    }
                }
            }
            
            //设置未开课的时间
            for (NSString *restTime in restArray) {
                if ([time isEqualToString:restTime]) {
                    button.selected = NO;
                    //未选中状态
//                    priceLabel.text = @"未开课";
                    timeDetailView.backgroundColor = MColor(174, 174, 174);
                    timeLabel.textColor = MColor(68, 68, 68);
                    priceLabel.textColor = MColor(68, 68, 68);
                    teachTypeLabel.textColor = MColor(68, 68, 68);
                    alreadyOrder.hidden = YES;
                    timeDetailView.layer.borderWidth = 0;
                    if ([isfreecourse boolValue]) {
                        experienceClassView.image = [UIImage imageNamed:@"体验课_停课"];
                    }
                }
            }
            
            
            //设置已过期的时间
            NSMutableArray *expireArray = [selectDic objectForKey:@"expireArray"];//已过期时间
            for (NSString *expire in expireArray) {
                if ([time isEqualToString:expire]) {
                    button.selected = NO;
                    
                    //未选中状态
                    priceLabel.text = @"已过期";
                    timeDetailView.backgroundColor = [UIColor clearColor];
                    timeLabel.textColor = MColor(185, 185, 185);
                    priceLabel.textColor = MColor(185, 185, 185);
                    teachTypeLabel.textColor = MColor(185, 185, 185);
                    alreadyOrder.hidden = YES;
                    timeDetailView.layer.borderWidth = 1;
                    experienceClassView.hidden = YES;
                }
            }
            
            //设置已约的时间
            NSMutableArray *bookArray = [selectDic objectForKey:@"bookArray"];//已约时间
            for (NSString *restTime in bookArray) {
                if ([time isEqualToString:restTime]) {
                    button.selected = YES;
                    selectLabel.hidden = YES;
                    timeDetailView.backgroundColor = MColor(239, 144, 60);
                    timeLabel.textColor = [UIColor whiteColor];
                    priceLabel.textColor = MColor(158, 85, 6);
                    if (bookedername.length>0) {
                        priceLabel.text = bookedername;
                    }
                    teachTypeLabel.textColor = MColor(158, 85, 6);
                    alreadyOrder.hidden = NO;
                    timeDetailView.layer.borderWidth = 0;
                    if ([isfreecourse boolValue]) {
                        experienceClassView.hidden = NO;
                        experienceClassView.image = [UIImage imageNamed:@"体验课"];
                    }
                }
            }
        }
    }
    buttonY = (18 + 66);
    selectView.frame = CGRectMake(0, y, SCREEN_WIDTH, buttonY*2);
//    selectView.backgroundColor = [UIColor redColor];
    //下一个控件的Y轴
    y = selectView.frame.origin.y + CGRectGetHeight(selectView.frame);
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//没有选中状态
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - scrollView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.refreshManager tableViewScrolled];
    
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    //CGFloat y = scrollView.contentOffset.y;
    if (scrollView.contentOffset.y >= 0){
        [self getDataFinish];
    }
    
    if (scrollView.contentOffset.y > weekHeight*(weekCount - 1)) {
        if (!isReload2Section) {
            //显示第二个sectionHeader隐藏第一个sectionHeader，造成选中行停留的效果
            isReload2Section = YES;
            [self.mainTableView reloadData];
        }
        
    }else{
        if (isReload2Section) {
            //显示第一个sectionHeader隐藏第二个sectionHeader，造成选中行打开的效果
            isReload2Section = NO;
            [self.mainTableView reloadData];
        }
    }
    
    if (scrollView.contentOffset.y > ceil(weekHeight*weekCount/2)
        && scrollView.contentOffset.y < weekHeight*weekCount+16) {
        //大于一半，收缩
        self.openBtn.selected = YES;//展开
        
    }else if (scrollView.contentOffset.y <= ceil(weekHeight*weekCount/2)){
        //小于一半，打开
        self.openBtn.selected = NO;//收缩
        
    }
    
}

#pragma mark - DSPullToRefreshManagerClient

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshManager tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    [self getScheduleList];
}

- (void)getDataFinish{
    [self.refreshManager tableViewReloadFinishedAnimated:YES];
}

#pragma mark - private
//比较日期查看上一个的按钮是否可以点击， 下一个日期是否可以点击
- (void)compareBeforeDate:(NSDate *)date1 nowDate:(NSDate *)nowDate{
    //判断下一个月是否可以点击
    NSDate *endDate = [CommonUtil addDate2:nowDate year:0 month:1 day:0];
    endDate = [CommonUtil getFirstDayOfDate:endDate];
    NSDate *endDate1 = [CommonUtil getFirstDayOfDate:date1];
    if ([endDate1 compare:endDate] == NSOrderedAscending) {
        //小于，可以点击
        self.rightBtn.selected = NO;
        self.rightBtn.userInteractionEnabled = YES;
    }else{
        self.rightBtn.selected = YES;
        self.rightBtn.userInteractionEnabled = NO;
    }
    
    //判断上一个月是否可以点击
    date1 = [CommonUtil getFirstDayOfDate:date1];
    nowDate = [CommonUtil getFirstDayOfDate:nowDate];
    
    if ([date1 compare:nowDate] == NSOrderedDescending) {
        //大于当前月
        self.leftBtn.selected = NO;
        self.leftBtn.userInteractionEnabled = YES;
        //选中日期默认1号
        self.selectDate = date1;
    }else{
        //当前月
        self.leftBtn.selected = YES;
        self.leftBtn.userInteractionEnabled = NO;
        //选中日期默认今天
        self.selectDate = self.nowDate;
    }
    
}

- (void)compareStartDate:(NSDate *)date1 endDate:(NSDate *)nowDate{
    //判断下一个月是否可以点击
    NSDate *endDate = [CommonUtil addDate2:date1 year:0 month:1 day:0];
    endDate = [CommonUtil getFirstDayOfDate:endDate];
    NSDate *endDate1 = [CommonUtil addDate2:nowDate year:0 month:1 day:0];
    endDate1 = [CommonUtil getFirstDayOfDate:endDate1];
    if ([endDate compare:endDate1] == NSOrderedAscending) {
        //小于，可以点击
        self.rightBtn.selected = NO;
        self.rightBtn.userInteractionEnabled = YES;
    }else{
        self.rightBtn.selected = YES;
        self.rightBtn.userInteractionEnabled = NO;
    }
    
    //判断上一个月是否可以点击
    date1 = [CommonUtil getFirstDayOfDate:date1];
    nowDate = [CommonUtil getFirstDayOfDate:nowDate];
    
    if ([date1 compare:nowDate] == NSOrderedDescending) {
        //大于当前月
        self.leftBtn.selected = NO;
        self.leftBtn.userInteractionEnabled = YES;
        //选中日期默认1号
        self.selectDate = date1;
    }else{
        //当前月
        self.leftBtn.selected = YES;
        self.leftBtn.userInteractionEnabled = NO;
        //选中日期默认今天
        self.selectDate = self.nowDate;
    }
    
}

//更新选中的时间区间描述
- (void)updateSelectTimeDesc{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSMutableArray *list = [NSMutableArray arrayWithArray:dic[@"list"]];
    for (int i=0; i<list.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:list[i]];
        NSString *isrest = [dic[@"isrest"] description];
        NSString *isfreecourse = [dic[@"isfreecourse"] description];
        if ([isrest intValue] && ![isfreecourse boolValue]) {
            if (self.DefaultSchedule.count > 0) {
                for (int j=0; j<self.DefaultSchedule.count; j++) {
                    NSDictionary *defaultDic = self.DefaultSchedule[j];
                    if ([defaultDic[@"hour"] isEqualToString:[dic[@"hour"] description]]) {
                        [dic setValue:[defaultDic[@"price"] description] forKey:@"price"];
                        [dic setValue:[defaultDic[@"subjectid"] description] forKey:@"subjectid"];
                        [dic setValue:[defaultDic[@"subject"] description] forKey:@"subject"];
                        [dic setValue:[defaultDic[@"addressid"] description] forKey:@"addressid"];
                        [dic setValue:[defaultDic[@"addressdetail"] description] forKey:@"addressdetail"];
                        [dic setValue:[defaultDic[@"cuseraddtionalprice"] description] forKey:@"cuseraddtionalprice"];
                        [list replaceObjectAtIndex:i withObject:dic];
                    }
                }
            }
           }else{
            
        }
    }
    [dic setObject:list forKey:@"list"];
    NSMutableArray *oldArray = [NSMutableArray arrayWithArray:self.calenderArray];
    for (int k=0; k<self.calenderArray.count; k++) {
        NSDictionary *dic = self.calenderArray[k];
        NSString *date = [dic[@"date"] description];
        NSString *dicHour = [dic[@"hour"] description];
        for (int f=0; f<list.count; f++) {
            NSDictionary *changeDic = list[f];
            NSString *changeDate = [changeDic[@"date"] description];
            NSString *changeHour = [changeDic[@"hour"] description];
            if ([date isEqualToString:changeDate] && [dicHour isEqualToString:changeHour]) {
                [oldArray replaceObjectAtIndex:k withObject:changeDic];
            }
        }
    }
    
    self.calenderArray = oldArray;
    for (int i = 0; i < 1; i++) {
        //获取该行的选中状态
        NSString *key = @"selectState";
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
        
        //获取该行是否是全选
        NSString *allState = [selectDic objectForKey:@"allSelect"];
        if ([allState intValue] == 0) {
            //全选
            [dic setObject:@"5:00~23:00" forKey:@"allday"];
        }else{
            //不是全选
            
            //获取该行选中的时间
            NSMutableArray *restArray = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restArray"]];//未开课的日期
            NSMutableArray *array = [NSMutableArray array];
            array = [NSMutableArray arrayWithArray:self.morningAllTimeArray];
            [array removeObjectsInArray:restArray];//工作的时间
            
            NSString *descTime = @"";
            NSString *startTime = @"";
            NSString *endTime = @"";
            if (array.count == 0) {
                descTime = @"未开课";
            }else{
                
                for (int i = 0; i < array.count; i++) {
                    NSString *selectTime = array[i];
                    
                    if (i == 0) {
                        descTime = selectTime;
                        startTime = selectTime;
                        
                    } else{
                        //下一个日期
                        NSString *beforeTime = array[i - 1];
                        NSString *beforeH = [CommonUtil getStringForDate:[CommonUtil getDateForString:beforeTime format:@"H:00"] format:@"H"];
                        NSString *selectH = [CommonUtil getStringForDate:[CommonUtil getDateForString:selectTime format:@"H:00"] format:@"H"];
                        
                        if ([selectH intValue] - [beforeH intValue] == 1) {
                            //选中日期比上一个选中日期相差一个小时，表示这个是连续的时间
                            if (i == array.count-1) {
                                //最后一个时间
                                endTime = selectTime;
                                if (![startTime isEqualToString:endTime]) {
                                    //开始时间跟结束时间不一致,表示是一个区间
                                    descTime = [NSString stringWithFormat:@"%@~%@", descTime, endTime];
                                }else{
                                    //开始时间跟结束时间一致，代表要/分割
                                    descTime = [NSString stringWithFormat:@"%@/%@", descTime, selectTime];
                                    
                                }
                            }
                        }else{
                            //选中日期比上一个选中日期相差超过一个小时，表示这个不是连续的时间
                            //结束时间为上一个时间
                            endTime = array[i - 1];
                            if (![startTime isEqualToString:endTime]) {
                                //开始时间跟结束时间不一致,表示是一个区间
                                descTime = [NSString stringWithFormat:@"%@~%@/%@", descTime, endTime, selectTime];
                                
                            }else{
                                //开始时间跟结束时间一致，代表要/分割
                                descTime = [NSString stringWithFormat:@"%@/%@", descTime, selectTime];
                                
                            }
                            startTime = selectTime;
                            
                        }
                    }
                }
            }
            
            NSString *timeKey = @"allday";
            [dic setObject:descTime forKey:timeKey];
        }
    }
    NSString *isrestTag = @"NO";
    for (int i=0; i<list.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:list[i]];
        NSString *isrest = [dic[@"isrest"] description];
        if ([isrest intValue]) {
            
        }else{
            isrestTag = @"YES";
        }
    }
    NSString *key = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
    [array removeAllObjects];
    NSArray *bookArray = [selectDic objectForKey:@"bookArray"];//已经预约时间点集合
    NSArray *expireArray = [selectDic objectForKey:@"expireArray"];//已过期时间点集合
    if ([isrestTag isEqualToString:@"NO"]) {
        if (self.DefaultSchedule.count > 0) {
                for (int j=0; j<self.DefaultSchedule.count; j++) {
                    NSDictionary *defaultDic = self.DefaultSchedule[j];
                        NSString *defaultIsrest = [defaultDic[@"isrest"] description];
                        if (![defaultIsrest intValue]) {
                            NSDate *date = [CommonUtil getDateForString:[defaultDic[@"hour"] description] format:@"HH"];
                            NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                            [array addObject:str];
                        }
                }
            [array removeObjectsInArray:bookArray];
            [array removeObjectsInArray:expireArray];
        }
    }
    [selectDic setObject:array forKey:@"selectArray"];
    [dic setObject:selectDic forKey:@"selectState"];
    [self.calenderDic setObject:dic forKey:chooseTime];
    
}

#pragma mark - action
//点击查看日期详细   选择日期
- (void)clickForDetail:(DateButton *)button{
    NSString *date = button.date;
    self.selectDate = [CommonUtil getDateForString:date format:@"yyyy-MM-dd"];
    [self testOpenOrCloseView];
    [self getDefaultSchedule];
}

- (void)clickCoachInfo
{
    CoachInfoViewController *nextViewController = [[CoachInfoViewController alloc]initWithNibName:@"CoachInfoViewController" bundle:nil];
    nextViewController.superViewNum = @"1";
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)testOpenOrCloseView
{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSString *key1 = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
    if (array.count == 0) {
        self.openOrCloseClassView.hidden = YES;
    }else{
        NSMutableArray *unrestArray = [NSMutableArray arrayWithArray:selectDic[@"unrestArray"]];
        if ([unrestArray containsObject:array[0]]) {
            self.writeScheduleButton.hidden = YES;
            self.sureIssueButton.hidden = YES;
            self.stopClassButton.hidden = NO;
            //全选按钮
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:@" 全选（已开课）"];
            [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(3, 5)];
            [str1 addAttribute:NSForegroundColorAttributeName value:MColor(68, 68, 68) range:NSMakeRange(0,8)];
            [self.allSelectButton setAttributedTitle:str1 forState:UIControlStateNormal];
            self.allSelectButton.date = @"-2";
        }
        NSMutableArray *restArray = [NSMutableArray arrayWithArray:selectDic[@"restArray"]];
        if ([restArray containsObject:array[0]]) {
            self.writeScheduleButton.hidden = NO;
            self.sureIssueButton.hidden = NO;
            self.stopClassButton.hidden = YES;
            //全选按钮
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:@" 全选（未开课）"];
            [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(3, 5)];
            [str1 addAttribute:NSForegroundColorAttributeName value:MColor(68, 68, 68) range:NSMakeRange(0,8)];
            [self.allSelectButton setAttributedTitle:str1 forState:UIControlStateNormal];
            self.allSelectButton.date = @"-1";
        }
        self.openOrCloseClassView.hidden = NO;
    }
}

//切换月份
- (IBAction)clickForChangeDate:(id)sender {
    [self getDefaultSchedule];
    
    isCloseDate = NO;
    self.openBtn.selected = NO;
    UIButton *button = (UIButton *)sender;
    
    NSDate *date = [CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"];
    date = [CommonUtil getFirstDayOfDate:date];
    
    if (button.tag == 0) {
        //上一个月
        date = [CommonUtil addDate2:date year:0 month:-1 day:0];
        
        self.startTime = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    }else{
        //下一个月
        
        date = [CommonUtil addDate2:date year:0 month:1 day:0];
        
        self.startTime = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    }
    
    self.dateLabel.text = [CommonUtil getStringForDate:date format:@"yyyy年M月"];
    [self compareBeforeDate:date nowDate:self.nowDate];
    
    [self handelSelectDateDetail];//处理数据
    
    [self.mainTableView reloadData];
    [self showTableFooterView];
    [self showTableHeaderView];
    [self testOpenOrCloseView];
}

//打开或者关闭日历
- (void)clickForOpenClose:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    if (button.selected) {
        //收缩状态,显示一行日期
        //打开日期栏
        [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        //打开状态，显示全部日期
        //关闭日期栏
        [self.mainTableView setContentOffset:CGPointMake(0, (weekCount - 1)*weekHeight) animated:YES];
    }
    
    button.selected = !button.selected;
    [self showTableFooterView];
    
}

//停课
- (IBAction)clickForStop:(id)sender{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    //修改改天日程状态
    [self updateSchedateState:@"2"];//修改的状态1.全天开课 2.全天未开课
    
}

//开课
- (void)clickForStart:(id)sender{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    //修改改天日程状态
    [self updateSchedateState:@"1"];//修改的状态1.全天开课 2.全天未开课
    
}

//选择时间（）
- (void)clickForChoose:(DateButton *)button{
    [self testOpenOrCloseView];
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSString *key1 = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *bookArray = [selectDic objectForKey:@"bookArray"];
    NSMutableArray *unrestArray = [selectDic objectForKey:@"unrestArray"];
    NSMutableArray *restArray = [selectDic objectForKey:@"restArray"];
    NSString *time = button.date;
    if ([@"-1" isEqualToString:time]) {
        //全选
        NSString *allSelect = selectDic[@"allSelect"];
        if ([allSelect intValue] == 1) {
            //全选，变成全不选
            [selectDic setObject:@"0" forKey:@"allSelect"];//1:全选 0：不是全选
            [selectDic setObject:[NSArray array] forKey:@"selectArray"];
        }else{
            //不是全选，变成全选
            [selectDic setObject:@"1" forKey:@"allSelect"];//1:全选 0：不是全选
            
            NSMutableArray *array = nil;
            array = [NSMutableArray arrayWithArray:self.allTimeArray];
            if (array == nil) {
                array = [NSMutableArray array];
            }
            
            //移除已经预约的
            [array removeObjectsInArray:bookArray];
            //移除已经预约的
            [array removeObjectsInArray:unrestArray];
            
            //移除当前时间之前的日期
            if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
                //小于当天
                [array removeAllObjects];
                [self makeToast:@"没有可以选择的时间点"];
                return;
                
            }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
                //等于当天
                NSArray *hourArray = [NSArray arrayWithArray:array];
                for (NSString *hour in hourArray) {
                    NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:hour format:@"H:00"] format:@"H"];
                    
                    if ([hourStr intValue] <= [self.nowHour intValue]) {
                        [array removeObject:hour];
                    }
                    
                }
                
            }
            
            if (array.count == 0) {
                //没有可以选择的日期
                [self makeToast:@"没有可以选择的时间点"];
                return;
            }
            [selectDic setObject:array forKey:@"selectArray"];
        }
        self.writeScheduleButton.hidden = NO;
        self.sureIssueButton.hidden = NO;
        self.stopClassButton.hidden = YES;
        
    }else if ([@"-2" isEqualToString:time]) {
        //全选
        NSString *allSelect = selectDic[@"allSelect"];
        if ([allSelect intValue] == 1) {
            //全选，变成全不选
            [selectDic setObject:@"0" forKey:@"allSelect"];//1:全选 0：不是全选
            [selectDic setObject:[NSArray array] forKey:@"selectArray"];
        }else{
            //不是全选，变成全选
            [selectDic setObject:@"1" forKey:@"allSelect"];//1:全选 0：不是全选
            
            NSMutableArray *array = nil;
            array = [NSMutableArray arrayWithArray:self.allTimeArray];
            if (array == nil) {
                array = [NSMutableArray array];
            }
            
            //移除已经预约的
            [array removeObjectsInArray:bookArray];
            //移除已经预约的
            [array removeObjectsInArray:restArray];
            
            //移除当前时间之前的日期
            if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
                //小于当天
                [array removeAllObjects];
                [self makeToast:@"没有可以选择的时间点"];
                return;
                
            }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
                //等于当天
                NSArray *hourArray = [NSArray arrayWithArray:array];
                for (NSString *hour in hourArray) {
                    NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:hour format:@"H:00"] format:@"H"];
                    
                    if ([hourStr intValue] <= [self.nowHour intValue]) {
                        [array removeObject:hour];
                    }
                    
                }
                
            }
            
            if (array.count == 0) {
                //没有可以选择的日期
                [self makeToast:@"没有可以选择的时间点"];
                return;
            }
            [selectDic setObject:array forKey:@"selectArray"];
        }
        self.writeScheduleButton.hidden = YES;
        self.sureIssueButton.hidden = YES;
        self.stopClassButton.hidden = NO;
        
    }else{
        [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

        [selectDic setObject:@"0" forKey:@"allSelect"];//0:不是全选 1：全选
        
        //移除已经预约的
        if ([bookArray containsObject:time]) {
            [self makeToast:@"该时间点已被预约不可选择"];
            return;
        }
        
        //移除当前时间之前的日期
        if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
            //小于当天
            [self makeToast:@"该时间点不可选择"];
            return;
            
        }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
            //等于当天
            NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:time format:@"H:00"] format:@"H"];
            if ([hourStr intValue] <= [self.nowHour intValue]) {
                [self makeToast:@"该时间点不可选择"];
                return;
            }
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
        if ([array  containsObject:time]) {
            //包含，就移除
            [array removeObject:time];
        }else{
            //不包含，就添加
            if (array.count > 1) {
                if ([button.isrest intValue] == 1) {
                    NSMutableArray *unrestArray = [NSMutableArray arrayWithArray:selectDic[@"unrestArray"]];
                    
                    if ([unrestArray containsObject:array[0]]) {
                        [self makeToast:@"未开课和已开课不能同时选择"];
                        return;
                    }else{
                        [array addObject:time];
                    }
                }else if([button.isrest intValue] == 0){
                    NSMutableArray *restArray = [NSMutableArray arrayWithArray:selectDic[@"restArray"]];
                    if ([restArray containsObject:array[0]]) {
                        [self makeToast:@"未开课和已开课不能同时选择"];
                        return;
                    }else{
                        [array addObject:time];
                    }
                }
                
            }else if(array.count ==1){
                if ([button.isrest intValue] == 1) {
                    NSMutableArray *unrestArray = [NSMutableArray arrayWithArray:selectDic[@"unrestArray"]];
                    
                    if ([unrestArray containsObject:array[0]]) {
                        [array removeAllObjects];
                        [array addObject:time];
                    }else{
                        [array addObject:time];
                    }
                }else if([button.isrest intValue] == 0){
                    NSMutableArray *restArray = [NSMutableArray arrayWithArray:selectDic[@"restArray"]];
                    if ([restArray containsObject:array[0]]) {
                        [array removeAllObjects];
                        [array addObject:time];
                    }else{
                        [array addObject:time];
                    }
                }
            }else{
                [array addObject:time];
            }
            
            
        }
        if (array.count > 0) {
            self.openOrCloseClassView.hidden = NO;
        }
        if ([button.isrest intValue] == 0) {
            self.writeScheduleButton.hidden = YES;
            self.sureIssueButton.hidden = YES;
            self.stopClassButton.hidden = NO;
        }else if([button.isrest intValue] == 1){
            self.writeScheduleButton.hidden = NO;
            self.sureIssueButton.hidden = NO;
            self.stopClassButton.hidden = YES;
        }
        
        NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *str1 = (NSString *)obj1;
            NSString *str2 = (NSString *)obj2;
            str1 = [CommonUtil getStringForDate:[CommonUtil getDateForString:str1 format:@"H:00"] format:@"H"];
            str2 = [CommonUtil getStringForDate:[CommonUtil getDateForString:str2 format:@"H:00"] format:@"H"];
            
            if ([str1 intValue] > [str2 intValue]) {
                //小于
                return NSOrderedDescending;
            }else if ([str1 intValue] == [str2 intValue]){
                return NSOrderedSame;
            }else{
                return NSOrderedAscending;
            }
        }];
        [selectDic setObject:sortArray forKey:@"selectArray"];
        if (sortArray.count == 0) {
            self.openOrCloseClassView.hidden = YES;
            self.writeScheduleButton.hidden = YES;
            self.sureIssueButton.hidden = YES;
            self.stopClassButton.hidden = YES;
        }
    }
    if (button.isrest) {  //判断是不是由全选按钮过来
        if ([button.isrest intValue] == 0) {
            //全选按钮
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:@" 全选（已开课）"];
            [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(3, 5)];
            [str1 addAttribute:NSForegroundColorAttributeName value:MColor(68, 68, 68) range:NSMakeRange(0,8)];
            [self.allSelectButton setAttributedTitle:str1 forState:UIControlStateNormal];
            self.allSelectButton.date = @"-2";
        }else if([button.isrest intValue] == 1){
            //全选按钮
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc]initWithString:@" 全选（未开课）"];
            [str1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(3, 5)];
            [str1 addAttribute:NSForegroundColorAttributeName value:MColor(68, 68, 68) range:NSMakeRange(0,8)];
            [self.allSelectButton setAttributedTitle:str1 forState:UIControlStateNormal];
            self.allSelectButton.date = @"-1";
        }
    }
    
    [dic setObject:selectDic forKey:key1];
    NSArray *selectArray = selectDic[@"selectArray"];
    if (selectArray.count > 0) {
        self.openOrCloseClassView.hidden = NO;
    }else{
        self.openOrCloseClassView.hidden = YES;
    }
    
    [self.calenderDic setObject:dic forKey:chooseTime];
    [self testOpenOrCloseView];
    [self.mainTableView reloadData];
}

//打开或者关闭日程
- (void)clickForChangeSchedule:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [NSString stringWithFormat:@"row%ld", (long)button.tag];
    NSString *state = [dic objectForKey:key];
    if ([@"1" isEqualToString:state]) {
        state = @"0";//关闭
        
        //获取该行的选中状态
        NSString *stateKey = @"selectState";
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:stateKey]];
        [dic setObject:selectDic forKey:stateKey];
        
        [self updateSelectTimeDesc];//更新日期描述
    }else{
        state = @"1";//打开
    }
    [dic setObject:state forKey:key];//时间状态 0:关闭 1：打开
    
    [self.calenderDic setObject:dic forKey:chooseTime];
    
    [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:1]]  withRowAnimation:UITableViewRowAnimationFade];
    
    [self checkSlideDown];
}

- (void)checkSlideDown{
    int weekHeight = ceil(SCREEN_WIDTH / 7);
    NSDate *firstDate = [CommonUtil getFirstDayOfDate:[CommonUtil getDateForString:self.startTime format:@"yyyy-MM-dd"]];//获取月初时间
    //获取本月有几周
    NSInteger weekCount = [CommonUtil getWeekCountOfDate:firstDate];
    if (self.mainTableView.contentOffset.y > weekHeight*(weekCount - 1)) {
        if (!isReload2Section) {
            //显示第二个sectionHeader隐藏第一个sectionHeader，造成选中行停留的效果
            isReload2Section = YES;
            [self.mainTableView reloadData];
        }
    }else{
        if (isReload2Section) {
            //显示第一个sectionHeader隐藏第二个sectionHeader，造成选中行打开的效果
            isReload2Section = NO;
            [self.mainTableView reloadData];
        }
    }
}

#pragma mark 批量设置
- (IBAction)clickForUpdateTime:(id)sender{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *cityid = [userInfo[@"cityid"] description];
    if (cityid.length == 0 || !cityid) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请先设置您所在的城市" delegate:self cancelButtonTitle:@"前去设置" otherButtonTitles: @"取消",nil];
        alert.tag = 1;
        [alert show];
        return;
    }
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    //获取选中的日期
    NSString *time = @"";
    NSString *firstTime = @"";
    NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];//获取选中日期的对象
    //获取对应时间段的选中状态
    NSString *key = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
    
    NSMutableArray *selectArray = selectDic[@"selectArray"];//选中的时间点集合
    for (NSString *str in selectArray) {
        if ([CommonUtil isEmpty:time]) {
            time = str;
            firstTime = str;//获取第一个时间点，用来获取该时间点的具体数据
        }else{
            time = [NSString stringWithFormat:@"%@、%@", time, str];
        }
        
    }
    
    if ([CommonUtil isEmpty:time]){
        [self makeToast:@"请选择修改时间点"];
        return;
    }
    //获取第一个时间点的具体数据
    NSDate *strDate = [CommonUtil getDateForString:firstTime format:@"HH:00"];
    NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
    for (NSDictionary *arrDic in array) {
        NSString *timeStr = [arrDic[@"hour"] description];
        if ([hourStr intValue] == [timeStr intValue]) {
            //获取该日期的具体数据
            timeDic = [NSMutableDictionary dictionaryWithDictionary:arrDic];
            break;
        }
    }
    
    
    ScheduleSettingViewController *nextController = [[ScheduleSettingViewController alloc] initWithNibName:@"ScheduleSettingViewController" bundle:nil];
    nextController.time = time;
    nextController.timeDic = timeDic;
    nextController.date = chooseTime;
    nextController.allDayArray = array;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark 点击单个设置
- (void)clickForSetting:(DateButton *)button{
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    //获取时间点的具体数据
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    
    NSString *key1 = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *bookArray = selectDic[@"bookArray"];
    
    NSDictionary *timeDic = [NSDictionary dictionary];
    
    NSDate *strDate = [CommonUtil getDateForString:button.date format:@"HH:00"];
    NSString *hourStr = [CommonUtil getStringForDate:strDate format:@"H"];
    
    //判断已经预约的
    if ([bookArray containsObject:button.date]) {
        [self makeToast:@"该时间点已被预约不可修改"];
        return;
    }
    
    //移除当前时间之前的日期
    if ([self.selectDate compare:self.nowDate] == NSOrderedAscending) {
        //小于当天
        [self makeToast:@"该时间点不可选择"];
        return;
        
    }else if ([self.selectDate compare:self.nowDate] == NSOrderedSame) {
        //等于当天
        NSString *hourStr = [CommonUtil getStringForDate:[CommonUtil getDateForString:button.date format:@"H:00"] format:@"H"];
        if ([hourStr intValue] <= [self.nowHour intValue]) {
            [self makeToast:@"该时间点不可修改"];
            return;
        }
        
    }
    
    for (NSDictionary *arrDic in array) {
        NSString *hour = [arrDic[@"hour"] description];
        if ([hourStr isEqualToString:hour]) {
            timeDic = arrDic;
            break;
        }
    }
    
    ScheduleSettingViewController *nextController = [[ScheduleSettingViewController alloc] initWithNibName:@"ScheduleSettingViewController" bundle:nil];
    nextController.time = button.date;
    nextController.timeDic = timeDic;
    nextController.date = chooseTime;
    [self.navigationController pushViewController:nextController animated:YES];
}

- (IBAction)clickForTodayOPenClose:(id)sender{
    if(self.defaultAlertView.superview){
        [self.defaultAlertView removeFromSuperview];
    }
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    if (array.count == 0) {
        [self makeToast:@"数据获取中，请稍候"];
        return;
    }
    BOOL allrest = YES;
    for (int i = 1; i<array.count-1; i++) {
        NSDictionary *dic = array[i];
        NSString *isrest = [dic[@"isrest"] description];
        if (isrest.intValue == 0) {
            allrest = NO;
            break;
        }
    }
//    if (allrest) {
//        [self makeToast:@"至少有一节课是开课状态才能发布"];
//    }else{
        [self.view addSubview:self.defaultAlertView];
//    }
}

#pragma mark - 接口
//获取日程安排
- (void)getScheduleList{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
 
    needRefresh = NO;
}
//更新该天日程的状态， state：修改的状态1.全天开课 2.全天未开课
- (void)updateSchedateState:(NSString *)state{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
   
    [DejalBezelActivityView activityViewForView:self.view];
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
//获取默认课程设置
- (void)getDefaultSchedule{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    NSString *cityid = [userInfo[@"cityid"] description];
    if (cityid.length == 0 || !cityid) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请先设置您所在的城市" delegate:self cancelButtonTitle:@"前去设置" otherButtonTitles: @"取消",nil];
        
        [alert show];
        return;
    }
  
    [DejalBezelActivityView activityViewForView:self.view];
}


- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonIndex%ld", (long)buttonIndex);
    
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            //跳转至地址列表画面
            SetAddrViewController *nextViewController = [[SetAddrViewController alloc] initWithNibName:@"SetAddrViewController" bundle:nil];
            nextViewController.fromSchedule = @"1";
            [self.navigationController pushViewController:nextViewController animated:YES];

        }else{
            
        }
        
    }else {
        if (buttonIndex == 0) {
            CoachInfoViewController *nextViewController = [[CoachInfoViewController alloc] initWithNibName:@"CoachInfoViewController" bundle:nil];
            nextViewController.superViewNum = @"1";
            [self.navigationController pushViewController:nextViewController animated:YES];
                    }else{
            
        }
    }
    
    
}
#pragma mark - private
//整理数据
- (void)handelCalender{
    NSArray *array = [NSArray arrayWithArray:self.calenderArray];
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        NSString *date1 = dic1[@"date"];
        NSString *date2 = dic2[@"date"];
        return [date1 compare:date2];
    }];
    
    
    NSString *date = @"";
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *calenderArray = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSDictionary *dic = [sortArray objectAtIndex:i];
        NSString *arrayDate = dic[@"date"];
        
        if (i == 0) {
            date = arrayDate;
        }
        
        if ([date isEqualToString:arrayDate]) {
            //相同日期
            [dataArray addObject:dic];
        }else{
            //不同日期
            NSMutableDictionary *dateDic = [self.calenderDic objectForKey:date];
            if (dateDic == nil) {
                dateDic = [NSMutableDictionary dictionary];
            }
            [dateDic setObject:date forKey:@"date"];
            [dateDic setObject:[NSArray arrayWithArray:dataArray] forKey:@"list"];
            
            //设置每一行的状态
            if ([CommonUtil isEmpty:dateDic[@"row0"]]) {
                [dateDic setObject:@"0" forKey:@"row0"];//上午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row1"]]) {
                [dateDic setObject:@"0" forKey:@"row1"];//下午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row2"]]) {
                [dateDic setObject:@"0" forKey:@"row2"];//晚上状态 0:关闭 1：打开
            }
            
            [calenderArray addObject:dateDic];
            [self.calenderDic setObject:dateDic forKey:date];
            
            [dataArray removeAllObjects];
            date = arrayDate;
            [dataArray addObject:dic];
        }
        
        if (i == sortArray.count - 1) {
            NSMutableDictionary *dateDic = [self.calenderDic objectForKey:date];
            if (dateDic == nil) {
                dateDic = [NSMutableDictionary dictionary];
            }
            [dateDic setObject:date forKey:@"date"];
            [dateDic setObject:[NSArray arrayWithArray:dataArray] forKey:@"list"];
            
            //设置每一行的状态
            if ([CommonUtil isEmpty:dateDic[@"row0"]]) {
                [dateDic setObject:@"0" forKey:@"row0"];//上午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row1"]]) {
                [dateDic setObject:@"0" forKey:@"row1"];//下午状态 0:关闭 1：打开
            }
            if ([CommonUtil isEmpty:dateDic[@"row2"]]) {
                [dateDic setObject:@"0" forKey:@"row2"];//晚上状态 0:关闭 1：打开
            }
            
            
            [self.calenderDic setObject:dateDic forKey:date];
            [calenderArray addObject:dateDic];
        }
    }
    
    //判断是否是全选
    NSMutableDictionary *sortDic = [NSMutableDictionary dictionaryWithDictionary:self.calenderDic];
    NSArray *keyArray = self.calenderDic.allKeys;
    for (int i = 0; i < keyArray.count; i++) {
        NSString *date = keyArray[i];
        NSMutableDictionary *keyDic = [NSMutableDictionary dictionaryWithDictionary:[sortDic objectForKey:date]];
        NSArray *dicArray = keyDic[@"list"];
        
        NSString *state = @"0";//全天状态 0开课  1未开课
        NSString *cancelstate = @"0";//当天的订单是否可以取消 0.可以取消 1.不可以取消
        //对三个时间段进行整理
        //        for (int j = 0; j < 3; j++) {
        //            //获取对应时间段的选中状态
        NSString *key = @"selectState";
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[keyDic objectForKey:key]];
        
        NSMutableArray *selectArray = [NSMutableArray array];//选中的时间点集合
        NSMutableArray *restArray = [NSMutableArray array];//未开课的时间点集合
        NSMutableArray *unrestArray = [NSMutableArray array];//开课的时间点集合
        NSMutableArray *bookArray = [NSMutableArray array];//已经预约时间点集合
        NSMutableArray *expireArray = [NSMutableArray array];//已过期时间点集合
        for (NSDictionary *timeDic in dicArray) {
            int hour = [timeDic[@"hour"] intValue];
            NSString *isrest = [timeDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
            NSString *hasbooked = [timeDic[@"hasbooked"] description];//时间点是否已经被预约 0未被预约 1已经被预约
            NSString *expire = [timeDic[@"expire"] description];
            if (hour > 0 && hour < 25){
                NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
                NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
                
                if ([isrest intValue] == 1) {
                    //未开课
                    [restArray addObject:str];
                }else{
                    [unrestArray addObject:str];
                }
                
                if ([expire intValue] == 1) {
                    //已过期
                    [expireArray addObject:str];
                }else{
                }
                
                if ([hasbooked intValue] == 1) {
                    //已经预约
                    [bookArray addObject:str];
                }else{
                    NSString *nowDateStr = [CommonUtil getStringForDate:self.nowDate format:@"yyyy-MM-dd"];
                    //移除当前时间之前的日期
                    if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedAscending) {
                        //大于当天
                        //                                [selectArray addObject:str];//工作,默认全选
                    }else if ([nowDateStr compare:[timeDic[@"date"] description]] == NSOrderedSame) {
                        //等于当天
                        if ([self.nowHour intValue] < [[timeDic[@"hour"] description] intValue]){
                            //现在时间大于改时间点，选中状态
                            //                                    [selectArray addObject:str];//工作,默认全选
                        }
                        
                    }
                    
                }
            }else{
                //全体状态
                NSString *str = [timeDic[@"state"] description];
                NSString *cancelstateStr = [timeDic[@"cancelstate"] description];
                //                    if ([str intValue] == 0) {
                //                        continue;
                //                    }
                state = [CommonUtil isEmpty:str]?@"":str;
                cancelstate = [CommonUtil isEmpty:cancelstateStr]?@"":cancelstateStr;
                //                    break;
            }
            
        }
        
        //将值保存下来
        [selectDic setObject:selectArray forKey:@"selectArray"];
        [selectDic setObject:restArray forKey:@"restArray"];
        [selectDic setObject:bookArray forKey:@"bookArray"];
        [selectDic setObject:expireArray forKey:@"expireArray"];
        [selectDic setObject:unrestArray forKey:@"unrestArray"];
        //判断是否全选
        NSString *allSelect = @"0";
        
        if (selectArray.count == 19){
            
            allSelect = @"1";
        }
        [selectDic setObject:allSelect forKey:@"allSelect"];
        
        [keyDic setObject:selectDic forKey:key];//替换选中状态
        
        //        }
        
        [keyDic setObject:state forKey:@"state"];//全体状态
        [keyDic setObject:cancelstate forKey:@"cancelstate"];//当天的订单是否可以取消 0.可以取消 1.不可以取消
        [self.calenderDic setObject:keyDic forKey:date];//更新数据
        
    }
}
//保存修改后的日程
- (void)saveChangeSchedule{
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    
    int index = -1;
    for (int i = 0; i < self.calenderArray.count; i++) {
        NSDictionary *calenderDic = [self.calenderArray objectAtIndex:i];
        NSString *date = calenderDic[@"date"];//日期
        
        if ([chooseTime isEqualToString:date]) {
            //已经包含了该日程
            index = i;
            break;
        }
        
    }
    
    if(index == -1 || index > self.calenderArray.count){
        //不包含该日程，插入
        NSMutableDictionary *calenderDic = [NSMutableDictionary dictionary];
        [calenderDic setObject:chooseTime forKey:@"date"];
        
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        NSString *time = @"";
        //        for (int j = 0; j < 3; j++) {
        NSString *key = @"selectstate";
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
        
        //获取该行选中的时间
        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restTime"]];//选择的日期
        
        for (NSString *str in array) {
            //格式转换
            NSDate *date = [CommonUtil getDateForString:str format:@"H:mm"];
            NSString *dateStr = [CommonUtil getStringForDate:date format:@"H"];
            
            if ([CommonUtil isEmpty:time]) {
                time = dateStr;
            }else{
                time = [NSString stringWithFormat:@"%@,%@", time, dateStr];
            }
            
        }
        
        //        }
        
        [calenderDic setObject:time forKey:@"resttimes"];//未开课时间
        [calenderDic setObject:dic[@"state"] forKey:@"state"];
        [self.calenderArray addObject:calenderDic];
    }else{
        //已经包含了该日程，替换
        NSMutableDictionary *calenderDic = [NSMutableDictionary dictionary];
        [calenderDic setObject:chooseTime forKey:@"date"];
        
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        
        NSString *time = @"";
        //        for (int j = 0; j < 3; j++) {
        NSString *key = @"selectState";
        NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
        
        //获取该行选中的时间
        NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"restTime"]];//选择的日期
        
        for (NSString *str in array) {
            //格式转换
            NSDate *date = [CommonUtil getDateForString:str format:@"H:mm"];
            NSString *dateStr = [CommonUtil getStringForDate:date format:@"H"];
            
            if ([CommonUtil isEmpty:time]) {
                time = dateStr;
            }else{
                time = [NSString stringWithFormat:@"%@,%@", time, dateStr];
            }
            
        }
        
        //        }
        
        [calenderDic setObject:time forKey:@"resttimes"];//未开课时间
        [calenderDic setObject:dic[@"state"] forKey:@"state"];
        [self.calenderArray insertObject:calenderDic atIndex:index];
    }
    
}
//处理选中日期的数据
- (void)handelSelectDateDetail{
    [self updateSelectTimeDesc];
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    
    //设置工作时间
    BOOL hasDate = NO;
    int index = -1;
    for (int i = 0; i < self.calenderArray.count; i++) {
        NSDictionary *calenderDic = [self.calenderArray objectAtIndex:i];
        NSString *date = calenderDic[@"date"];//日期
        
        if ([chooseTime isEqualToString:date]) {
            hasDate = YES;
            index = i;
            break;
        }
    }
}
//更新当天数据
- (void)handelDaySchedule:(NSArray *)dateArray{
    
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    
    [dic setObject:dateArray forKey:@"list"];
    
    NSString *state = @"0";//全天状态 0开课  1未开课
    NSString *cancelstate = @"0";//当天的订单是否可以取消 0.可以取消 1.不可以取消
    //    for (int j = 0; j < 3; j++) {
    //        //获取对应时间段的选中状态
    NSString *key = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key]];
    
    NSMutableArray *selectArray = [NSMutableArray arrayWithArray:selectDic[@"selectArray"]];//选中的时间点集合
    NSMutableArray *restArray = [NSMutableArray array];//未开课的时间点集合
    NSMutableArray *bookArray = [NSMutableArray array];//已经预约时间点集合
    for (NSDictionary *timeDic in dateArray) {
        int hour = [timeDic[@"hour"] intValue];
        NSString *isrest = [timeDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
        NSString *hasbooked = [timeDic[@"hasbooked"] description];//时间点是否已经被预约 0未被预约 1已经被预约
        
        if (hour > 0 && hour < 25){
            NSDate *date = [CommonUtil getDateForString:[timeDic[@"hour"] description] format:@"HH"];
            NSString *str = [CommonUtil getStringForDate:date format:@"H:00"];
            
            if ([isrest intValue] == 1) {
                //未开课
                [restArray addObject:str];
            }else{
                //                            [selectArray addObject:str];//工作
            }
            
            if ([hasbooked intValue] == 1) {
                //已经预约
                [bookArray addObject:str];
            }else{
                
            }
            
        }else{
            //全体状态
            NSString *str = [timeDic[@"state"] description];
            NSString *cancelstateStr = [timeDic[@"cancelstate"] description];
            
            state = [CommonUtil isEmpty:str]?@"":str;
            cancelstate = [CommonUtil isEmpty:cancelstateStr]?@"":cancelstateStr;
        }
        
    }
    
    //将值保存下来
    [selectDic setObject:selectArray forKey:@"selectArray"];
    [selectDic setObject:restArray forKey:@"restArray"];
    
    //判断是否全选
    NSString *allSelect = @"0";
    
    if (selectArray.count == 19){
        //全选
        allSelect = @"1";
    }
    [selectDic setObject:allSelect forKey:@"allSelect"];
    
    [dic setObject:selectDic forKey:key];//替换选中状态
    
    
    //    }
    
    [dic setObject:state forKey:@"state"];//全体状态
    [dic setObject:cancelstate forKey:@"cancelstate"];//全体状态
    
    [self.calenderDic setObject:dic forKey:chooseTime];
    [self.mainTableView reloadData];
    [self showTableFooterView];
}

- (NSMutableArray *)getPointNum:(NSString *)day{
    NSMutableArray *pointArray = [NSMutableArray array];
    
    NSDictionary *dic = [self.calenderDic objectForKey:day];
    if (dic == nil) {
        dic = [NSDictionary dictionary];
    }
    
    NSArray *array = dic[@"list"];
    //不未开课,判断上课状态
    BOOL hasMorning = NO;
    BOOL hasAfternoon = NO;
    BOOL hasEvening = NO;
    
    //没有数据，默认开课
    if (array == nil) {
        hasMorning = YES;
        hasAfternoon = YES;
        hasEvening = YES;
    }
    
    //有数据，开始判断
    for (NSDictionary *arrDic in array) {
        NSString *hour = [arrDic[@"hour"] description];
        NSString *isRest = [arrDic[@"isrest"] description];//是否未开课 0.不未开课  1.未开课
        if ([isRest intValue]==0) {
            [pointArray addObject:hour];
        }
    }
    
    return pointArray;
}
/** 显示日期按钮
 * @param weekWidth     一个日期的宽高
 * @param dayStr        日期-天
 * @param beginDate     该按钮的日期（NSDate类型）
 * @param status        该天的状态 0开课  1未开课
 * @param index         该天在calenderList里面的下标位置
 * @param lastDate      月末
 * @param firstDate     月初
 * @param month 当前日期所属的月份
 **/
- (UIView *)showDateButtonView:(NSInteger)weekWidth dayStr:(NSString *)dayStr
                     beginDate:(NSDate *)beginDate status:(NSInteger)status index:(int)index
                      lastDate:(NSDate *)lastDate firstDate:(NSDate *)firstDate month:(NSInteger) month{
    NSMutableArray *pointArray = [self getPointNum:[CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"]];//点点的数量
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = MColor(34, 34, 34);
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 0.5f;
    
    DateButton *button = [DateButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, 5, weekWidth - 10, weekWidth - 10);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.date = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
    button.titleLabel.numberOfLines = 2;
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
    [view addSubview:button];
    
    //设置该日期在list的位置
    button.index = [NSString stringWithFormat:@"%d", index];
    
    //获取最后一天的日期
    if ([beginDate compare:lastDate] == NSOrderedDescending || [beginDate compare:firstDate] == NSOrderedAscending
        || [beginDate compare:self.nowDate] == NSOrderedAscending || [beginDate compare:self.endDate] == NSOrderedDescending) {
        //不可点击, beginDate大于月末, beginDate小于月初、开始时间,小于今日
        int selectMonth = [CommonUtil getMonthOfDate:self.selectDate];
        if(selectMonth == month){
            [button setTitle:dayStr forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;//不可点击
            [button setTitleColor:MColor(104, 104, 104) forState:UIControlStateNormal];
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 18, weekWidth, 22)];
            label.text = @"不可操作";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = MColor(104, 104, 104);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }else{
            [button setTitle:@"" forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;//不可点击
            [button setTitleColor:MColor(104, 104, 104) forState:UIControlStateNormal];
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 18, weekWidth, 22)];
            label.text = @"";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = MColor(104, 104, 104);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
        
    }else if ([beginDate compare:self.nowDate] == NSOrderedSame){
        //今天
        [button addTarget:self action:@selector(clickForDetail:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:dayStr forState:UIControlStateNormal];
        [button setTitleColor:MColor(34, 192, 100) forState:UIControlStateNormal];
        
        //文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 18, weekWidth, 22)];
        label.text = @"今日";
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = MColor(34, 192, 100);
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        if ([beginDate compare:self.selectDate] == NSOrderedSame ) {
            //该日期是选中的日期
            [button setTitleColor:MColor(28, 28, 28) forState:UIControlStateNormal];
            label.textColor = MColor(28, 28, 28);
            view.backgroundColor = [UIColor whiteColor];
        }
        
    }else{
        //beginDate 在这个月内
        //添加点击
        [button addTarget:self action:@selector(clickForDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        //显示按钮下方点
        if (pointArray.count == 0){
            //未开课
            [button setTitle:dayStr forState:UIControlStateNormal];
            [button setTitleColor:MColor(255, 255, 255) forState:UIControlStateNormal];
            view.backgroundColor = MColor(43, 55, 51);
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 18, weekWidth, 22)];
            label.text = @"未开课";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = MColor(255, 255, 255);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            if ([beginDate compare:self.selectDate] == NSOrderedSame ) {
                //该日期是选中的日期
                label.textColor = MColor(28, 28, 28);
            }
        }else{
            //正常工作
            [button setTitle:dayStr forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            NSString *chooseTime = [CommonUtil getStringForDate:beginDate format:@"yyyy-MM-dd"];
            NSDictionary *dic = [self.calenderDic objectForKey:chooseTime];
            if (dic == nil) {
                dic = [NSDictionary dictionary];
            }
            view.backgroundColor = MColor(44, 64, 33);
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, weekWidth - 18, weekWidth, 22)];
            label.text = @"已开课";
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = MColor(255, 255, 255);
            if ([beginDate compare:self.selectDate] == NSOrderedSame) {
                label.textColor = MColor(28, 28, 28);
            }
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
        if ([beginDate compare:self.selectDate] == NSOrderedSame) {
            //该日期是选中的日期
            [button setTitleColor:MColor(28, 28, 28) forState:UIControlStateNormal];
            view.backgroundColor = [UIColor whiteColor];
        }
    }
    return view;
}

- (IBAction)clickForDefaultAlert:(id)sender {
    NSInteger tag = ((UIButton*)sender).tag;
    if(tag == 0){//设置默认
        [self clickForStart:nil];
        if(self.setDefaultButton.selected){
            needSetDefault = YES;
            self.setDefaultButton.selected = NO;
        }
    }
    
    [self.defaultAlertView removeFromSuperview];
}


- (IBAction)clickForSetDefaultCheck:(id)sender {
    UIButton *button = (UIButton*)sender;
    if(button.isSelected){
        button.selected = NO;
    }else{
        button.selected = YES;
    }
}

- (void) setTodayDefault{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
   
}
@end

