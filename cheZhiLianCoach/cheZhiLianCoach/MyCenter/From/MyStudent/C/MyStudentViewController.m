//
//  MyStudentViewController.m
//  guangda
//
//  Created by guok on 15/6/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyStudentViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "MyStudentTableViewCell.h"
#import "LoginViewController.h"



#define kDataNum 10
@interface MyStudentViewController ()<UITableViewDataSource, UITableViewDelegate,DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    int pageNum;
    BOOL isRefresh;//是否刷新
}
@property (strong, nonatomic) IBOutlet UITableView *studentTableView;

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) NSMutableArray *studentList;
@property (strong, nonatomic) NSString *openStudentID;//打开的订单id
@property (strong, nonatomic) NSIndexPath *openIndexPath;//打开的indexPath
@property (strong, nonatomic) NSIndexPath *closeIndexPath;//关闭的indexPath


@end

@implementation MyStudentViewController

- (NSMutableArray *)studentList {
    if (!_studentList) {
        _studentList = [NSMutableArray array];
    }
    return _studentList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentTableView.delegate = self;
    self.studentTableView.dataSource = self;
    pageNum = 0;
    _openStudentID = @"0";
    self.studentList = [NSMutableArray array];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.studentTableView withClient:self];
    
    //隐藏加载更多
   // self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.studentTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isRefresh = YES;
    if ([UserDataSingleton mainSingleton].coachId.length == 0) {
        return;
    }
    [self refreshData];
    
}

- (void)refreshData{
    
    if(isRefresh){
        [self.pullToRefresh tableViewReloadStart:[NSDate date] Animated:YES];
        [self.studentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self pullToRefreshTriggered:self.pullToRefresh];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark tableViewCell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
      if ([_openStudentID isEqualToString:@"0"]) {
        //打开
        return 303;
    }else{
        //关闭
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellident = @"MyStudentTableViewCell";
    MyStudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyStudentTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    //获取数据
    MyStudentListModel *model = self.studentList[indexPath.row];
    NSString *avatar = @"";
    NSString *coachstate = [NSString stringWithFormat:@"%d", model.state];
    NSString *learnmytime = @"23";
    NSString *learntime = @"30";
    NSString *money = @"5299";
    NSString *realname = model.realName;
    NSString *studentid = @"0";
    NSString *phone = model.phone;
    NSString *student_cardnum = @"11";
    //头像
    NSString *logo = [CommonUtil isEmpty:avatar]?model.avatarUrl:avatar;
    if ([coachstate intValue] == 1) {
        //已认证
        cell.detailImageView.image = [UIImage imageNamed:@"logo_default"];
        //[cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:logo] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
        
    }else{
        [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImage_URL,logo]] placeholderImage:[UIImage imageNamed:@"logo_default"]];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImage_URL,logo]] placeholderImage:[UIImage imageNamed:@"logo_default"]];//背景图片
    }
    if(![CommonUtil isEmpty:realname]){
        cell.timeLabel.text = realname;
    }else{
        cell.timeLabel.text = @"";
    }
    
    if([CommonUtil isEmpty:learnmytime]){
        
    }
    
    if([CommonUtil isEmpty:learntime]){
        
    }
    
    cell.addressLabel.text = [NSString stringWithFormat:@"历史学时:%d/%d",[learnmytime intValue],[learntime intValue]];
    
    //订单总价
    cell.priceLabel.textColor = MColor(32, 180, 120);
    cell.priceLabel.text = [NSString stringWithFormat:@"历史消费:%@元",money];
    
    // 投诉
    NSString *phone1 = [CommonUtil isEmpty:phone]?@"暂无":phone;
    cell.complaintBtn.phone = phone1;
    [cell.complaintBtn addTarget:self action:@selector(complaintClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 联系
    cell.contactBtn.phone = phone1;
    [cell.contactBtn addTarget:self action:@selector(contactClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //姓名
    NSString *name = [CommonUtil isEmpty:realname]?@"暂无":realname;
    name = [NSString stringWithFormat:@"学员姓名 %@", name];
    cell.nameLabel.text = name;
    
    //联系电话
    NSString *phoneString = [NSString stringWithFormat:@"联系电话 %@", phone1];
    cell.phoneLabel.text = phoneString;
    
    //学员证号
    NSString *num = [CommonUtil isEmpty:student_cardnum]?@"暂无":student_cardnum;
    num = [NSString stringWithFormat:@"学员证号 %@", num];
    cell.studentNumLabel.text = num;
    
    if([self.openStudentID isEqualToString:studentid]){
        [self showDetailsCell:cell];
    }else{
        [self hideDetailsCell:cell];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     if ([_openStudentID isEqualToString:@"1"]) {
        _openStudentID = @"0";
    }else{
        self.openStudentID = @"1";
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
    
}
// details收起
- (void)hideDetailsCell:(MyStudentTableViewCell *)cell{
    cell.studentDetailsView.hidden = YES;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_right"];
    cell.iconTop.constant = 32;
    cell.iconRight.constant = 11;
    cell.iconWidth.constant = 9;
    cell.iconHeight.constant = 15;
}
// details展开
- (void)showDetailsCell:(MyStudentTableViewCell *)cell{
    cell.studentDetailsView.hidden = NO;
    cell.jiantouImageView.image = [UIImage imageNamed:@"icon_button_down"];
    cell.iconTop.constant = 35;
    cell.iconRight.constant = 8;
    cell.iconWidth.constant = 14;
    cell.iconHeight.constant = 9;
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
    [self.studentList removeAllObjects];
    [self getStudentList];
}
/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getStudentList];
}

- (void)getDataFinish{
    [self.pullToRefresh tableViewReloadFinishedAnimated:YES];
    [self.pullToMore tableViewReloadFinished];
    
//    if (self.studentList.count == 0) {
//        self.noStudentView.hidden = NO;
//        self.studentTableView.hidden = YES;
//    }else{
//        self.noStudentView.hidden = YES;
//        self.studentTableView.hidden = NO;
//    }
}

- (void) getStudentList{
    //MyStudentListModel
    //http://106.14.158.95:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT/coach/api/findStudents?coachId=88922b469930498a89ee444e6e25f757
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findStudents", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    __weak  MyStudentViewController *VC = self;
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr= [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        [VC.studentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [VC.pullToRefresh tableViewReloadFinished:[NSDate date] Animated:YES];
        if ([resultStr isEqualToString:@"1"]) {
            [VC  ParsingStudentData:responseObject];
        }else {
            [VC makeToast:responseObject[@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}

- (void)ParsingStudentData:(NSDictionary *)dataDic {
    NSArray *studentArray = dataDic[@"data"];
    for (NSDictionary *studentDic in studentArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"MyStudentListModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        MyStudentListModel *model = [[MyStudentListModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        NSLog(@"studentDic%@", studentDic);
        for (NSString *key in studentDic) {
            
            [model setValue:studentDic[key] forKey:key];
            
        }
        [self.studentList addObject:model];
    }
    
    [self.studentTableView reloadData];
    NSLog(@"self.studentList%@", self.studentList);
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
//更新用户头像，显示六边形
- (void)updateUserLogo:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}
#pragma mark - button action
#pragma mark 联系
- (void)contactClick:(DSButton *)sender {
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
    
}

#pragma mark 投诉
- (void)complaintClick:(DSButton *)sender {
    if(![CommonUtil isEmpty:sender.phone] && ![@"暂无" isEqualToString:sender.phone]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",sender.phone]]];
    }else{
        [self makeToast:@"该学员还未设置电话号码"];
    }
}

@end
