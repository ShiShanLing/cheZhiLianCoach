//
//  MyEvaluationViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyEvaluationViewController.h"
#import "MyEvaluationCell.h"
#import "EvaluationMeCell.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "TQStarRatingView.h"
#import "ComplainMeCell.h"
#import "LoginViewController.h"

@interface MyEvaluationViewController () <UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    NSMutableArray *myDataArr;
    //NSMutableArray *myDataArr;
    TQStarRatingView *ratingView;
    
    NSMutableArray *complainMyDataArr; // 我的投诉容器
    NSMutableDictionary *complainMyDic; // 存放每条投诉我的内容高度
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UIView *selectBarView;
@property (strong, nonatomic) IBOutlet UIImageView *backgoundImageView;
@property (strong, nonatomic) IBOutlet UIButton *myEvaluationBtn;       // 评价我的按钮属性
@property (strong, nonatomic) IBOutlet UIButton *evaluationMeBtn;       // 我的评价按钮属性
@property (strong, nonatomic) IBOutlet UIButton *ComplainMeBtn;         // 投诉我的按钮属性
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *studentInfoView;
@property (strong, nonatomic) IBOutlet UIImageView *nodataImageView;   // 没评论时显示的内容
@property (strong, nonatomic) IBOutlet UIImageView *noComplainImageView;      // 无投诉内容时显示的背景图片

@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;  // 学员名字
@property (strong, nonatomic) IBOutlet UILabel *studentCardIdLabel; // 学员证号
@property (strong, nonatomic) IBOutlet UILabel *studentPhoneLabel;  // 学员号码
@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView; // 学员头像
@property (strong, nonatomic) IBOutlet UILabel *studentScoreLabel;    // 学员评分
@property (strong, nonatomic) IBOutlet UIView *startView; // 星级显示


- (IBAction)clickForMyEvaluation:(id)sender;
- (IBAction)clickForEvaluationMe:(id)sender;
- (IBAction)clickForComplainMe:(id)sender;//点击投诉
- (IBAction)clickForCancelInfoView:(id)sender;
- (IBAction)callPhoneBtn:(id)sender;

@property (assign, nonatomic) int rows; // 数据行数;
@property (assign, nonatomic) int pagenum; //评论页数
@property (copy, nonatomic) NSString *phoneNum;

@end

@implementation MyEvaluationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    complainMyDataArr = [[NSMutableArray alloc] init];
    complainMyDic = [[NSMutableDictionary alloc] init];
    
    // 设置边框
    self.selectBarView.layer.cornerRadius = 4;
    self.selectBarView.layer.borderWidth = 0.6;
    self.selectBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    self.evaluationMeBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.evaluationMeBtn.layer.borderWidth = 0.6;
    
    [self settingView];
    
    ratingView = [[TQStarRatingView alloc] initWithFrame:self.startView.bounds numberOfStar:5];
    ratingView.couldClick = NO;//不可点击
    [ratingView changeStarForegroundViewWithPoint:CGPointMake(0/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    [self.startView addSubview:ratingView];
    
    self.phoneNum = @"12345678912";
    
    // self.rows = 5;
    myDataArr = [[NSMutableArray alloc] init];
    //myDataArr = [[NSMutableArray alloc] init];
    
    self.evaluationType = 1;
    // 调用评价我的
    [self GetEvaluationToMy:self.pagenum];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //隐藏加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingView {
    self.mainTableView.allowsSelection = NO;
    self.studentInfoView.frame = [UIScreen mainScreen].bounds;
    
    // 设置圆角
    UIImage *backgroundImage = [[UIImage imageNamed:@"bar_tousu.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0,13,0,13)];
    [self.backgoundImageView setImage:backgroundImage];
    
    self.selectBarView.layer.cornerRadius = 13;
    
    self.myEvaluationBtn.selected = YES;
    self.evaluationMeBtn.selected = NO;
    self.ComplainMeBtn.selected = NO;
    
    
    [self.myEvaluationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.myEvaluationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.evaluationMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.evaluationMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.ComplainMeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.ComplainMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.myEvaluationBtn setBackgroundColor:[UIColor blackColor]];
    [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
}

// 根据文字，字号及固定宽(固定高)来计算高(宽)
- (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height
{
    
    // 用何种字体显示
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment=NSTextAlignmentLeft;
        
        NSAttributedString *attributeText=[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
        CGSize labelsize = [attributeText boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        expectedLabelSize = CGSizeMake(ceilf(labelsize.width),ceilf(labelsize.height));
    } else {
        expectedLabelSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByCharWrapping];
    }
    // 计算出显示完内容的最小尺寸
    return expectedLabelSize;
}

// 对头像裁剪成六边形
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.evaluationType == 2) {
        return complainMyDataArr.count;
    }else {
        return  10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 我的评价
    if (self.evaluationType == 0) {
        static NSString *ID = @"MyEvaluationCellIdentifier";
        MyEvaluationCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"MyEvaluationCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        // 加载数据
        cell.evaluationContent = @"是个好学员,一教就会"; // 评价详情
        cell.studentIcon = @"logo.jpg"; // 学员头像
        
        cell.coachIcon = @"logo.jpg";
        cell.studentName = @"张二毛";          // 学员名字
        cell.score = 5.0;  // 评分
        
        NSString *startTime = @"2017-03-23";  // 任务开始时间
        NSString *endTime = @"2017-08-21";      // 任务结束时间
        NSString *dataTime =[NSString stringWithFormat:@"%@~%@",startTime ,endTime ];
        cell.evaluationData = dataTime;           // 任务时间
        cell.studentInfoBtn.tag = indexPath.row;
        [cell.studentInfoBtn addTarget:self action:@selector(myClickForStudentInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell loadData:nil];
        
        return cell;
    }
    // 评价我的
    else if (self.evaluationType == 1) {
        static NSString *ID = @"EvaluationMeCellIdentifier";
        EvaluationMeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"EvaluationMeCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 加载数据
        
        cell.evaluationContent = @"是个好教练,可惜长得爱国了点"; // 评价详情
        cell.studentIcon = @"logo.jpg"; // 学员头像
        cell.score = 5.0;  // 评分
        
        NSString *startTime = @"2017-10-10";  // 任务开始时间
        NSString *dataTime =[NSString stringWithFormat:@"%@",startTime];
        cell.evaluationData = dataTime;           // 任务时间
        cell.studentInfoBtn.tag = indexPath.row;
        [cell loadData:nil];
        return cell;
    }
    // 投诉我的
    else{
        
        EvaluationOrderModel *model = complainMyDataArr[indexPath.row];
        
        static NSString *ID = @"ComplainMeCellIdentifier";
        ComplainMeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"ComplainMeCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
        // 动态清除子控件
        while (cell.depositView.subviews.count) {
            UIView* child = cell.depositView.subviews.lastObject;
            [child removeFromSuperview];
        }
        if(myDataArr == nil){
            return 0;
        }
        cell.type2 = model.appealState;
        cell.hasDealedWith = model.appealState;
        cell.complainContent = model.appealReason;
        NSString *startTime = [CommonUtil getStringForDate:model.appealTime];
        NSString *dataTime =[NSString stringWithFormat:@"%@",startTime ];
        cell.complainData = dataTime;// 任务时间段
        cell.studentIcon = @"logo.jpg";      // 学员头像
        cell.studentInfoBtn.tag = indexPath.row;
        [cell loadData:nil];
        if (indexPath.row == (myDataArr.count - 1)) {
            [_pullToMore tableViewReloadFinished];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.evaluationType == 0) {
        NSString *EvaluationContent = @"是个好学员,一教就会";
        CGSize textSize;
        if([CommonUtil isEmpty:EvaluationContent]){
            textSize.height = 0;
        }else{
            textSize = [self sizeWithString:EvaluationContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
        }
        return 229 - 35 + textSize.height;
    } else if (self.evaluationType == 1) {
        
        NSString *EvaluationContent = @"是个好教练可以长得有点爱国";
        CGSize textSize;
        if([CommonUtil isEmpty:EvaluationContent]){
            textSize.height = 0;
        }else{
            textSize = [self sizeWithString:EvaluationContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
        }
        return 152 - 35 + textSize.height;
    } else {
        return [self computeContentMyHeight:indexPath.row];
    }
}
// 计算投诉我的每个内容高度
- (int)computeContentMyHeight:(NSInteger)index{
    // 从字典中获取我的投诉数据
    EvaluationOrderModel *model = complainMyDataArr[index];
    if(complainMyDataArr == nil){
        return 0;
    }
    
    NSString *strContent = model.appealReason;
    // 投诉内容
    NSString *complainContent = [NSString stringWithFormat:@"%@",strContent];
    CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
    int height = textSize.height;
    return 100;
}


#pragma mark - 请求接口
- (void)getFreshData {
    // self.rows = 5;
    //[self.mainTableView reloadData];
    self.pagenum = 0;
    if(self.evaluationType == 0)
    {
        [self GetMyEvaluation:self.pagenum];
    }else if(self.evaluationType == 1){
        [self GetEvaluationToMy:self.pagenum];
    }else{
        [self getComplaintToMy:self.pagenum];
    }
    [_pullToRefresh tableViewReloadFinishedAnimated:YES];
}
// 加载更多数据
- (void)getMoreData {
    //self.rows = self.rows + 5;
    //[self.mainTableView reloadData];
    
    if(self.evaluationType == 0){
        self.pagenum = (int)(myDataArr.count / 10);
        [self GetMyEvaluation:self.pagenum];
    }else if(self.evaluationType == 1){
        self.pagenum = (int)(myDataArr.count / 10);
        [self GetEvaluationToMy:self.pagenum];
    }else{
        self.pagenum = (int)(myDataArr.count / 10);
        [self getComplaintToMy:self.pagenum];
    }
    //    [_pullToMore tableViewReloadFinished];
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
    [self getFreshData];
}
/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getMoreData];
}
#pragma mark - 按钮方法
// 评价我的
- (IBAction)clickForMyEvaluation:(id)sender {
    self.evaluationType = 1;
    self.pagenum = 0;
    if (self.myEvaluationBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = YES;
        self.evaluationMeBtn.selected = NO;
        self.ComplainMeBtn.selected = NO;
        [self.myEvaluationBtn setBackgroundColor:[UIColor blackColor]];
        [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    }
    [myDataArr removeAllObjects];
    [self GetEvaluationToMy:self.pagenum];
    [self.mainTableView reloadData];
}
// 我的评价
- (IBAction)clickForEvaluationMe:(id)sender {
    self.evaluationType = 0;
    self.pagenum = 0;
    if (self.evaluationMeBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = NO;
        self.evaluationMeBtn.selected = YES;
        self.ComplainMeBtn.selected = NO;
        [self.ComplainMeBtn setBackgroundColor:[UIColor clearColor]];
        [self.myEvaluationBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor blackColor]];
        
    }
    [myDataArr removeAllObjects];
    [self GetMyEvaluation:self.pagenum];
    [self.mainTableView reloadData];
}
#pragma mark - 按钮方法
// 投诉我的
- (IBAction)clickForComplainMe:(id)sender {
    //self.mainTableView.scrollsToTop = YES;
    //[self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.pagenum = 0;
    self.evaluationType = 2;
    if (self.ComplainMeBtn.selected == YES) {
        return;
    } else {
        self.myEvaluationBtn.selected = NO;
        self.evaluationMeBtn.selected = NO;
        self.ComplainMeBtn.selected = YES;
        [self.ComplainMeBtn setBackgroundColor:[UIColor blackColor]];
        [self.myEvaluationBtn setBackgroundColor:[UIColor clearColor]];
        [self.evaluationMeBtn setBackgroundColor:[UIColor clearColor]];
    }
    [myDataArr removeAllObjects];
    [self getComplaintToMy:self.pagenum];
    [self.mainTableView reloadData];
}
// 显示我的评价学员信息
- (void)myClickForStudentInfo:(UIButton *)sender {
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.studentScoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description]];
    self.studentPhoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentCardIdLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    self.phoneNum = self.studentPhoneLabel.text;
    
    NSString * strIcon = [[dict objectForKey:@"studentavatar"] description];
    if([CommonUtil isEmpty:strIcon])         // 设置学员头像
    {
        strIcon = @"";
    }
    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:strIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
            //            [self updateLogoImage:self.studentIconImageView];//裁切
        }
    }];
    
    [self.view addSubview:self.studentInfoView];
}

// 显示评价我的学员信息
- (void)clickForStudentMyInfo:(UIButton *)sender {
    NSDictionary * dict = [myDataArr objectAtIndex:sender.tag];
    self.studentScoreLabel.text = [NSString stringWithFormat:@"%@分",[[dict objectForKey:@"score"] description] ];
    self.studentPhoneLabel.text = [[dict objectForKey:@"phone"] description];
    self.studentCardIdLabel.text = [[dict objectForKey:@"studentcardnum"] description];
    self.studentNameLabel.text = [dict objectForKey:@"name"];
    
    [ratingView changeStarForegroundViewWithPoint:CGPointMake([dict[@"score"] floatValue]/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    self.phoneNum = self.studentPhoneLabel.text;
    
    NSString * strIcon = [[dict objectForKey:@"studentavatar"] description];
    if([CommonUtil isEmpty:strIcon])         // 设置学员头像
    {
        strIcon = @"";
    }
    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:strIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
            //            [self updateLogoImage:self.studentIconImageView];//裁切
        }
    }];
    
    [self.view addSubview:self.studentInfoView];
}
// 关闭学员信息
- (IBAction)clickForCancelInfoView:(id)sender {
    [self.studentInfoView removeFromSuperview];
}
// 电话联系
- (IBAction)callPhoneBtn:(id)sender {
    NSLog(@"%@",self.phoneNum);
    NSString *phoneNum = [NSString stringWithFormat:@"telprompt://%@",self.phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}
#pragma mark - 我的评价接口
- (void)GetMyEvaluation:(int) pageNum{
    
    
}


#pragma mark - 评价我的接口
- (void)GetEvaluationToMy:(int)pageNum{
    
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findAppraiseInfo", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    __weak  MyEvaluationViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC ParsingEvaluationForMineData:responseObject];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}
//
- (void)ParsingEvaluationForMineData:(NSDictionary *)data {
    
    
}
#pragma mark - 投诉我的接口
- (void)getComplaintToMy:(int)pageNum {
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findOrderAppeal", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    __weak  MyEvaluationViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC ParsingComplaintsForMineData:responseObject];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}
//投诉我的数据解析
- (void)ParsingComplaintsForMineData:(NSDictionary *)data
{
    [complainMyDataArr removeAllObjects];
    NSArray *dataArray =data[@"data"];
    if (dataArray.count == 0) {
        [self showAlert:@"暂时还没有订单" time:1.2];
        return;
    }
    
    for (NSDictionary *modelDic in dataArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"EvaluationOrderModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        EvaluationOrderModel *model = [[EvaluationOrderModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        
        for (NSString *key in modelDic) {
            [model setValue:modelDic[key] forKey:key];
        }
        [complainMyDataArr addObject:model];
    }
    NSLog(@"complainMyDataArr%@", complainMyDataArr);
    [self.mainTableView reloadData];
    
    
}

- (void)backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

@end
