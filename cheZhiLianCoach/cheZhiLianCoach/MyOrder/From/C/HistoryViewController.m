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
#import "TaskTimeDetailsTVCell.h"
#import "TaskHeadView.h"

@interface HistoryViewController ()<UITableViewDataSource, UITableViewDelegate, DSBottomPullToMoreManagerClient, DSPullToRefreshManagerClient, UITextViewDelegate, StarRatingViewDelegate,TaskTimeDetailsTVCellDeleagte>{
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
@property (nonatomic, strong)NSMutableArray *taskListArray;


@end

@implementation HistoryViewController

- (NSMutableArray *)taskListArray {
    if (!_taskListArray) {
        _taskListArray = [NSMutableArray array];
    }
    return _taskListArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TaskTimeDetailsTVCell" bundle:nil] forCellReuseIdentifier:@"TaskTimeDetailsTVCell"];
    self.noDataBtn.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self getHistoryTaskList];
}
- (void)getHistoryTaskList{
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/historyTrainOrder", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    //http://www.jxchezhilian.com/coach/api/findReservationOrder?coachId=a019d62109674cff8f7fcd7b5bc2cefd
    URL_Dic[@"coachId" ] =[UserDataSingleton mainSingleton].coachId;
    NSLog(@"URL_Dic%@", URL_Dic);
    __weak  HistoryViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr  = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC AnalyticalData:responseObject];
            NSLog(@"VC.tableView.contentOffset.y;%f",VC.tableView.contentOffset.y);
            if (VC.tableView.contentOffset.y > 0) {
                
            }else {
                [VC.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                [VC.pullToRefresh setPullToRefreshViewVisible:YES];
            }
            
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
        self.noDataBtn.hidden = NO;
        //[self showAlert:@"你还没有订单可以选择" time:1.2];
        [self.tableView reloadData];
        return;
    }
    self.noDataBtn.hidden = YES;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.taskListArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MyOrderModel *orderModel = self.taskListArray[section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    return timeModelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrderModel *orderModel = self.taskListArray[indexPath.section];
    NSArray *timeModelArray = (NSArray *)orderModel.orderTimes;
    if (orderModel.state == 2) {
        if (indexPath.row == timeModelArray.count -1) {
            return 179;
        }else {
            return 128;
        }
    }else {
        return 128;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
@end
