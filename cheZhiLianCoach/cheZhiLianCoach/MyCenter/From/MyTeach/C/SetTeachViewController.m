//
//  SetTeachViewController.m
//  guangda
//
//  Created by Yuhangping on 15/4/22.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SetTeachViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SetTeachViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *defaultTeachView;

@property (strong, nonatomic) NSMutableArray *teachArray;
@property (strong, nonatomic) NSMutableArray *teachIdArray;
//参数
@property (strong, nonatomic) NSString *teachssid;//设为默认地址的科目id

@end

@implementation SetTeachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTeachData];//获取地址信息
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - UITabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teachArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SetAddrCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        //cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        
        
        // 添加按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(kScreen_widht - 65 - 13, - 4, 65, 60)];
        [button addTarget:self action:@selector(clickToDefaultTeach:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"[默认科目]" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 13.0];
        [button setTitleColor:MColor(84, 204, 153) forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 10;
        [cell.contentView addSubview:button];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, kScreen_widht, 1)];
        line.backgroundColor = MColor(211, 211, 211);
        line.tag = 20;
        [cell.contentView addSubview:line];
    }
    
    // 加载数据
    NSDictionary *dic = self.teachArray[indexPath.row];
    NSString *iscurr = [dic[@"isdefault"] description];//是否是当前使用科目 0.不是 1.是
    NSString *subjectname = dic[@"subjectname"];
    cell.detailTextLabel.text = subjectname;
    CGSize size = [CommonUtil sizeWithString:subjectname fontSize:17 sizewidth:kScreen_widht - 65 sizeheight:MAXFLOAT];
    if ([iscurr intValue] == 1) {
            //当前使用
        UIView *view = [cell.contentView viewWithTag:10];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.hidden = NO;
                
        }
            
        cell.imageView.image = [UIImage imageNamed:@"icon_teachcai5"];
    }else{
        UIView *view = [cell.contentView viewWithTag:10];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.hidden = YES;
        }
            
        cell.imageView.image = [UIImage imageNamed:@"icon_teachhui5"];
    }
        
    
    
    //下划线
    UIView *view = [cell.contentView viewWithTag:20];
    if (view != nil) {
        view.frame = CGRectMake(0, 54 - 21 + size.height - 1, kScreen_widht, 1);
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 加载数据
    NSDictionary *dic = self.teachArray[indexPath.row];
    NSString *subjectname = dic[@"subjectname"];
    
    CGSize size = [CommonUtil sizeWithString:subjectname fontSize:17 sizewidth:kScreen_widht - 65 sizeheight:MAXFLOAT];
    
    return 54 - 21 + size.height;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.teachArray[indexPath.row];
    self.teachssid = [dic[@"subjectid"] description];
    
    self.defaultTeachView.frame = self.view.bounds;
    [self.view addSubview:self.defaultTeachView];
}

// 弹出设置
- (void)clickToDefaultTeach:(id)sender {
    self.defaultTeachView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.defaultTeachView];
}

// 关闭设置
- (IBAction)clickToClose:(id)sender {
    [self.defaultTeachView removeFromSuperview];
}

#pragma mark 设置为默认科目
- (IBAction)clickToSetDefaultTeach:(id)sender {
    [self setDefaultTeach:self.teachssid];
    
}

#pragma mark - 接口
//获取科目信息
- (void)getTeachData{
   [self makeToast:@"功能未开通"];
}

//设为默认科目
- (void)setDefaultTeach:(NSString *)teachid{

    [self makeToast:@"功能未开通"];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
