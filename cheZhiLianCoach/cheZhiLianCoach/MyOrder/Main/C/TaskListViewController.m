//
//  TaskListViewController.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "TaskListViewController.h"
#import "HistoryViewController.h"
#import "TaskListTableViewCell.h"
#import "UIPlaceHolderTextView.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "UploadPhotoViewController.h"
#import "TQStarRatingView.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GoComplaintViewController.h"

@interface TaskListViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, UIAlertViewDelegate, StarRatingViewDelegate, UITextViewDelegate, TaskListTableViewCellDelgate>{
    int pageNum;
    BOOL hasTask;//是否有进行中的任务
    BOOL isRefresh;//是否刷新
    NSString *upcarOrderId;
    
    NSString *advertisementopentype;
    NSString *advertisementUrl;
}
//用户定位
@property (strong, nonatomic) NSString *cityName;//城市
@property (strong, nonatomic) NSString *address;//地址

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *commentView;             // 评价弹窗
@property (strong, nonatomic) IBOutlet UIView *commentBottomView;       // 评价弹窗下半部分
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *commentTextView;      
@property (strong, nonatomic) IBOutlet DSButton *gouBtn;        // 勾
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewAndStarView;     // textView距离上部分的约束
@property (strong, nonatomic) IBOutlet UIView *commentContentView;      // 评价的内部内容View
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentContentViewTopJuli; // 评价的内部内容View距离顶部的距离约束

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UIButton *noDataViewBtn;

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

//参数
@property (strong, nonatomic) NSIndexPath *selectIndexPath;
@property (strong, nonatomic) NSMutableDictionary *scoreDic;//分数
@property (strong, nonatomic) NSMutableArray *taskListArray;  //任务信息
@property (strong, nonatomic) NSMutableArray *noSortArray;                 //没有整理过的任务信息
@property (strong, nonatomic) NSMutableDictionary *rowDic;                 // 每一行的状态list
@property (strong, nonatomic) NSString *commentOrderId; //评论的订单id
@property (strong, nonatomic) NSString *openOrderId;//打开的订单id
@property (strong, nonatomic) NSIndexPath *closeIndexPath;//关闭的indexPath
@property (strong, nonatomic) NSIndexPath *openIndexPath;//打开的indexPath

//广告位
@property (strong, nonatomic) IBOutlet UIView *advertisementView;
@property (strong, nonatomic) IBOutlet UIButton *advertisementImageButton;
//@property (strong, nonatomic) NSString *advertisementUrl;//地址
- (IBAction)closeAdvertisementView:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *advImageView;

@end

@implementation TaskListViewController

- (NSMutableArray *)taskListArray {
    if (!_taskListArray) {
        _taskListArray  = [NSMutableArray array];
    }
    return  _taskListArray;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UserDataSingleton mainSingleton].URL_SHY.length != 0) {
        return;
    }
  

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isRefresh = YES;
    self.openOrderId = @"0";
    self.commentOrderId = @"0";
    self.scoreDic = [NSMutableDictionary dictionary];
    self.noSortArray = [NSMutableArray array];
    hasTask = NO;
    self.rowDic = [NSMutableDictionary dictionary];

    self.commentTextView.delegate = self;
    self.commentTextView.placeholder = @"来说点什么吧";
    self.commentTextView.placeholderColor = MColor(163, 171, 188);
    self.gouBtn.data = [NSMutableDictionary dictionary];
    pageNum = 0;
    self.commentContentViewTopJuli.constant = ([UIScreen mainScreen].bounds.size.height - 319) / 2;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"refreshTaskData" object:nil];
    //设置默认分数
    [self.scoreDic setObject:@"5" forKey:@"score1"];
    [self.scoreDic setObject:@"5" forKey:@"score2"];
    [self.scoreDic setObject:@"5" forKey:@"score3"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isRefresh = YES;
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isRefresh = NO;
}

- (void)refreshData{
    if(isRefresh){
        [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
        [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self pullToRefreshTriggered:self.pullToRefresh];
    }
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
    
    if (self.taskListArray.count == 0) {
        //  self.noDataViewBtn.hidden = NO;
    }else{
        self.noDataViewBtn.hidden = YES;
    }
    
}
#pragma mark - 接口
- (void)getTaskList{
   
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findReservationOrder", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId" ] =[UserDataSingleton mainSingleton].coachId;
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak  TaskListViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr  = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC AnalyticalData:responseObject];
            [VC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            [VC.pullToRefresh setPullToRefreshViewVisible:YES];
        }else {
            [VC.taskListArray removeAllObjects];
            [VC makeToast:responseObject[@"msg"]];
            [VC.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [VC makeToast:@"获取失败请重试"];
        [VC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [VC.pullToRefresh setPullToRefreshViewVisible:YES];
        NSLog(@"error%@", error);
    }];
}

- (void)AnalyticalData:(NSDictionary *)dataDic {
    [self.taskListArray removeAllObjects];
    NSArray *dataArray = dataDic[@"data"];
    if (dataArray.count == 0) {
        self.noDataViewBtn.hidden = NO;
        //[self showAlert:@"你还没有订单可以选择" time:1.2];
        [self.tableView reloadData];
        return;
    }
    self.noDataViewBtn.hidden = YES;
    for (NSDictionary *modelData in dataArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"MyOrderModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        MyOrderModel *model = [[MyOrderModel   alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        
        for (NSString *key in modelData) {
            [model setValue:modelData[key] forKey:key];
        }
        [self.taskListArray  addObject:model];
          NSLog(@"self.taskListArray%@model%@",self.taskListArray, model);
    }
    [self.tableView reloadData];
}
#pragma mark - UITableView
#pragma mark tableViewSection

#pragma mark tableViewCell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.taskListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 300;
    //return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"taskCell";
    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
  //  cell.delegate = self;
    MyOrderModel *model = self.taskListArray[indexPath.row];
   // NSLog(@"model%@", model);
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"TaskListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    //获取数据
    {
        
    if (9) {
        if (indexPath.row == 2) {
            cell.blackLine.hidden = YES;
        }else{
            cell.blackLine.hidden = NO;
        }
    }
    
    NSString *agreecancel = @"1"; //判断订单是否需要取消
    cell.sureCancelBtn.indexPath = indexPath;
    cell.noCancelBtn.indexPath = indexPath;
    [cell.sureCancelBtn addTarget:self action:@selector(sureCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noCancelBtn addTarget:self action:@selector(noCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    if (!agreecancel.boolValue) {
        cell.backgroundColor = MColor(253, 243, 144);
        cell.cancelView.hidden = NO;
        cell.getCarClick.hidden = YES;
        cell.cancelLabel.hidden = NO;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.cancelView.hidden = YES;
        cell.getCarClick.hidden = NO;
        cell.cancelLabel.hidden = YES;
    }
    NSString *startTime = [CommonUtil InDataForString:model.startTime];//开始时间
    NSString *endTime = [CommonUtil InDataForString:model.endTime];//结束时间
    NSString *address = @"";//地址
    NSString *total = [NSString stringWithFormat:@"%d", model.price] ; //订单总价
    /**
     state =
     0：
     接口相关:coachstate为0,且距离开始时间超过一个小时.
     前端处理:无
     1:
     接口相关:coachstate为0,且距离开始时间少于一个小时.且教练当前没有其它的进行中任务.
     前端处理:任务的时间显示为红色.可以确认上车.
     2:
     接口相关:coachstate为0,且距离开始时间少于一个小时.但教练当前还有其它的进行中任务.
     前端处理:任务的时间显示为红色.不可以确认上车.
     3:
     接口相关:coachstate为1
     前端处理:显示练车中,且可以确认下车."
     
     以上纯属瞎扯  这才是真的 
     0 未上车 可以上车
     1 上车了 可以下车
     2 下车了 可以投诉
     
     */
    int state = model.trainState;
        NSLog(@"model.trainState%d",model.trainState);
    if (state != 0) {
        //红色日期 （开始时间1小时内到结束时间为止）
        cell.timeLabel.textColor = MColor(246, 102, 93);
    }else{
        cell.timeLabel.textColor = MColor(28, 28, 28);
    }
    //支付方式   1：现金 2：小巴券 3：小巴币
     int paytype = arc4random()%3 + 1;
    if (paytype  == 1) {
        cell.payerType.hidden = NO;
        cell.payerType.text = @"¥";
        cell.payerType.hidden = NO;
        cell.payerType2.hidden = YES;
    }else if (paytype== 2) {
        cell.payerType.hidden = NO;
        cell.payerType.text =  @"券";
        cell.payerType.hidden = NO;
        cell.payerType2.hidden = YES;
    }else if (paytype == 3) {
        cell.payerType.hidden = NO;
        cell.payerType.text = @"币";
        cell.payerType.hidden = NO;
        cell.payerType2.hidden = YES;
    }else if (paytype== 4) {
        cell.payerType.hidden = NO;
        cell.payerType.text = @"币";
        cell.payerType.hidden = NO;
        cell.payerType.text = @"￥";
        cell.payerType2.hidden = NO;
    }else{
        cell.payerType.hidden = YES;
        cell.payerType2.hidden = YES;
    }
    NSString *subjectname = @"";
    if (subjectname.length == 0 || !subjectname) {
        cell.accompanyDriveBtn.hidden = YES;
    }else{
        cell.accompanyDriveBtn.hidden = NO;
        //陪驾是否需要教练带车
        NSString *attachcar = @"1";
        if ([attachcar boolValue]) {
            [cell.accompanyDriveBtn setImage:[UIImage imageNamed:@"ic_教练带车"] forState:UIControlStateNormal];
        }else{
            [cell.accompanyDriveBtn setImage:[UIImage imageNamed:@"ic_学员带车"] forState:UIControlStateNormal];
        }
    }
    NSString *coursetype = @"1";
    if ([coursetype intValue] == 5) {
        cell.accompanyDriveBtn.hidden = NO;
        [cell.accompanyDriveBtn setImage:[UIImage imageNamed:@"ic_not_attach_car"] forState:UIControlStateNormal];
    }
    
    //头像
    NSString *logo = @"";
    int studentState = arc4random()%2+1;//0.未认证 1.认证.studentState
    if (studentState == 1) {
        //已认证
        cell.logoImageView.layer.cornerRadius = cell.logoImageView.bounds.size.width/2;
        cell.logoImageView.layer.masksToBounds = YES;
        cell.logoImageView.image = [UIImage imageNamed:@"logo_default"];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }else{
        cell.logoImageView.image = [UIImage imageNamed:@"logo_default_nopass"];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }
    //任务时间
    NSString *time = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
        cell.timeLabel.font = MFont(kFit(12));
    cell.timeLabel.text = time;
    cell.getCarClick.indexPath = indexPath;
    cell.finishView.hidden = YES;
    //订单总价
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@",total];
    //地址
    cell.addressLabel.text = address;
    // 投诉
    NSString *phone =@"136467120175";
    cell.complaintBtn.phone = phone;
    [cell.complaintBtn addTarget:self action:@selector(complaintClick:) forControlEvents:UIControlEventTouchUpInside];
    // 联系
    cell.contactBtn.phone = phone;
    [cell.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
    //姓名
    NSString *name = @"测试数据";
    name = [NSString stringWithFormat:@"学员姓名 %@", name];
    cell.nameLabel.text = name;
    //联系电话
    phone = [NSString stringWithFormat:@"联系电话 %@", phone];
    cell.phoneLabel.text = phone;
    //学员证号
    NSString *num = @"123456789";
    num = [NSString stringWithFormat:@"学员证号 %@", num];
    cell.studentNumLabel.text = num;
    // 判断按钮状态
    /**
     state =
     0:
     接口相关:coachstate为0,且距离开始时间超过一个小时.
     前端处理:无
     1:
     接口相关:coachstate为0,且距离开始时间少于一个小时.且教练当前没有其它的进行中任务.
     前端处理:任务的时间显示为红色.可以确认上车.
     2:
     接口相关:coachstate为0,且距离开始时间少于一个小时.但教练当前还有其它的进行中任务.
     前端处理:任务的时间显示为红色.不可以确认上车.
     3:
     接口相关:coachstate为1
     前端处理:显示练车中,且可以确认下车."
     */
    NSString *key = [NSString stringWithFormat:@"row%@", @"123455677"];
    NSString *rowState = [self.rowDic objectForKey:key];
        
    if ([rowState intValue] == 2) {
        //完成状态
        cell.finishView.hidden = NO;
        [self showDetailsCell:cell];
    }else {
        if ([_openOrderId isEqualToString:@"1"]) {//判断打开或者关闭 cell
            //打开
            cell.finishView.hidden = YES; //打开情况下隐藏黑线
            cell.blackLine.hidden = YES;
            [self showDetailsCell:cell];
        }else{
            //关闭
            cell.finishView.hidden = YES;
            [self showDetailsCell:cell];
        }
    }
#warning 这个地方还要更改 因为目前就一个数组
    cell.getCarClick.tag = indexPath.row;
    cell.getCarClick.trainState = [NSString stringWithFormat:@"%d", model.trainState];
    [cell.getCarClick addTarget:self action:@selector(handlerUpDownCar:) forControlEvents:(UIControlEventTouchUpInside)];
    if (state == 0) {
        //可以确认上车
        [cell.getCarClick setTitle:@"确认上车" forState:(UIControlStateNormal)];
    }else if (state  == 1){
        //可以确认下车
        [cell.getCarClick setTitle:@"确认下车" forState:(UIControlStateNormal)];
    }else{
     //   [self checkUpCarBtn:cell.getCarClick];//确认上车
    }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取数据
    if ([_openOrderId isEqualToString:@"1"]) {
        _openOrderId = @"0";
    }else{
        self.openOrderId = @"0";
    }
    
    if (self.openIndexPath == nil || [self.openIndexPath isEqual:indexPath]) {
        //本来这一行就是打开状态或者所有行都处于关闭状态
//        self.closeIndexPath = indexPath;//关闭这一行
        self.openIndexPath = indexPath;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        //这一行不是打开状态,打开这一行
        self.closeIndexPath = self.openIndexPath;
        self.openIndexPath = indexPath;

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
    imageView.image = [UIImage imageNamed:@"shape.png"];
}
//更新未通过验证用户头像，显示六边形
- (void)updateNoPassUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [UIImage imageNamed:@"logo_default_nopass"];
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
#pragma mark - button action
#pragma mark 联系
- (void)contactClick:(DSButton *)sender {

    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", sender.phone]]];
                });
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
    
}
//关闭广告位
- (IBAction)closeAdvertisementView:(id)sender {
    [self.advertisementView removeFromSuperview];
}
//打开广告
- (IBAction)openAdvertisement:(id)sender {
    //0=无跳转，1=打开URL，2=内部action
    if ([advertisementopentype intValue]==0) {
        NSLog(@"不跳转");
    }else if([advertisementopentype intValue]==1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:advertisementUrl]];
    }else if([advertisementopentype intValue]==2){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:advertisementUrl]];
    }
}
#pragma mark 投诉 -- 发短信
- (void)complaintClick:(DSButton *)sender {
    
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
}

#pragma mark 练车中
- (void)practicingCarBtn:(DSButton *)button {
    UIImage *image = [UIImage imageNamed:@"background_practice"];
    [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:@"练车中" forState:UIControlStateNormal];
    button.enabled = NO;
}

- (void)handlerUpDownCar:(DSButton *)sender {
    
    __weak TaskListViewController *VC =self;
    
    MyOrderModel *model = self.taskListArray[sender.indexPath.row];
    NSLog(@"model.trainState%hd sender.trainState%@", model.trainState, sender.trainState);
    UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"警告!" message:model.trainState == 0 ?@"确定学员上车":@"确定学员下车"  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self  respondsToSelector:@selector(indeterminateExample)];
        NSString *URL_Str = [NSString stringWithFormat:@"%@/train/api/confirmOnBus", kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"id"] = model.orderId;
        URL_Dic[@"flag"] = [NSString stringWithFormat:@"%d", sender.trainState.intValue + 1];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress%@", uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            [self  respondsToSelector:@selector(delayMethod)];
            if ([resultStr isEqualToString:@"1"]) {
                [VC makeToast:@"编辑成功!"];
                [VC getTaskList];
            }else {
                [VC makeToast:responseObject[@"msg"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self  respondsToSelector:@selector(delayMethod)];
            NSLog(@"error%@", error);
        }];

    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"点错了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        return ;
    }];
    // 3.将“取消”和“确定”按钮加入到弹框控制器中
    [alertV addAction:cancle];
    [alertV addAction:confirm];
    // 4.控制器 展示弹框控件，完成时不做操作
    [self presentViewController:alertV animated:YES completion:^{
        nil;
    }];

    
 }

#pragma mark 点击确认上车弹框
- (void)getUpCarClick:(id)sender {


    
}
#pragma mark 点击确认下车弹框确认
- (void)getOffCarClick:(id)sender {
    
}
#pragma mark 点击同意取消订单
- (void)sureCancelClick:(DSButton *)button {
  
}
#pragma mark 点击不同意取消订单
- (void)noCancelClick:(DSButton *)button {
   
}

#pragma mark - 定位 BMKLocationServiceDelegate
#pragma mark details收起
- (void)hideDetailsCell:(TaskListTableViewCell *)cell {
    cell.studentDetailsView.hidden = YES;
    [cell.jiantouImageView setImage:[UIImage imageNamed:@"icon_button_right"] forState:UIControlStateNormal];
}
#pragma mark details展开
- (void)showDetailsCell:(TaskListTableViewCell *)cell {
    cell.studentDetailsView.hidden = NO;
    [cell.jiantouImageView setImage:[UIImage imageNamed:@"icon_button_down"] forState:UIControlStateNormal];
}
#pragma mark 完成任务删除cell
- (void)deleteCell {

    // 删除数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self.taskListArray objectAtIndex:self.selectIndexPath.section]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:dic[@"list"]];
    NSDictionary *rowDic = [array objectAtIndex:self.selectIndexPath.row];
    [array removeObject:rowDic];
    [dic setObject:array forKey:@"list"];
    
    if (array.count == 0) {
        //该日期下已经没有数据，移除
        [self.taskListArray replaceObjectAtIndex:self.selectIndexPath.section withObject:dic];
        [self.tableView deleteRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self.rowDic removeAllObjects];
        [self.taskListArray removeObject:dic];
        [self.tableView reloadData];
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:self.selectIndexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    }else{
        //该日期下还有数据，替换
        [self.taskListArray replaceObjectAtIndex:self.selectIndexPath.section withObject:dic];
        [self.tableView deleteRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    }
    
    //行状态重置
    self.closeIndexPath = nil;
    self.openIndexPath = nil;
    
//    [self getTaskList];//刷新数据
    
    [self performSelector:@selector(addCommentView) withObject:nil afterDelay:0.3f];
}
#pragma mark 添加评论
- (void)addCommentView {
    
    
    self.commentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.commentView];

    if (self.taskListArray.count == 0) {
        //没有数据
       // self.noDataViewBtn.hidden = NO;
    }else{
        self.noDataViewBtn.hidden = YES;
    }
    
    pageNum = 0;
    [self performSelector:@selector(getTaskList) withObject:nil afterDelay:0.3f];
    
}
#pragma mark 取消评论
- (IBAction)cancelComment:(id)sender {
    [self.commentView removeFromSuperview];
}
#pragma mark 提交评论
- (IBAction)sureComment:(id)sender {
    NSString *str = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (str.length == 0) {
//        [self makeToast:@"请说点什么吧。。"];
//        return;
//    }
    
    
//    if (self.selectIndexPath.section >= self.taskList.count) {
//        return;//数组越界判断
//    }
//    //判断该学员是否填写过资料
//    NSDictionary *dic = [self.taskList objectAtIndex:self.selectIndexPath.section];
//    NSArray *array = dic[@"list"];
//    
//    if (self.selectIndexPath.row >= array.count) {
//        return;//数组越界判断
//    }
//    
//    dic = [array objectAtIndex:self.selectIndexPath.row];
    
    if ([self.commentOrderId intValue] !=0) {
        [self ComfirmComment:str orderId:self.commentOrderId];
    }
    
    
    
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
    
//    self.gouBtn.enabled = YES;
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
    
    self.commentView.frame = newTextViewFrame;
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
    self.commentView.frame = self.view.frame;
    [UIView commitAnimations];
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.commentTextView resignFirstResponder];
}
#pragma mark 查看历史订单
- (IBAction)historyClick:(id)sender {
    HistoryViewController *viewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
    viewController.userId = self.userId;
    [self.navigationController pushViewController:viewController animated:YES];
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


#pragma mark 确认上车接口
- (void)ComfirmTask:(NSString *)orderId{
    [self makeToast:@"该功能未开通"];
}
#pragma mark 确认下车接口
- (void)getOffCarTask:(NSString *)orderId{
   [self makeToast:@"该功能未开通"];
}
#pragma mark 提交评论
- (void)ComfirmComment:(NSString *)comment orderId:(NSString *)orderId{
   [self makeToast:@"该功能未开通"];

}
#pragma mark 确认取消课程
- (void)sureCancle:(NSString *)orderId {
   [self makeToast:@"该功能未开通"];
}
#pragma mark 不同意取消课程
- (void)noCancle:(NSString *)orderId {
   [self makeToast:@"该功能未开通"];
    
}
#pragma mark - 广告位接口
- (void)getAdvertisement{
   [self makeToast:@"该功能未开通"];
}
#pragma mark 回调
- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - private
/** 整理数据， 根据日期存放list
 *格式 [{date: "yyyy-MM-dd", list:[....]}，{date: "yyyy-MM-dd", list:[....]},...]
 */
- (NSMutableArray *)handelTaskList:(NSArray *)array{
    //1.整理数据，根据日期排序,倒序排列
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        NSString *str1 = dic1[@"date"];
        NSString *str2 = dic2[@"date"];
        return [str1 compare:str2];
        
    }];
    
    NSMutableArray *taskArray = [NSMutableArray array];
    NSString *date = @"";
    NSMutableArray *sortList = [NSMutableArray array];
    for (int i = 0; i < sortArray.count; i++) {
        NSDictionary *dic = sortArray[i];
        if (i == 0) {
            date = dic[@"date"];
        }
        
        if ([CommonUtil isEmpty:date]) {
            date = @"";
        }
        
        if ([date isEqualToString:dic[@"date"]]) {
            //同一个日期
            [sortList addObject:dic];
        }else{
            //下一个日期
            NSMutableDictionary *sortDic = [NSMutableDictionary dictionary];
            [sortDic setObject:date forKey:@"date"];//日期
            [sortDic setObject:[NSArray arrayWithArray:sortList] forKey:@"list"];
            [taskArray addObject:sortDic];
            
            //清空list
            [sortList removeAllObjects];
            date = dic[@"date"];
            [sortList addObject:dic];
        }
        if (i == sortArray.count - 1){
            NSMutableDictionary *sortDic = [NSMutableDictionary dictionary];
            [sortDic setObject:date forKey:@"date"];//日期
            [sortDic setObject:[NSArray arrayWithArray:sortList] forKey:@"list"];
            [taskArray addObject:sortDic];
        }
    }
    return taskArray;
}

//清空评价信息
- (void)clearEvaluate{
    [self.starRatingView1 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView1.frame), 0)];
    [self.starRatingView2 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView2.frame), 0)];
    [self.starRatingView3 changeStarForegroundViewWithPoint:CGPointMake(CGRectGetWidth(self.starRatingView3.frame), 0)];
    
    self.scoreLabel1.text = @"学习态度5分";
    self.scoreLabel2.text = @"技能掌握5分";
    self.scoreLabel3.text = @"遵章守时5分";
    
    self.commentTextView.text = @"";
    self.commentOrderId = @"0";
}

@end
