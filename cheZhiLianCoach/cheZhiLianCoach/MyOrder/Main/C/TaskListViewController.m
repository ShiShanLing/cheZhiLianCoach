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
#import "TaskTimeDetailsTVCell.h"
#import "TaskHeadView.h"//页眉视图

@interface TaskListViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, UIAlertViewDelegate, StarRatingViewDelegate, UITextViewDelegate, TaskListTableViewCellDelgate,TaskTimeDetailsTVCellDeleagte>{
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
    [self.tableView registerNib:[UINib nibWithNibName:@"TaskTimeDetailsTVCell" bundle:nil] forCellReuseIdentifier:@"TaskTimeDetailsTVCell"];
    self.tableView.backgroundColor = MColor(239, 239, 244);
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
        
    }else{
        self.noDataViewBtn.hidden = YES;
    }
}
#pragma mark - 接口
- (void)getTaskList{
   
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findReservationOrder", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    //http://www.jxchezhilian.com/coach/api/findReservationOrder?coachId=a019d62109674cff8f7fcd7b5bc2cefd
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
            
            if ([key isEqualToString:@"orderTimes"]) {
                NSMutableArray *timeModelArray  = [NSMutableArray array];
                NSArray *timeArray = modelData[key];
                for (NSDictionary *timeDic in timeArray) {
                    NSEntityDescription *timeDes = [NSEntityDescription entityForName:@"OrderTimeModel" inManagedObjectContext:self.managedContext];
                    //根据描述 创建实体对象
                    OrderTimeModel *timeModel = [[OrderTimeModel alloc] initWithEntity:timeDes insertIntoManagedObjectContext:self.managedContext];
                    for (NSString *timeKey in timeDic) {
                        if ([timeKey isEqualToString:@"startTime"]) {
                            [model setValue:timeDic[timeKey] forKey:@"orderDate"];
                        }
                        if ([timeKey isEqualToString:@"trainState"]) {
                            [model setValue:timeDic[timeKey] forKey:@"trainState"];
                        }
                        [timeModel setValue:timeDic[timeKey] forKey:timeKey];
                    }
                    [timeModelArray addObject:timeModel];
                }
                [model setValue:timeModelArray forKey:key];
            }else {
                [model setValue:modelData[key] forKey:key];
            }
        }
        [self.taskListArray  addObject:model];
    }
    NSLog(@"self.taskListArray%@",self.taskListArray);
    [self.tableView reloadData];
}
#pragma mark - UITableView
#pragma mark tableViewSection

#pragma mark tableViewCell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.taskListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    MyOrderModel *orderModel = self.taskListArray[section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    return timeModelArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyOrderModel *orderModel = self.taskListArray[indexPath.section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    if (orderModel.state == 3) {
        if (indexPath.row == timeModelArray.count -1) {
            return 179;
        }else {
            return 128;
        }
    }else {
        return 128;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskTimeDetailsTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskTimeDetailsTVCell" forIndexPath:indexPath];;
    MyOrderModel *orderModel = self.taskListArray[indexPath.section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    //这个判断是判断是否显示 拒绝和同意
    if (orderModel.state == 3) {
        if (indexPath.row == timeModelArray.count -1) {
            cell.AgreedBtn.hidden = NO;
            cell.RefusedBtn.hidden = NO;
        }else {
            cell.AgreedBtn.hidden = YES;
            cell.RefusedBtn.hidden = YES;
        }
    }else {
        cell.AgreedBtn.hidden = YES;
        cell.RefusedBtn.hidden = YES;
    }
    
    OrderTimeModel *timeModel  =timeModelArray[indexPath.row];
    if (indexPath.row == timeModelArray.count-1) {
        cell.backgroundImageView.image = [UIImage imageNamed:@"background4"];
    }else {
        cell.backgroundImageView.image = [UIImage imageNamed:@"background2"];
    }
    cell.model = timeModel;
    cell.indexPath = indexPath;
    cell.delegate  = self;
    NSString *btnState;
    switch (timeModel.trainState) {
        case 0:
            btnState = @"确认上车";
            cell.timeEditorBtn.backgroundColor = MColor(0, 190, 122);
            break;
        case 1:
            btnState = @"确认下车";
            cell.timeEditorBtn.backgroundColor = MColor(0, 190, 122);
            break;
        case 2:
            btnState = @"已结束";
            cell.timeEditorBtn.backgroundColor = MColor(149, 149, 149);
            break;
        default:
            break;
    }
    [cell.timeEditorBtn setTitle:btnState forState:(UIControlStateNormal)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MyOrderModel *orderModel = self.taskListArray[section];
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"TaskHeadView" owner:nil options:nil];
    TaskHeadView *headView = [nibContents lastObject];
    headView.frame = CGRectMake(0, 0, kScreen_widht, 162);
    headView.model = orderModel;
    
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 175;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_widht, 0.01)];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
    
}
#pragma make TaskTimeDetailsTVCell
/**
 *确认上下车
 *@param sender DSButton
 */
- (void)TimeStateEditor:(DSButton *)sender  {
    __weak TaskListViewController *VC =self;

    MyOrderModel *orderModel = self.taskListArray[sender.indexPath.section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    OrderTimeModel *timeModel  =timeModelArray[sender.indexPath.row];
    NSString *btnState;
    switch (timeModel.trainState) {
        case 0:
            btnState = @"确认学员上车";
            break;
        case 1:
            btnState = @"确认学员下车";
            break;
        case 2:
            return;
            break;
        default:
            break;
    }
    UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"警告!" message:btnState  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self  respondsToSelector:@selector(indeterminateExample)];
        NSString *URL_Str = [NSString stringWithFormat:@"%@/train/api/confirmOnBus", kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"timeId"] = timeModel.timeId;
        NSLog(@"URL_Dic%@", URL_Dic);
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
/**
 *同意或者拒绝取消订单   tag值 拒绝 0 同意 1
 * sender sender description
 */
- (void)AgreeOrRefuseCancelOrder:(DSButton *)sender {
    MyOrderModel *orderModel = self.taskListArray[sender.indexPath.section];

__weak  TaskListViewController *VC = self;
    if (sender.tag == 0) {
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/reject",kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"orderId"] = orderModel.orderId;
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress%@", uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"1"]) {
                [VC showAlert:responseObject[@"msg"] time:1.2];
                [VC getTaskList];
            }else {
                [VC showAlert:responseObject[@"msg"] time:1.2];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error%@", error);
        }];
    }else {
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/approve",kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"orderId"] = orderModel.orderId;
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress%@", uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"1"]) {
                [VC showAlert:responseObject[@"msg"] time:1.2];
                [VC getTaskList];
            }else {
                [VC showAlert:responseObject[@"msg"] time:1.2];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error%@", error);
        }];

    }
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
#pragma mark 取消评论
- (IBAction)cancelComment:(id)sender {
    [self.commentView removeFromSuperview];
}
#pragma mark 提交评论
- (IBAction)sureComment:(id)sender {
    
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


@end
