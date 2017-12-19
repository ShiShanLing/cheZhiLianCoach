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
#import "TimeChooseTableViewCell.h"
#define TIME_BLOCKWEITH SCREEN_WIDTH/320*66 // 时间块的宽度
#define TIME_BLOCKHIGTH SCREEN_WIDTH/320*70 // 时间块的高度

//如果是当天就不让编辑
static  BOOL EditTime;

@interface ScheduleViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, CustomTabBarDelegate, TimeChooseTableViewCellDelegate,UIAlertViewDelegate>{
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
@property (strong,nonatomic)NSMutableArray *CoursePriceArray;
@property (strong, nonatomic) IBOutlet UIButton *setDefaultButton;

- (IBAction)clickForSetDefaultCheck:(id)sender;
/*
 CGFloat ff = scrollView.contentOffset.y;
 if (ff > scrollView.contentSize.height - self.mainTableView.height){
 // 取消上拉回弹
 [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - self.mainTableView.hidden)];
 }
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
/**
 *存储未分割的时间
 */
@property (nonatomic, strong)NSMutableArray *coachTimeArray;

@property (strong, nonatomic) IBOutlet DateButton *allSelectButton;
/**
 *分割好的时间数组
 */
@property (nonatomic, strong)NSMutableArray *dateArray;
@end

@implementation ScheduleViewController {
    NSInteger  openCourse;//当点击的第一个时间段是未开课的 那么就不让点击别的开课的选项
    NSDate   *currentTime;//如果是空的或者 是当天就不让操作
    CGFloat bai2;//白天科二
    CGFloat bai3;//白天科三
    CGFloat hei2;//黑夜科二
    CGFloat hei3;//黑夜科三
}
- (NSMutableArray *)CoursePriceArray {
    if (!_CoursePriceArray) {
        _CoursePriceArray  = [NSMutableArray array];
    }
    return _CoursePriceArray;
}
- (NSMutableArray *)coachTimeArray {
    if (!_coachTimeArray) {
        _coachTimeArray = [NSMutableArray array];
    }
    return _coachTimeArray;
}

- (NSMutableArray *)dateArray {
    if (!_dateArray) {
        _dateArray = [NSMutableArray arrayWithArray:@[@[].mutableCopy, @[].mutableCopy, @[].mutableCopy]];
    }
    return _dateArray;
}

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
    [self.mainTableView registerClass:[TimeChooseTableViewCell class] forCellReuseIdentifier:@"TimeChooseTableViewCell"];
    
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
   
    self.sureIssueButton.layer.cornerRadius = 5;
    self.sureIssueButton.layer.masksToBounds = YES;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    showAlert = YES;
    openCourse = 5;
    if (self.selectDate != nil) {
        NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
        NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
        if (dic == nil) {
            dic = [NSMutableDictionary dictionary];
        }
        needRefresh = YES;
        //获取数据
        if(needRefresh){
            [self.refreshManager tableViewReloadStart:[NSDate date] Animated:YES];
            [self refreshSchedule];
        }
    }
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
        [self requestCoursePrice:currentTime];

        self.openOrCloseClassView.hidden = YES;
    }
}
//比较两个时间是否相等
- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
}
/**
 获取当天时间段价钱
 */
- (void)requestCoursePrice:(NSDate *)date  {
    NSDate *nowDate;
    if (date ==nil ||  [self isSameDay:date date2:[NSDate date] ]) {
        nowDate = [NSDate date];
        NSLog(@"nowDate%@ date%@", nowDate, date);
        currentTime =  nowDate;
        EditTime = NO;
    }else {
        currentTime = date;
        nowDate = date;
        EditTime = YES;
    }
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findClassPrice", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"schoolId"] = kSchoolId;
    URL_Dic[@"dateTime"] = [CommonUtil getStringForDate:nowDate format:@"yyyy-MM-dd"];
    URL_Dic[@"carTypeId"] = [UserDataSingleton mainSingleton].carTypeId.length == 0?@"1":[UserDataSingleton mainSingleton].carTypeId;
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak  ScheduleViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取当天价钱responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC parsingTodayCoursePrice:responseObject[@"data"]];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}
- (void)parsingTodayCoursePrice:(NSArray *)CoursePrice {
    if (CoursePrice.count ==0) {
        [self showAlert:@"课程信息数据为空,请联系管理员!" time:1.0];
        return;
    }
    [self.CoursePriceArray removeAllObjects];
    for (NSDictionary *PriceDic in CoursePrice) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CoursePriceModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CoursePriceModel *model = [[CoursePriceModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        for (NSString *key in PriceDic) {
            [model setValue:PriceDic[key] forKey:key];
        }
        [self.CoursePriceArray addObject:model];
    }
    [self requestData:currentTime];
}
#pragma mark 请求数据
- (void)requestData:(NSDate *)date {
    self.allSelectButton.selected = NO;
    needRefresh = NO;
    NSDate *nowDate;
    if (date ==nil ||  [self isSameDay:date date2:[NSDate date] ]) {
        nowDate = [NSDate date];
        NSLog(@"nowDate%@ date%@", nowDate, date);
        currentTime =  nowDate;
        EditTime = NO;
    }else {
        currentTime = date;
        nowDate = date;
        EditTime = YES;
    }
    NSTimeInterval timeIn = [nowDate timeIntervalSince1970];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:timeIn];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *newTime = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:detaildate]];
    NSString *SJCStr = [NSString stringWithFormat:@"%.0f000", [[CommonUtil getDateForString:newTime format:nil] timeIntervalSince1970]];
    //NSLog(@"最终转为字符串时间1 = %@  SJCStr%@", newTime, SJCStr);
    NSString *URL_Str = [NSString stringWithFormat:@"%@/train/api/coachReserveTime", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"]= [UserDataSingleton mainSingleton].coachId;
    [URL_Dic setValue:SJCStr forKey:@"dateMillis"];
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak ScheduleViewController *VC = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // manager.requestSerializer.timeoutInterval = 20;// 网络超时时长设置
    [manager POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //   NSLog(@"responseObject%@",responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"0"]) {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }else {
            needRefresh = YES;
            [VC.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];//介绍刷新
            [VC parsingCoachTimeData:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];//介绍刷新
        [VC showAlert:@"网络出错!!" time:1.2];
        needRefresh = YES;
    }];
}

- (void)parsingCoachTimeData:(NSDictionary *)dic {
    [self.coachTimeArray removeAllObjects];
    NSLog(@"self.CoursePriceArray%@", self.CoursePriceArray);
    self.openOrCloseClassView.hidden = YES;
    NSArray *tempArray = dic[@"data"];
    NSDictionary *tempDic = tempArray[0];
    NSArray *dateArray = tempDic[@"result"];
    [self managedContext];
    //创建实体描述对象
    for (NSDictionary *dateDic in dateArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CoachTimeListModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CoachTimeListModel *CTLModel = [[CoachTimeListModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        [CTLModel setValue:tempDic[@"unitPrice"] forKey:@"unitPrice"];

        for (NSString *key in dateDic) {
            [CTLModel setValue:dateDic[key] forKey:key];
        }
        [self.coachTimeArray addObject:CTLModel];
    }
    [self TimeDivision];
}
//时间分割
- (void)TimeDivision {
    //    NSLog(@"TimeDivision%@", self.coachTimeArray);
    [self.dateArray[0] removeAllObjects];
    [self.dateArray[1] removeAllObjects];
    [self.dateArray[2] removeAllObjects];
    for (CoursePriceModel *priceModel in self.CoursePriceArray) {
        //如果是休息天(3) - 否者就是工作日(1白天和2夜晚)
        if (priceModel.dateId==3) {
            //如果是 休息日只需要判断是科二还是科三
            if (priceModel.subId==2) {
                bai2 = priceModel.classPrice;
                hei2 = priceModel.classPrice;
            }else if(priceModel.subId == 3) {
                bai3 = priceModel.classPrice;
                hei3 = priceModel.classPrice;
            }
        }else {
            //如果是工作日需要判断是 白天还是夜晚
            //如果是白天 //否者如果是晚上
            if (priceModel.dateId == 1) {
                //如果是科二//否者如果是科三
                if (priceModel.subId==2) {
                    bai2 = priceModel.classPrice;
                }else if(priceModel.subId == 3) {
                    bai3 = priceModel.classPrice;
                }
            }else if (priceModel.dateId == 2) {
                //如果是科二//否者如果是科三
                if (priceModel.subId==2) {
                    hei2 = priceModel.classPrice;
                }else if(priceModel.subId == 3) {
                    hei3 = priceModel.classPrice;
                }
            }
        }
    }
    
    for (CoachTimeListModel *model in self.coachTimeArray) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"HH"];
        NSString *currentDateStr = [dateFormatter stringFromDate: model.endTime];
        int temeHH = currentDateStr.intValue;
       // NSLog(@"<><><><><><><><><>%d", temeHH);
        
        if (temeHH <=12) {
            [dateFormatter setDateFormat:@"HH:mm"];
            model.timeStr = [dateFormatter stringFromDate: model.startTime];
            model.periodStr = @"上午";
            model.sub2Price = bai2;
            model.sub3Price = bai3;
            [self.dateArray[0] addObject:model];
        }else if (temeHH <=18 && (temeHH > 12)) {
            [dateFormatter setDateFormat:@"HH:mm"];
            model.timeStr = [dateFormatter stringFromDate: model.startTime];
            model.periodStr = @"下午";
            model.sub2Price = bai2;
            model.sub3Price = bai2;
            [self.dateArray[1] addObject:model];
        }else {
            [dateFormatter setDateFormat:@"HH:mm"];
            model.timeStr = [dateFormatter stringFromDate: model.startTime];
            model.periodStr = @"晚上";
            model.sub2Price = hei2;
            model.sub3Price = hei3;
            [self.dateArray[2] addObject:model];
        }
    }
    NSLog(@"self.dateArray%@", self.dateArray);
    [self.mainTableView reloadData];
    
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
//section高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
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
    }else {
        return 0.01;
    }
}
//sectionHeader的样式
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;{
    if (section == 0) {
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
            NSString *state = [UserDataSingleton mainSingleton].approvalState;
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
    }else {
        return nil;
    }
}
#pragma mark sectionFooterView
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    int  state = [UserDataSingleton mainSingleton].approvalState.intValue;
    if (section == 0) {
        if (isReload2Section) {
            //不显示第一行的section
            return 0;
        }
           if (state != 2) {
            return 16+32;
        }else{
            return 16;
        }
        
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    int  state = [UserDataSingleton mainSingleton].approvalState.intValue;
    //    view.backgroundColor = [UIColor blackColor];
    self.openBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 16);
    [view addSubview:self.openBtn];

        UIView *signView = [[UIView alloc]initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 32)];
        signView.backgroundColor = MColor(249, 239, 210);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20, 11, 6, 9)];
        imageView.image = [UIImage imageNamed:@"ic_arrowForSchedule"];
        [signView addSubview:imageView];
        UIButton *remindButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, signView.width, signView.height)];
        [remindButton addTarget:self action:@selector(clickCoachInfo) forControlEvents:UIControlEventTouchUpInside];
        remindButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [remindButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
            switch (state) {
                case -1:
                    [remindButton setTitle:@"    还为申请成为教练!" forState:UIControlStateNormal];
                    break;
                case 0:
                    [remindButton setTitle:@"    还为申请成为教练!" forState:UIControlStateNormal];
                    break;
                case 1:
                    [remindButton setTitle:@"    正在等待审核您的资料!" forState:UIControlStateNormal];
                    break;
                case 2:
                    [remindButton setTitle:@"    您的资料已经审核通过!" forState:UIControlStateNormal];
                    break;
                case 3:
                    [remindButton setTitle:@"    您的资料审核未通过,请重新提交!" forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
    [remindButton setTitleColor:MColor(252, 89, 0) forState:UIControlStateNormal];
    if (state == 2) {
        
    }else {
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
//section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dateArray.count == 0) {
        return 1;
    }else {
        return self.dateArray.count + 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        //剩下的日期
        NSDate *lastDate = [CommonUtil getLastDayOfDate:self.selectDate];
        long lastWeek = [CommonUtil getWeekOfDate:lastDate];
        long selectWeed = [CommonUtil getWeekOfDate:self.selectDate];
     //   NSLog(@"numberOfRowsInSection%d", lastWeek - selectWeed);
        return lastWeek - selectWeed;
    }else{
    //    NSLog(@" self.dateArray.count%d",  self.dateArray.count);
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        int weekHeight = ceil(SCREEN_WIDTH / 7.0);
        return  weekHeight;
    }
    
    NSMutableArray *tempArray = self.dateArray[indexPath.section-1];
    int number = tempArray.count;
    //排数 = number/4 + number%4?1:0
    //cell的高度  =  82.5 * 排数 + (排数 - 1) * 5
    if (number == 0) {
        return kFit(82.5) + kFit(5);
    }else if (number <=4){
        return kFit(82.5) + kFit(5);
    }else {
        int row = (number/4) + (number%4?1:0);
        return row *kFit(82.5)+(row-1)*kFit(5);
    }
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
    }else {
        TimeChooseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeChooseTableViewCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dataArray = _dateArray[indexPath.section -1];
        cell.cellSection = indexPath.section - 1;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//没有选中状态
        return cell;
    }
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
       //     [self.mainTableView reloadData];
        }
    }else{
        if (isReload2Section) {
            //显示第一个sectionHeader隐藏第二个sectionHeader，造成选中行打开的效果
            isReload2Section = NO;
     //       [self.mainTableView reloadData];
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
    
    [self requestCoursePrice:currentTime];
    if (self.CoursePriceArray.count != 0) {
        [self requestData:currentTime];
    }
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
    currentTime = self.selectDate;
    NSLog(@"self.selectDate%@", self.selectDate);
    //处理选中日期的数据
    [self handelSelectDateDetail];
    [self showTableHeaderView];
    [self showTableFooterView];
    [self testOpenOrCloseView];
    [self requestCoursePrice:currentTime];
    if (self.CoursePriceArray.count != 0) {
        [self requestData:currentTime];
    }
}
- (void)clickCoachInfo {
    CoachInfoViewController *nextViewController = [[CoachInfoViewController alloc]initWithNibName:@"CoachInfoViewController" bundle:nil];
    nextViewController.superViewNum = @"1";
    [self.navigationController pushViewController:nextViewController animated:YES];
}
- (void)testOpenOrCloseView {
    NSString *chooseTime = [CommonUtil getStringForDate:self.selectDate format:@"yyyy-MM-dd"];
    NSMutableDictionary *dic = [self.calenderDic objectForKey:chooseTime];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    NSString *key1 = @"selectState";
    NSMutableDictionary *selectDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:key1]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[selectDic objectForKey:@"selectArray"]];//选择的日期
    if (array.count == 0) {
        //self.openOrCloseClassView.hidden = YES;
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
        //self.openOrCloseClassView.hidden = NO;
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
//切换月份
- (IBAction)clickForChangeDate:(id)sender {
    //    [self getDefaultSchedule];
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
    NSString *timeIdStr;
    for (NSArray * timeArray in self.dateArray) {
        for (CoachTimeListModel *model in timeArray) {
            if (model.state == 4) {
                if (timeIdStr.length == 0) {
                    timeIdStr = model.timeId;
                }else {
                timeIdStr = [NSString stringWithFormat:@"%@,%@", timeIdStr,model.timeId];
                }
            }
        }
    }
//    ?timeId=0e6087aa34a34f1c8f7816f4af1cb7aa,131b11c1271a4175b30b42f663272501
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/cancleClass",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"timeId"] = timeIdStr;
    NSLog(@"URL_Dic%@",URL_Dic);
    __weak  ScheduleViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC showAlert:responseObject[@"msg"] time:1.2];
            [VC requestData:currentTime];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];

    
    
}
//开课
- (void)clickForStart:(id)sender{

    
}
//全选 全部取消
- (void)clickForChoose:(DateButton *)button{
    NSLog(@"%@", button.selected?@"YES":@"NO");
    button.selected = !button.selected;
    
    for (NSArray * timeArray in self.dateArray) {
        for (CoachTimeListModel *model in timeArray) {
            if (button.selected) {
                if (openCourse == 0) {
                    if (model.state == 0 && model.openCourse == 0) {
                        model.state = 4;
                    }
                }else if (openCourse == 1){
                    if (model.state == 0 && model.openCourse == 1) {
                        model.state = 4;
                    }
                }
            }else {
                if (openCourse == 0) {
                    if (model.state == 4 && model.openCourse == 0) {
                        model.state = 0;
                    }
                }else if (openCourse == 1) {
                if (model.state == 4 && model.openCourse == 1) {
                    model.state = 0;
                }
            }
        }
        }
    }
    if (!button.selected) {
        openCourse = 5;
        self.openOrCloseClassView.hidden = YES;
    }
    [self.mainTableView reloadData];
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
    //获取选中的日期
    NSString *time = [CommonUtil getStringForDate:currentTime format:@"yyyy-MM-dd"];
    ScheduleSettingViewController *nextController = [[ScheduleSettingViewController alloc] initWithNibName:@"ScheduleSettingViewController" bundle:nil];
    nextController.time = time;
    nextController.bai2 = bai2;
    nextController.bai3 = bai3;
    nextController.hei2 = hei2;
    nextController.hei3 = hei3;
    nextController.timeDic = nil;
    nextController.date = nil;
    nextController.allDayArray = self.dateArray;
    [self.navigationController pushViewController:nextController animated:YES];
}
//提交时间
- (IBAction)clickForTodayOPenClose:(id)sender{
    BOOL NOEmpty = NO;
    NSMutableArray *selectedTimeArray = [NSMutableArray array];
    NSString *priceStr ;
    NSString *coachNameStr;
    for (NSArray * timeArray in self.dateArray) {
        for (CoachTimeListModel *model in timeArray) {
            if (model.state == 4) {
                NOEmpty = YES;
                priceStr = [NSString stringWithFormat:@"%.0f", model.unitPrice];;
                [selectedTimeArray addObject:[NSString stringWithFormat:@"%ld%@", (long)[model.startTime timeIntervalSince1970], @"000"]];
                [selectedTimeArray addObject:[NSString stringWithFormat:@"%ld%@", (long)[model.endTime timeIntervalSince1970], @"000"]];
            }
        }
    }
    //http://www.jxchezhilian.com/coach/api/openClass?coachId=0d885d2fd73e47798290b2f415f25a78&time=1509926400000,1509930000000&subType=1
    [self performSelector:@selector(indeterminateExample)];
    NSString *timeArraayStr = [selectedTimeArray componentsJoinedByString:@","];
    timeArraayStr = [timeArraayStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    timeArraayStr =[timeArraayStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    timeArraayStr =[timeArraayStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/openClass", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"]= [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"time"]= timeArraayStr;
    URL_Dic[@"subType"]= @"2";
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak  ScheduleViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [VC performSelector:@selector(delayMethod)];
    //    NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC makeToast:@"提交成功"];
            [VC requestData:currentTime];
        }else {
            [VC makeToast:@"提交失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC performSelector:@selector(delayMethod)];
        NSLog(@"error%@", error);
    }];
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
#pragma mark - privat

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
            label.text = @"可操作";
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
            label.text = @"可操作";
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
#pragma make  时间选择cell的代理方法
- (void)ClickIndex:(NSIndexPath *)indexPath {
    
    
    
    if ([UserDataSingleton mainSingleton].approvalState.intValue != 2) {
        [self showAlert:@"您还不是教练,不能编辑时间!" time:1.2];
        return;
    }
    
    if (!EditTime) {
        [self showAlert:@"不能编辑当天时间!" time:1.2];
        return;
    }
    
    NSLog(@"%@", self.openOrCloseClassView.hidden?@"NO":@"YES");
    NSMutableArray *tempArray = self.dateArray[indexPath.section];
    CoachTimeListModel *model = tempArray[indexPath.row];
    if (openCourse == 5) {
        openCourse =model.openCourse;
        if (model.openCourse == 0) {//如果没有开课
            if (model.state == 0 ) {//点击编程选中状态
                model.state = 4;
            }else if(model.state == 4) {
                model.state = 0;
            }
        }else if(model.openCourse == 1){//如果开课了
            if (model.state == 0) {//如果没有被预约
                if (model.state == 0 ) {
                    model.state = 4;
                }else if(model.state == 4) {
                    model.state = 0;
                }
            }
        }
    }else {
        if (openCourse == model.openCourse) {
                if (model.state == 0 ) {
                    model.state = 4;
                }else if(model.state == 4) {
                    model.state = 0;
                }
        }
    }
    NSLog(@"self.dateArray%@", self.dateArray);
    self.dateArray[indexPath.section] = tempArray;
    [self.mainTableView reloadData];
    //BOOL  hidden = YES;
    for (NSArray * timeArray in self.dateArray) {
        for (CoachTimeListModel *model in timeArray) {
            if (model.openCourse == 0) {
                if (model.state == 4) {
                    self.openOrCloseClassView.hidden = NO;//如果还有时间在选中状态那么就不让视图隐藏
                    self.writeScheduleButton.hidden = NO;
                    self.sureIssueButton.hidden = NO;
                    self.stopClassButton.hidden = YES;
                    return;
                }
            }
            if ( model.openCourse == 1) {
                if (model.state == 4) {
                    self.writeScheduleButton.hidden = YES;
                    self.sureIssueButton.hidden = YES;
                    self.stopClassButton.hidden = NO;
                    self.openOrCloseClassView.hidden = NO;//如果还有时间在选中状态那么就不让视图隐藏
                    return;
                }
            }
        }
    }
    openCourse = 5;
    self.openOrCloseClassView.hidden = YES;//如果走到这里代表所有的时间都已经取消选中那么视图消失掉 openCourse 也要重置掉
    
    
}

@end

