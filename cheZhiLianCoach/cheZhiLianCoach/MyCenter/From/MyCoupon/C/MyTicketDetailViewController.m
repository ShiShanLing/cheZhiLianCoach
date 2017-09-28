//
//  MyTicketDetailViewController.m
//  guangda
//
//  Created by Ray on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyTicketDetailViewController.h"
#import "MyTicketDetailTableViewCell.h"

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
@end

@implementation MyTicketDetailViewController
{
    NSMutableArray *selectArray;
    NSString *requsetTag;
    NSString *recordids;
    UIView *view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = MColor(243, 243, 243);
    
    self.noDataButton.hidden = YES;
    self.convertButton.layer.cornerRadius = 4;
    self.convertButton.layer.masksToBounds = YES;
    
    self.ticketArray = [[NSMutableArray alloc]init];
    self.arrayList1 = [[NSMutableArray alloc]init];
    self.arrayList2 = [[NSMutableArray alloc]init];
    selectArray = [[NSMutableArray alloc]init];
    
    [self.noDataButton setImage:[UIImage imageNamed:@"no_coupon"] forState:UIControlStateDisabled];
    self.noDataButton.enabled = NO;
    
    requsetTag = @"1";
   // [self getAmountData];
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

//ticketArray处理
- (void)handleTicketArray
{
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
    if (selectArray.count > 0) {
        requsetTag = @"2";
      //  [self getAmountData];
    }else{
        [self makeToast:@"请至少选择一张学车券"];
    }
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return kCellNum/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellident = @"MyTicketDetailTableViewCell";
    MyTicketDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyTicketDetailTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    }
    cell.selectTag1.hidden = YES;
    cell.selectTag2.hidden = YES;
    cell.clickButton1.tag = [NSNumber numberWithInt:((int)indexPath.row*10+0)].intValue;
    cell.clickButton2.tag = [NSNumber numberWithInt:((int)indexPath.row*10+1)].intValue;
    [cell.clickButton1 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    [cell.clickButton2 addTarget:self action:@selector(selectTicket:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row < kCellNum/2) {
        NSString *str1 = [NSString stringWithFormat:@"%@小时学车券", @"3"];
        NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
        cell.ticketFrom1.text = [self getFromString:@"0"];
        cell.ticketTime1.text = @"2017-07-28";
        NSString *state1 = @"2";
        if (state1.intValue == 2) {
            [string1 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str1.length)];
            cell.clickButton1.enabled = NO;
            cell.applyLabel1.hidden = NO;
        }else{
            [string1 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
            cell.clickButton1.enabled = YES;
            cell.applyLabel1.hidden = YES;
        }
        cell.ticketName1.attributedText = string1;
        
        
        NSString *str2 = [NSString stringWithFormat:@"%@小时学车券", @"4"];
        NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:str2];
        cell.ticketFrom2.text = [self getFromString:@"1"];
        cell.ticketTime2.text = @"2017-07-27";
        NSString *state2 = @"2";
        if (state2.intValue == 2) {
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
        if (kCellNum%2 != 0) {
            
            NSString *str1 = [NSString stringWithFormat:@"%@小时学车券", @"3"];
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
            cell.ticketFrom1.text = [self getFromString:@"0"];
            cell.ticketTime1.text = @"2017-07-28";
            NSString *state1 = @"2";
            if (state1.intValue == 2) {
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
        }else{
            
            NSString *str1 = [NSString stringWithFormat:@"%@小时学车券", @"3"];
            NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:str1];
            cell.ticketFrom1.text = [self getFromString:@"0"];
            cell.ticketTime1.text = @"2017-07-28";
            NSString *state1 = @"2";
            if (state1.intValue == 2) {
                [string1 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str1.length)];
                cell.clickButton1.enabled = NO;
                cell.applyLabel1.hidden = NO;
            }else{
                [string1 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str1.length-3,3)];
                cell.clickButton1.enabled = YES;
                cell.applyLabel1.hidden = YES;
            }
            cell.ticketName1.attributedText = string1;
            
            NSString *str2 = [NSString stringWithFormat:@"%@小时学车券", @"4"];
            NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:str2];
            cell.ticketFrom2.text = [self getFromString:@"1"];
            cell.ticketTime2.text = @"2017-07-27";
            NSString *state2 = @"2";
            if (state2.intValue == 2) {
                [string2 addAttribute:NSForegroundColorAttributeName value:MColor(222, 222, 222) range:NSMakeRange(0,str2.length)];
                cell.clickButton2.enabled = NO;
                cell.applyLabel2.hidden = NO;
            }else{
                [string2 addAttribute:NSForegroundColorAttributeName value:MColor(37, 37, 37) range:NSMakeRange(str2.length-3,3)];
                cell.clickButton2.enabled = YES;
                cell.applyLabel2.hidden = YES;
            }
            cell.ticketName2.attributedText = string2;
        }
    }
    
    if ([selectArray containsObject:[NSNumber numberWithInteger:((int)indexPath.row*10+0)]]) {
        cell.selectTag1.hidden = NO;
    }
    if ([selectArray containsObject:[NSNumber numberWithInteger:((int)indexPath.row*10+1)]]){
        cell.selectTag2.hidden = NO;
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

-(void)selectTicket:(UIButton *) sender{
    if ([selectArray containsObject:[NSNumber numberWithInteger:sender.tag]]) {
        [selectArray removeObject:[NSNumber numberWithInteger:sender.tag]];
    }else{
        [selectArray addObject:[NSNumber numberWithInteger:sender.tag]];
    }
    
    //小巴券id的String
    NSMutableString *str = [[NSMutableString alloc]init];
    //合计金额
    NSString *money = @"0";
    //合计时间
    NSString *ticketNum = @"0";
    NSString *altogetherHours = @"0";
    for (int i=0; i<selectArray.count; i++) {
        NSNumber *num = selectArray[i];
        NSNumber *buttonTag = [NSNumber numberWithInt:(num.intValue%10)];
        NSNumber *cellRow = [NSNumber numberWithInt:(num.intValue/10)];
        NSDictionary *dic = [[NSDictionary alloc]init];
        if (buttonTag.intValue == 0) {
            dic = self.arrayList1[cellRow.intValue];
        }else{
            dic = self.arrayList2[cellRow.intValue];
        }
        NSNumber *valueNum = dic[@"value"];
        altogetherHours = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:altogetherHours.intValue+valueNum.intValue]];
        
        NSNumber *money_valueNum = dic[@"money_value"];
        money = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:money.intValue+money_valueNum.intValue]];
        
        NSNumber *recordidNum = dic[@"recordid"];
        [str appendString:[NSString stringWithFormat:@"%@,",recordidNum]];
    }
    //小巴券的id string
    if (str.length >0) {
       recordids = [str substringToIndex:str.length-1];
    }else{
       recordids = str;
    }
    //合计数量
    ticketNum = [NSString stringWithFormat:@"%lu",(unsigned long)selectArray.count];
    //合计金额
    NSString *altogetherMoney = [NSString stringWithFormat:@"合计：%@元", money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:altogetherMoney];
    [string addAttribute:NSForegroundColorAttributeName value:MColor(246, 102, 93) range:NSMakeRange(3,money.length+1)];
    self.altogetherMoney.attributedText = string;
    
    //合计时间
    NSString *altogetherTimeStr = [NSString stringWithFormat:@"已选%@张共%@小时",ticketNum,altogetherHours];
    self.altogetherTime.text = altogetherTimeStr;
    
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
