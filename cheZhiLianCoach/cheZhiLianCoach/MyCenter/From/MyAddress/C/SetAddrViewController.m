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
#import "SetAddrTVCell.h"
@interface SetAddrViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *addrArray;

@property (strong, nonatomic) IBOutlet UIView *defaultAddrView;
@property (strong, nonatomic) IBOutlet UIButton *nodataImageBtn;

//参数
@property (strong, nonatomic) NSString *addressid;//设为默认练车地点的地址id
@property (strong, nonatomic) NSIndexPath *delIndexPath;

@end

@implementation SetAddrViewController {
    

}

- (NSMutableArray *)addrArray {
    if (!_addrArray) {
        _addrArray = [NSMutableArray array];
    }
    return _addrArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"SetAddrTVCell" bundle:nil] forCellReuseIdentifier:@"SetAddrTVCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getAddressData];//获取练车地点信息
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([self.fromSchedule intValue] == 1) {
        self.fromSchedule = @"0";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSchedule" object:nil];
    }
}
#pragma mark - UITabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addrArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SetAddrTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SetAddrTVCell" forIndexPath:indexPath];
    CoachDriverAddreModel *model = self.addrArray[indexPath.row];
    cell.contentLabel.text = model.addressName;
    if (model.isDefault == 1) {
        [cell.stateImage setImage:[UIImage imageNamed:@"icon_addrarrow"] forState:(UIControlStateNormal)];
        cell.defaultLabel.text = @"[默认地址]";
        cell.stateLabel.text = @"正在使用";
        cell.defaultLabel.font = [UIFont systemFontOfSize: 13.0];
        cell.defaultLabel.textColor = MColor(84, 204, 153);
    }else{
           [cell.stateImage setImage:[UIImage imageNamed:@"icon_myaddr_greymark"] forState:(UIControlStateNormal)];
        cell.defaultLabel.text = @"";
        cell.stateLabel.text = @"";
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
    
    CoachDriverAddreModel *model = self.addrArray[indexPath.row];
    
    if (model.isDefault == 1)  {
        [self makeToast:@"默认地址不能删除"];
        return;
    }
    [self delAddress:model.addressId];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CoachDriverAddreModel *model = self.addrArray[indexPath.row];
    if (model.isDefault == 1) {
        return;
    }
    self.addressid = model.addressId;
    self.defaultAddrView.frame = self.view.bounds;
    [self.view addSubview:self.defaultAddrView];
}

#pragma mark - action  添加搜索地址
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
    [DejalBezelActivityView activityViewForView:self.view];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/setDefault", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"addressId"] = self.addressid;
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    __weak  SetAddrViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC showAlert:responseObject[@"masg"] time:1.2];
            [VC.defaultAddrView removeFromSuperview];
        }else {
            [VC showAlert:responseObject[@"masg"] time:1.2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];

    
}

#pragma mark - 接口
//获取地址信息
- (void)getAddressData{
    [DejalBezelActivityView activityViewForView:self.view];
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/findTrainAddressList", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    __weak  SetAddrViewController *VC = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer.timeoutInterval = 5;
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取地址信息responseObject%@", responseObject);
        [DejalBezelActivityView removeView];
        [VC ParsingAddressInfor:responseObject[@"data"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [DejalBezelActivityView removeView];
        NSLog(@"error%@", error);
    }];
}

- (void)ParsingAddressInfor:(NSArray *)data {
    if (data.count == 0) {
        [self showAlert:@"还没有添加地址" time:1.2];
        return;
    }
    for (NSDictionary *dic in data) {
        NSEntityDescription *des = [NSEntityDescription entityForName:@"CoachDriverAddreModel" inManagedObjectContext:self.managedContext];
        //根据描述 创建实体对象
        CoachDriverAddreModel *model = [[CoachDriverAddreModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
        for (NSString *key in dic) {
            [model setValue:dic[key] forUndefinedKey:key];
        }
        [self.addrArray addObject:model];
    }
    NSLog(@"self.addrArray%@", self.addrArray);
    [self.mainTableView reloadData];
}

//删除地址
- (void)delAddress:(NSString *)addressid{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    
    
}



- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
@end
