//
//  MyTicketDetailViewController.m
//  guangda
//
//  Created by Ray on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyTicketDetailViewController.h"
#import "MyTicketDetailTableViewCell.h"
#import "CouponsModel+CoreDataProperties.h"
#define kCellNum 20

@interface MyTicketDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIButton *noDataButton;

@property (strong, nonatomic) IBOutlet UIView *ruleView;//规则页面

@property (strong, nonatomic) IBOutlet UIView *footBackView;
@property (strong, nonatomic) IBOutlet UILabel *altogetherTime;
@property (strong, nonatomic) IBOutlet UILabel *altogetherMoney;
@property (strong, nonatomic) IBOutlet UIButton *convertButton;
@property (strong, nonatomic) IBOutlet UILabel *headLabel;

//参数
@property (strong, nonatomic) NSMutableArray *ticketArray;
@property (strong, nonatomic) NSMutableArray *arrayList1;
@property (strong, nonatomic) NSMutableArray *arrayList2;

@property (strong, nonatomic) IBOutlet UIView *ruleBackView;
/**
 *可变数组
 */
@property (nonatomic, strong)NSMutableArray * couponsListAray;
@end

@implementation MyTicketDetailViewController
{
    NSMutableArray *selectArray;
    NSString *recordids;
    UIView *view;
}
- (NSMutableArray *)couponsListAray {
    if (!_couponsListAray) {
        _couponsListAray = [NSMutableArray array];
    }
    return _couponsListAray;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.altogetherMoney.hidden = YES;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = MColor(243, 243, 243);
    self.headLabel.hidden = YES;
    self.noDataButton.hidden = YES;
    self.convertButton.layer.cornerRadius = 4;
    self.convertButton.layer.masksToBounds = YES;
    
    self.ticketArray = [[NSMutableArray alloc]init];
    self.arrayList1 = [[NSMutableArray alloc]init];
    self.arrayList2 = [[NSMutableArray alloc]init];
    selectArray = [[NSMutableArray alloc]init];
    
    [self.noDataButton setImage:[UIImage imageNamed:@"no_coupon"] forState:UIControlStateDisabled];
    self.noDataButton.enabled = NO;
    //合计金额
    NSString *money = @"0";
    NSString *altogetherMoney = [NSString stringWithFormat:@"合计：%@元", money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:altogetherMoney];
    [string addAttribute:NSForegroundColorAttributeName value:MColor(246, 102, 93) range:NSMakeRange(3,money.length+1)];
    self.altogetherMoney.attributedText = string;
    
    //合计时间
    NSString *ticketNum = @"0";
    NSString *altogetherHours = @"0";
    NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%@张共%@小时",ticketNum,altogetherHours];
    self.altogetherTime.text = altogetherTimeStr;
    
    self.ruleBackView.layer.cornerRadius = 3;
    self.ruleBackView.layer.masksToBounds = YES;
}
#pragma mark - 网络请求
- (void) requestData{

    NSString *URL_Str = [NSString stringWithFormat:@"%@/coupon/api/couponMemberList",kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"memberId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"couponIsUsed"] = @"0";
    __weak  MyTicketDetailViewController  *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC parsingData:responseObject];
        }else {
            [VC showAlert:responseObject[@"msg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}

- (void)parsingData:(NSDictionary *)dataDic {
    [self.couponsListAray removeAllObjects];
    NSArray *dataArray =dataDic[@"data"];
    if (dataArray.count == 0) {
        return;
    }
    
    for (NSDictionary *modelDic in dataArray) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CouponsModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CouponsModel *model = [[CouponsModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        model.selected = @"0";
        for (NSString *key in modelDic) {
            NSLog(@"key%@ value%@", key,modelDic[key]);
            [model setValue:modelDic[key] forKey:key];
        }
        [self.couponsListAray addObject:model];
    }
    [self.mainTableView reloadData];
}
//ticketArray处理
- (void)handleTicketArray {
    for (int i = 0; i<self.ticketArray.count; i++) {
        NSDictionary *dic = self.ticketArray[i];
        if (i%2 == 0) {
            [self.arrayList1 addObject:dic];
        }else{
            [self.arrayList2 addObject:dic];
        }
    }
}
//立即兑换
- (IBAction)convertClick:(id)sender {
    if (self.couponsListAray.count > 0) {
        NSString *couponIdStr;
        
            for (CouponsModel *model in  self.couponsListAray) {
                if ([model.selected isEqualToString:@"1"]) {
                    NSLog(@"model%@", model);
                    if (couponIdStr.length == 0) {
                        couponIdStr = model.couponMemberId;
                    }else {
                        couponIdStr = [NSString stringWithFormat:@"%@,%@", couponIdStr,model.couponMemberId];
                    }
                }
            }
        
        NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/exchangeCoupons",kURL_SHY];
        NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
        URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
        NSLog(@"couponIdStr%@", couponIdStr);
        URL_Dic[@"couponMemberId"] =  couponIdStr;
        __weak  MyTicketDetailViewController *self_VC = self;
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress%@", uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject%@", responseObject);
            NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
            if ([resultStr isEqualToString:@"1"]) {
                  [self_VC showAlert:responseObject[@"msg"] time:1.0];
                [self_VC requestData];
            }else {
                [self_VC showAlert:responseObject[@"msg"] time:1.0];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error%@", error);
        }];
        
    }else{
        [self showAlert:@"请至少选择一张优惠券" time:1.0];
    }
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int a = self.couponsListAray.count%2;
    return self.couponsListAray.count/2 + a;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"MyTicketDetailTableViewCell";
    MyTicketDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    cell.clickButton1.indexPath  = indexPath;
    cell.clickButton2.indexPath  = indexPath;
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyTicketDetailTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    
    cell.clickButton1.tag = 1;
    cell.clickButton2.tag = 2;
    [cell.clickButton1 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.clickButton2 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //如果row 小于 数组/2 如果是双数 正好 如果是单数 会
    if (indexPath.row < self.couponsListAray.count/2) {
        CouponsModel *modelOne = self.couponsListAray[indexPath.row *2];
        CouponsModel *modelTwo = self.couponsListAray[indexPath.row * 2 +1];
        
        NSString *str1 = modelOne.couponTitle;
        NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
        cell.ticketFrom1.text = [self getFromString:@"1"];
        cell.ticketTime1.text = modelOne.createTimeStr;
        
        if ([modelOne.selected isEqualToString:@"0"]) {
            cell.selectTag1.hidden = YES;
        }else if([modelOne.selected isEqualToString:@"1"]){
            cell.selectTag1.hidden = NO;
        }
        
        if ([modelTwo.selected isEqualToString:@"0"]) {
            cell.selectTag2.hidden = YES;
        }else if([modelTwo.selected isEqualToString:@"1"]){
            cell.selectTag2.hidden = NO;
        }
        int state1 = modelOne.couponIsUsed;//判断有没有提现过
        if (state1 == 1) {
            [string1 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str1.length)];
            cell.clickButton1.enabled = NO;
            cell.applyLabel1.hidden = NO;
        }else{
            [string1 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
            cell.clickButton1.enabled = YES;
            cell.applyLabel1.hidden = YES;
        }
        cell.ticketName1.attributedText = string1;
        
        NSString *str2 = modelTwo.couponTitle;
        NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:str2];
        cell.ticketFrom2.text = [self getFromString:@"1"];
        cell.ticketTime2.text = modelTwo.createTimeStr;
        int state2 = modelTwo.couponIsUsed;//判断有没有提现过
        if (state2 == 1) {
            [string2 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str2.length)];
            cell.clickButton2.enabled = NO;
            cell.applyLabel2.hidden = NO;
        }else{
            [string2 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str2.length-3,3)];
            cell.clickButton2.enabled = YES;
            cell.applyLabel2.hidden = YES;
        }
        cell.ticketName2.attributedText = string2;
        
    }else{
            CouponsModel *modelOne = self.couponsListAray[indexPath.row *2];
            NSString *str1 = modelOne.couponTitle;
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
            cell.ticketFrom1.text = [self getFromString:@"1"];
            cell.ticketTime1.text = modelOne.createTimeStr;
        
        if ([modelOne.selected isEqualToString:@"0"]) {
            cell.selectTag1.hidden = YES;
        }else if([modelOne.selected isEqualToString:@"1"]){
            cell.selectTag1.hidden = NO;
        }
        int state1 = modelOne.couponIsUsed;//判断有没有提现过
            if (state1 == 1) {
                [string1 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str1.length)];
                cell.clickButton1.enabled = NO;
                cell.applyLabel1.hidden = NO;
            }else{
                [string1 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
                cell.clickButton1.enabled = YES;
                cell.applyLabel1.hidden = YES;
            }
            cell.ticketName1.attributedText = string1;
            cell.backView2.hidden = YES;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)getFromString:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"%@",sender];
    if ([str isEqualToString:@"0"]) {
        str = @"由官方平台发行";
    }else if ([str isEqualToString:@"1"]){
        str = @"由驾校发行";
    }else if ([str isEqualToString:@"2"]){
        str = @"由教练发行";
    }
    return str;
}

-(void)selectTicket:(DSButton *) sender {
        if (sender.tag == 1) {
            CouponsModel *model = self.couponsListAray[sender.indexPath.row * 2];
            if ([model.selected isEqualToString:@"1"]) {
                model.selected = @"0";
            }else {
                model.selected = @"1";
            }
        }else{
         CouponsModel *model = self.couponsListAray[sender.indexPath.row *2 +1];
            if ([model.selected isEqualToString:@"1"]) {
                model.selected = @"0";
            }else {
                model.selected = @"1";
            }
        }
    NSLog(@"self.couponsListAray%@", self.couponsListAray);
    int num = 0;
    int time = 0;
    
    for (int i= 0; i < self.couponsListAray.count; i++) {
        CouponsModel *model = self.couponsListAray[i];
        if ([model.selected isEqualToString:@"1"]   ) {
            num ++ ;
            time += model.couponDuration;
        }
    }
    NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%d张共%d小时",num,time];
    self.altogetherTime.text = altogetherTimeStr;
    [self.mainTableView reloadData];
}

//兑换规则
- (IBAction)clickForRule:(id)sender {
    self.ruleView.frame = self.view.frame;
    [self.view addSubview:self.ruleView];
}

- (IBAction)removeRuleView:(id)sender {
    [self.ruleView removeFromSuperview];
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
