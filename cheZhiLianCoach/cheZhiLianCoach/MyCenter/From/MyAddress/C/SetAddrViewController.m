//
//  SetAddrViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SetAddrViewController.h"
#import "SearchAddrViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SetAddrViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *addrArray;

@property (strong, nonatomic) IBOutlet UIView *defaultAddrView;
@property (strong, nonatomic) IBOutlet UIButton *nodataImageBtn;

//参数
@property (strong, nonatomic) NSString *addressid;//设为默认练车地点的地址id
@property (strong, nonatomic) NSIndexPath *delIndexPath;

@end

@implementation SetAddrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getAddressData];//获取练车地点信息
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([self.fromSchedule intValue] == 1) {
        self.fromSchedule = @"0";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
    }
}

#pragma mark - UITabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SetAddrCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        
        
        // 添加按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(clickToDefaultAddr:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"[默认地址]" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 13.0];
        [button setTitleColor:MColor(84, 204, 153) forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 10;
        [cell.contentView addSubview:button];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 79, kScreen_widht, 1)];
        line.backgroundColor = MColor(211, 211, 211);
        line.tag = 20;
        [cell.contentView addSubview:line];
    }
    
    // 加载数据
//    NSDictionary *dic = self.addrArray[indexPath.row];
//    NSString *iscurr = [dic[@"iscurrent"] description];//是否是当前使用地址 0.不是 1.是
//    NSString *area = dic[@"area"];
//    NSString *detail = dic[@"detail"];
    
    if(![CommonUtil isEmpty:@"123"] && ![@"null" isEqualToString:@"123"]){
        cell.textLabel.text = @"你猜啊";
    }else{
        cell.textLabel.text = @"";
    }
    
    cell.detailTextLabel.text = @"详情地址你猜爱对方男反分裂能看房三分裤那时快电脑";
    
    CGSize size = [CommonUtil sizeWithString:@"详情地址你猜爱对方男反分裂能看房三分裤那时快电脑" fontSize:17 sizewidth:kScreen_widht - 65 - 33 - 13 sizeheight:MAXFLOAT];
    cell.detailTextLabel.numberOfLines = ceil(size.height/17);
    
    if ([@"1" intValue] == 1) {
        //当前使用
        UIView *view = [cell.contentView viewWithTag:10];
        if ([view isKindOfClass:[UIButton class]]) {
            CGFloat cellHeight = 80 - 21 + size.height;
            CGSize areaSize = [CommonUtil sizeWithString:@"你猜啊" fontSize:13 sizewidth:kScreen_widht - 65 - 13 - 33 sizeheight:MAXFLOAT];
            CGFloat y = ceil((cellHeight - size.height - areaSize.height)/2);
            
            UIButton *button = (UIButton *)view;
            button.frame = CGRectMake(kScreen_widht - 65 - 13, y - 10, 65, 20);
            button.hidden = NO;
            
        }
        
        cell.imageView.image = [UIImage imageNamed:@"icon_addrarrow"];
    }else{
        UIView *view = [cell.contentView viewWithTag:10];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.hidden = YES;
            
            CGFloat cellHeight = 80 - 21 + size.height;
            CGSize areaSize = [CommonUtil sizeWithString:@"你猜啊" fontSize:13 sizewidth:kScreen_widht - 65 - 13 - 33 sizeheight:MAXFLOAT];
            CGFloat y = ceil((cellHeight - size.height - areaSize.height)/2);
            
            button.frame = CGRectMake(kScreen_widht - 65 - 13, y - 5, 65, 25);
        }
        
        cell.imageView.image = [UIImage imageNamed:@"icon_myaddr_greymark"];
    }
    
    //下划线
    UIView *view = [cell.contentView viewWithTag:20];
    if (view != nil) {
        view.frame = CGRectMake(0, 80 - 21 + size.height - 1, kScreen_widht, 1);
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 加载数据

    CGSize size = [CommonUtil sizeWithString:@"详情地址你猜爱对方男反分裂能看房三分裤那时快电脑" fontSize:17 sizewidth:kScreen_widht - 65 - 33 - 13 sizeheight:MAXFLOAT];
    return 80 - 21 + size.height;
}

// cell滑动删除按钮
- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.addrArray[indexPath.row];
    NSString *iscurrent = [dic[@"iscurrent"] description];
    if ([iscurrent boolValue]) {
        [self makeToast:@"默认地址不能删除"];
        return;
    }
    NSString *addressid = [dic[@"addressid"] description];
    self.delIndexPath = indexPath;
    
    [self delAddress:addressid];
    
    //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.addrArray[indexPath.row];
    self.addressid = [dic[@"addressid"] description];
    
    self.defaultAddrView.frame = self.view.bounds;
    [self.view addSubview:self.defaultAddrView];
}

#pragma mark - action
- (IBAction)clickToSearchAddrView:(id)sender {
    
    SearchAddrViewController *targetViewController = [[SearchAddrViewController alloc] initWithNibName:@"SearchAddrViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (void)clickToDefaultAddr:(id)sender {
    self.defaultAddrView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.defaultAddrView];
}

- (IBAction)clickToClose:(id)sender {
    [self.defaultAddrView removeFromSuperview];
}

#pragma mark 设置为默认地址
- (IBAction)clickToSetDefaultAddr:(id)sender {
    [self setDefaultAddress:self.addressid];
    
}

#pragma mark - 接口
//获取地址信息
- (void)getAddressData{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
  
}

//设为默认地址
- (void)setDefaultAddress:(NSString *)addressid{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
      [DejalBezelActivityView activityViewForView:self.view];
}

//删除地址
- (void)delAddress:(NSString *)addressid{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
        [DejalBezelActivityView activityViewForView:self.view];
}



- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
