//
//  CoachInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachInfoViewController.h"
#import "MyInfoCell.h"
//#import "BigPhotoViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CZPhotoPickerController.h"
#import "DatePickerViewController.h"
#import "LoginViewController.h"
#import "SchoolSelectViewController.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import "XBProvince.h"
#import "CarModelViewController.h"
@interface CoachInfoViewController ()<UITextFieldDelegate, DatePickerViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,LocationViewControllerDelegate> {
    CGFloat _y;
    NSInteger selectRow;
    NSString *isChangeCity;
//    NSString *cityid;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UIView *idPhototView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (strong, nonatomic) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) UIImageView *clickImageView;//需要显示图片的imageview
@property (strong, nonatomic) UILabel *clickLabel;//显示图片的文字
@property (strong, nonatomic) UIButton *clickDelBtn;
@property (strong, nonatomic) IBOutlet UIView *keepLabelView; // 动态存放label
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keepViewConstraint; // 动态存放label高度
@property (strong, nonatomic) IBOutlet UIButton *keepBtnOutlet;

@property (strong, nonatomic) IBOutlet UILabel *warmingLabel;//提示语 ----

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertDetailView;

// 身份证号码
@property (strong, nonatomic) IBOutlet UITextField *idCardField;
@property (strong, nonatomic) IBOutlet UIImageView *idCardPencilImage;

// 教练证号
@property (strong, nonatomic) IBOutlet UITextField *coachCardField;
@property (strong, nonatomic) IBOutlet UIImageView *coachCardPencilImage;

// 驾驶证号
@property (strong, nonatomic) IBOutlet UITextField *driveCardField;
@property (strong, nonatomic) IBOutlet UIImageView *driveCardPencilImage;

// 汽车年检证号
@property (strong, nonatomic) IBOutlet UITextField *carCheckField;
@property (strong, nonatomic) IBOutlet UIImageView *carCheckPencilImage;

// 教学用车牌照
@property (strong, nonatomic) IBOutlet UITextField *teachCarField;
@property (strong, nonatomic) IBOutlet UIImageView *teachCarPencilImage;

// 教学用车型号
@property (strong, nonatomic) IBOutlet UITextField *teachCarCardField;

// 准教车型
@property (strong, nonatomic) IBOutlet UIButton *C1Button;
@property (strong, nonatomic) IBOutlet UIButton *C2Button;

@property (strong, nonatomic) IBOutlet UILabel *coachCarLabel ; //教练车型选择

@property (strong, nonatomic) IBOutlet UIView *carModelView;
@property (strong, nonatomic) IBOutlet UITextField *carModelField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carModelViewHeight;
@property (strong, nonatomic) IBOutlet UIView *selectView; // 选择器
@property (nonatomic, strong) IBOutlet UIPickerView *carModelPicker;
@property (strong, nonatomic) NSMutableArray *carModelArray;      // 准教车型
@property (strong, nonatomic) NSMutableArray *myCarModelArray;
@property (strong, nonatomic) IBOutlet UIButton *teachCarBtnOutlet;
@property (strong, nonatomic) NSMutableArray *TeachCarModeArray;  // 教学用车型号
@property (strong, nonatomic) NSMutableArray *carSchoolArray;

@property (strong, nonatomic) IBOutlet UIButton *idCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *idCardBackDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachCarCardDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *carCheckDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *carCheckBackDelBtn;
@property (strong, nonatomic) IBOutlet UIButton *coachTureIconDelBtn;

// 身份证到期时间
@property (strong, nonatomic) IBOutlet UIView *cardMadeTimeView;
@property (strong, nonatomic) IBOutlet UITextField *cardMadeTimeField;

// 教练证到期时间
@property (strong, nonatomic) IBOutlet UITextField *coachMadeTimeField;

// 驾驶证到期时间
@property (strong, nonatomic) IBOutlet UITextField *driveMadeTimeField;

// 汽车年检证到期时间
@property (strong, nonatomic) IBOutlet UITextField *carCheckMadeTimeField;

/*  以下4个view内部各有5个子控件，其tag为:
 image:  100 200 300 400
 label:  101 201 301 401
 editBtn:102 202 302 402
 bigPhotoBtn:103 203 303 403
 deleteBtn:104 204 304 404
 */
@property (strong, nonatomic) IBOutlet UIView *idCardFrontView;     // 身份证正面
@property (strong, nonatomic) IBOutlet UIView *idCardBackView;      // 身份证反面
@property (strong, nonatomic) IBOutlet UIView *coachCardView;       // 教练证
@property (strong, nonatomic) IBOutlet UIView *coachCarCardView;    // 教练车驾驶证
@property (strong, nonatomic) IBOutlet UIView *carCheckView;      // 车辆行驶证正面
@property (strong, nonatomic) IBOutlet UIView *carCheckBackView;       // 车辆行驶证反面
@property (strong, nonatomic) IBOutlet UIView *coachTureIconView;    // 教练真实头像

@property (strong, nonatomic) IBOutlet UILabel *idCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *idCardBackLabel;
/**
 *这个不要动
 */
@property (strong, nonatomic) IBOutlet UILabel *coachCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachCarCardLabel;
@property (strong, nonatomic) IBOutlet UILabel *carCheckLabel;
@property (strong, nonatomic) IBOutlet UILabel *carCheckBackLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachTureIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;//教练名字

//证件图片
@property (strong, nonatomic) IBOutlet UIImageView *idCardImageView; // 身份证正面
@property (strong, nonatomic) IBOutlet UIImageView *idCardBackImageView;  // 身份证反面
@property (strong, nonatomic) IBOutlet UIImageView *coachCardImageView; // 教练证 ----
@property (strong, nonatomic) IBOutlet UIImageView *coachCarCardImageView; // 教练车驾驶证
@property (strong, nonatomic) IBOutlet UIImageView *carCheckImageView; // 车辆年检证&车辆行驶证正面
@property (strong, nonatomic) IBOutlet UIImageView *carCheckBackImageView; // 车辆行驶证反面
@property (strong, nonatomic) IBOutlet UIImageView *coachTureIconImageView; // 教练真实照片
//证件图片后台返回路径
/**
 *身份证正面
 */
@property (nonatomic, strong)NSString *idCardPath;
/**
 *身份证反面
 */
@property (nonatomic, strong)NSString *idCardBackPath;
/**
 *教练证
 */
@property (nonatomic, strong)NSString *carCheckPath;
/**
 *车辆驾驶证
 */
@property (nonatomic, strong)NSString *carCheckBackPaht;


//参数
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *hints;
@property (strong, nonatomic) NSArray *testInfo;
@property (strong, nonatomic) NSMutableDictionary *msgDic;//参数
@property (strong, nonatomic) NSString *userState;//2：通过审核（不可修改数据）

// 省市区
@property (strong, nonatomic) XBProvince *selectProvince;
@property (strong, nonatomic) XBCity *selectCity;
@property (strong, nonatomic) XBArea *selectArea;
@property (strong, nonatomic) NSString *selectProvinceid;
@property (strong, nonatomic) NSString *selectCityid;
@property (strong, nonatomic) NSString *selectAreaid; //地区id

@property (strong, nonatomic) IBOutlet UILabel *cityNameLabel ;   //----城市名字label


// 返回按钮
@property (strong, nonatomic) IBOutlet UIButton *backBtn;

// 时间
@property (strong, nonatomic) UITextField *dateTimeTextField;
@property (assign, nonatomic) NSInteger dataTag;
@property (assign, nonatomic) NSInteger teachCarTag;

// 选择教学车型ID
@property (copy, nonatomic) NSString *teachCarID;
@property (copy, nonatomic) NSString *carSchoolID;

- (IBAction)clickForCommit:(id)sender;
//- (IBAction)clickForCarModel:(id)sender;
//- (IBAction)clickForCardMadeTime:(id)sender;


- (IBAction)clickForPhoto:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UILabel *schoolTextFiled ;//联系方式

- (IBAction)clickForSelectSchool:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *selectSchoolButton;

@property (copy, nonatomic) NSString *schoolid;

@end

@implementation CoachInfoViewController {
 
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self RequestCoachCurrentState];
    self.coachCardImageView.tag = 201;
    self.coachCarCardImageView.tag = 202;
    self.carCheckImageView.tag = 203;
    self.carCheckBackImageView.tag = 204;
    
    [self.mainScrollView contentSizeToFit];
//[self getCoachDetail];
//    [self getCarMode];
    // _mainViewHeight.constant = 1360;
    self.userState = 0;
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
    self.userState = [userInfo[@"state"] description];
    self.warmingLabel.text = @"正在查询您的审核状态...";
    _myCarModelArray = [[NSMutableArray alloc] init];
    self.msgDic = [NSMutableDictionary dictionary];
    _TeachCarModeArray = [[NSMutableArray alloc] init];
    _carModelArray = [[NSMutableArray alloc] init];
    _teachCarID = @"";
    _carSchoolArray = [NSMutableArray array];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    //设置弹框圆角
    self.alertDetailView.layer.cornerRadius = 5;
    self.alertDetailView.layer.masksToBounds = YES;
    
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCarModelData) name:@"updateModelList" object:nil];
    
    [self.C1Button setImage:[UIImage imageNamed:@"coupon_unselected"] forState:UIControlStateNormal];
    [self.C1Button setImage:[UIImage imageNamed:@"coupon_selected"] forState:UIControlStateSelected];
    [self.C2Button setImage:[UIImage imageNamed:@"coupon_unselected"] forState:UIControlStateNormal];
    [self.C2Button setImage:[UIImage imageNamed:@"coupon_selected"] forState:UIControlStateSelected];
    
    // 判断哪个界面推出此界面 修改相应的样式
    if ([_superViewNum intValue] == 0) {
        // 登录注册界面过来的
        [self.backBtn setImage:nil forState:UIControlStateNormal];
        [self.backBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:MColor(32, 120, 180) forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.backBtn addTarget:self action:@selector(ignoreClick) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *idNum = [userInfo[@"id_cardnum"] description]; // 身份证
        //身份证
        self.idCardField.text = idNum;
        
    }else{
        // 修改账号资料
        [self.backBtn setImage:[UIImage imageNamed:@"icon_arrow_back"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [self updateUserMsg];//给信息赋值
    }
}

- (void) RequestCoachCurrentState{
    //http://192.168.100.101:8080/com-zerosoft-boot-assembly-seller-local-1.0.0-SNAPSHOT/coach/api/detail?coachId=
    
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/detail", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    __weak CoachInfoViewController *VC = self;
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"0"]) {
            [VC makeToast:responseObject[@"msg"]];
        }else {
            [VC ParsingCoachData:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
}

- (void)ParsingCoachData:(NSDictionary *)dataDic {
    
    if (![dataDic[@"data"] isKindOfClass:[NSArray class]]) {
        [self makeToast:@"资料获取失败"];
        return;
    }
    NSArray *coachArray =  dataDic[@"data"];
  
    if (coachArray.count == 0) {
          [self makeToast:@"资料获取失败"];
        return;
    }
    NSDictionary *coachDataDic =coachArray[0];
    
    NSEntityDescription *des = [NSEntityDescription entityForName:@"CoachAuditStatusModel" inManagedObjectContext:self.managedContext];
    //根据描述 创建实体对象
    CoachAuditStatusModel *model = [[CoachAuditStatusModel alloc] initWithEntity:des insertIntoManagedObjectContext:self.managedContext];
    for (NSString *key in coachDataDic) {
        NSLog(@"key%@", key);
        if ([key isEqualToString:@"state"]) {
            [UserDataSingleton mainSingleton].approvalState =[NSString stringWithFormat:@"%@", coachDataDic[key]];
        }
        if ([key isEqualToString:@"coachId"]) {
            [UserDataSingleton mainSingleton].coachId =[NSString stringWithFormat:@"%@", coachDataDic[key]];
        }

        if ([key isEqualToString:@"realName"]) {
            [UserDataSingleton mainSingleton].userName =[NSString stringWithFormat:@"%@", coachDataDic[key]];
            
        }
        if ([key isEqualToString:@"balance"]) {
            [UserDataSingleton mainSingleton].balance =[NSString stringWithFormat:@"%@", coachDataDic[key]];
        }
        [model setValue:coachDataDic[key] forKey:key];
        
        
    }
    [UserDataSingleton mainSingleton].approvalState = [NSString stringWithFormat:@"%d", model.state];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" "];
    self.cityNameLabel.text = [model.address  stringByTrimmingCharactersInSet:set];
    self.schoolTextFiled.text = model.phone;
    self.coachCarLabel.text = @"C1";
    self.coachNameLabel.text = model.realName;
    [self.coachCardImageView sd_setImageWithURL:[NSString stringWithFormat:@"%@/img%@", kURL_SHY, model.idCardFront] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
    [self.coachCarCardImageView sd_setImageWithURL:[NSString stringWithFormat:@"%@/img%@", kURL_SHY, model.idCardBack] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
    [self.carCheckImageView sd_setImageWithURL:[NSString stringWithFormat:@"%@/img%@", kURL_SHY, model.coachCertificate] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"]];
    [self.carCheckBackImageView sd_setImageWithURL:[NSString stringWithFormat:@"%@/img%@", kURL_SHY, model.driveCertificate] placeholderImage:[UIImage imageNamed:@"bg_myinfo_camera"] ];
    int state = model.state;
    self.userState = [NSString stringWithFormat:@"%hd", model.state];
    [UserDataSingleton mainSingleton].approvalState = [NSString stringWithFormat:@"%hd", model.state];
    switch (state) {
        case 0:
            self.warmingLabel.text = @"您还未提交申请...";
             self.commitBtn.hidden = NO;
            break;
        case 1:
            self.warmingLabel.text = @"正在等待审核..";
             self.commitBtn.hidden = YES;
            break;
        case 2:
            self.warmingLabel.text = @"申请已经通过";
             self.commitBtn.hidden = YES;
            break;
        case 3:
            self.warmingLabel.text = @"申请已经拒绝";
             self.commitBtn.hidden = YES;
            break;
        default:
            break;
    }
    NSLog(@"ParsingCoachData%@", model);

}
// 跳过
- (void)ignoreClick {
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSelfView" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backupgroupTap:(id)sender{
    [self.idCardField resignFirstResponder];
    [self.coachCardField resignFirstResponder];
    [self.carModelField resignFirstResponder];
    [self.cardMadeTimeField resignFirstResponder];
    [self.driveCardField resignFirstResponder];
    [self.carCheckField resignFirstResponder];
    [self.teachCarField resignFirstResponder];
    [self.coachMadeTimeField resignFirstResponder];
    [self.driveMadeTimeField resignFirstResponder];
    [self.carCheckMadeTimeField resignFirstResponder];
    [self.teachCarCardField resignFirstResponder];
}
#pragma mark - 加载驾照信息
- (void)updateUserMsg{
       
}
#pragma mark - 加载数据
// 加载测试数据
- (void)loadTestInfo {
    
    for (int i = 0; i < _myCarModelArray.count; i++) {
        NSDictionary *dic = _myCarModelArray[i];
        NSString *name = dic[@"modelname"];
        
        UIView *view = [self.carModelView viewWithTag:100 + i];
        if (view == nil) {
            continue;
        }
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if ([name isEqualToString:label.text]) {
                continue;
            }
        }
    }
    
    
    CGFloat addHeight = 0;
    if (_myCarModelArray.count == 0) {
    }
    else if (_myCarModelArray.count == 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
    }
    else if (_myCarModelArray.count > 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
        
        for (int i = 1; i < _myCarModelArray.count; i++) {
            dic = _myCarModelArray[i];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 39 * (i - 1), 150, 18)];
            label.font = [UIFont systemFontOfSize:18];
            label.text = dic[@"modelname"];
            label.tag = 100 + i;
            [self.keepLabelView addSubview:label];
            addHeight += 39;
        }
        _keepViewConstraint.constant = addHeight;
        _carModelViewHeight.constant = 85 + addHeight;
        _mainViewHeight.constant = 1485 + addHeight;
    }
}
#pragma mark - 加载数据
// 加载服务器数据
- (void)loadDataInfo {
    
    // 加载准教车型
    CGFloat addHeight = 0;
    if (_myCarModelArray.count == 1) {
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
    }
    if(_myCarModelArray.count > 1){
        NSDictionary *dic = _myCarModelArray[0];
        self.carModelField.text = dic[@"modelname"];
        dic = _myCarModelArray[_myCarModelArray.count - 1];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 39 * (_myCarModelArray.count - 2), 150, 18)];
        label.font = [UIFont systemFontOfSize:18];
        label.text = dic[@"modelname"];
        [self.keepLabelView addSubview:label];
        addHeight += 39 * (_myCarModelArray.count - 1);
    }
    _keepViewConstraint.constant = addHeight;
    _carModelViewHeight.constant = 85 + addHeight;
    _mainViewHeight.constant = 1485 + addHeight;
}
#pragma mark - PickerVIew
// 准教车型数据
- (void)initCarModelData {
    
    _carModelArray = [CommonUtil getObjectFromUD:@"modellist"];
    if (_carModelArray.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getModelList" object:nil];//重新获取
    }
}
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}
// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.carModelPicker]) {
        return 1;
    } else {
        return 0;
    }
}
// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.carModelPicker]) {
        if(self.teachCarTag == 0){
            if(_carModelArray.count == 0){
                return 0;
            }else{
                return _carModelArray.count;
            }
        }else if(self.teachCarTag == 1){
            return _TeachCarModeArray.count;
        }else{
            return _carSchoolArray.count;
        }
    }else {
        return 0;//如果不是就返回0
    }
}
// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    
    // 性别选择器
    if ([pickerView isEqual:self.carModelPicker]) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 45)];
        myView.textAlignment = NSTextAlignmentCenter;
        if(_teachCarTag == 0){
            NSDictionary *dic = [_carModelArray objectAtIndex:row];
            myView.text = dic[@"modelname"];
        }else if(_teachCarTag == 1){
            NSDictionary *dict = [_TeachCarModeArray objectAtIndex:row];
            myView.text = dict[@"modelname"];
        }else{
            NSDictionary *dict = [_carSchoolArray objectAtIndex:row];
            myView.text = dict[@"name"];
        }
        myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
        
        myView.textColor = MColor(161, 161, 161);
        
        myView.backgroundColor = [UIColor clearColor];
        if (selectRow == row){
            myView.textColor = MColor(34, 192, 100);
        }
    }
    
    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectRow = row;
    [pickerView reloadComponent:0];
}

#pragma mark - 页面特性
// 开始编辑，铅笔变蓝
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_blue"];
    
    if ([textField isEqual:self.idCardField]) {
        [self.idCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.coachCardField]) {
        [self.coachCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.driveCardField]) {
        [self.driveCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.carCheckField]) {
        [self.carCheckPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.teachCarField]) {
        [self.teachCarPencilImage setImage:image];
    }
}
// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_black"];
    
    if ([textField isEqual:self.idCardField]) {
        [self.idCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.coachCardField]) {
        [self.coachCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.driveCardField]) {
        [self.driveCardPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.carCheckField]) {
        [self.carCheckPencilImage setImage:image];
    }
    
    if ([textField isEqual:self.teachCarField]) {
        [self.teachCarPencilImage setImage:image];
    }
}

#pragma mark - 按钮方法
//弹出驾校选择框
- (IBAction)clickForSelectSchool:(id)sender {
//    if (self.userState.intValue == 1) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//    }else if (self.userState.intValue == 0){
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//    }else{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"联系方式" message:@"请填写" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        textField.placeholder = @"联系方式";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *login = alertController.textFields.firstObject;
        NSLog(@"firstObject%@", login.text);
        _schoolTextFiled.text = login.text;
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
    }];

    okAction.enabled = NO;
    // 3.将“取消”和“确定”按钮加入到弹框控制器中
    [alertController addAction:noAction];
    [alertController addAction:okAction];
    
    // 4.控制器 展示弹框控件，完成时不做操作
    [self presentViewController:alertController animated:YES completion:^{
        nil;
    }];
}
- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length == 11;
    }
}
//提交按钮
- (IBAction)clickForCommit:(id)sender {

    if (self.cityNameLabel.text.length == 0) {
        [self makeToast:@"城市不能为空"];
        return;
    }
    if (self.schoolTextFiled.text.length == 0) {
        [self makeToast:@"联系方式不能为空"];
        return;
    }
    if (self.coachCarLabel.text.length == 0) {
        [self makeToast:@"请选择车型"];
        return;
    }
    if (self.coachNameLabel.text.length == 0) {
        [self makeToast:@"教练名字不能为空"];
        return;
    }
    if (self.idCardPath.length == 0) {
        [self makeToast:@"请先提交身份证正面"];
        return;
    }
    if (self.idCardBackPath.length == 0) {
        [self makeToast:@"请提交身份证反面"];
        return;
    }
    if (self.carCheckPath.length == 0) {
        [self makeToast:@"请提交教练证"];
        return;
    }
    if (self.carCheckBackPaht.length == 0) {
        [self  mutableSetValueForKey:@"请提交车辆驾驶证"];
        return;
    }
    
    NSString *URL_Str = [NSString stringWithFormat:@"%@/coach/api/apply", kURL_SHY];
    NSMutableDictionary *URL_Dic = [NSMutableDictionary dictionary];
    URL_Dic[@"coachId"] = [UserDataSingleton mainSingleton].coachId;
    URL_Dic[@"carTypeName"] = @"C1";
    URL_Dic[@"carTypeId"] = @"1";
    URL_Dic[@"address"] = self.cityNameLabel.text;
    URL_Dic[@"phone"] = self.schoolTextFiled.text;
    URL_Dic[@"realName"] = self.coachNameLabel.text;
    URL_Dic[@"idCardFront"] = self.idCardPath;
    URL_Dic[@"idCardBack"] = self.idCardBackPath;
    URL_Dic[@"coachCertificate"] = self.carCheckPath;
    URL_Dic[@"driveCertificate"] = self.carCheckBackPaht;
    URL_Dic[@"schoolId"] = @"1";
    URL_Dic[@"longitude"] = @"113.54312";
    URL_Dic[@"latitude"] = @"114.65432";
    NSLog(@"URL_Dic%@", URL_Dic);
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    __weak CoachInfoViewController *VC = self;
    [session POST:URL_Str parameters:URL_Dic progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject%@", responseObject);
        
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            [VC makeToast:responseObject[@"msg"]];
            [UserDataSingleton mainSingleton].approvalState = @"1";
            [VC.navigationController popViewControllerAnimated:YES ];
        }else {
            [VC makeToast:responseObject[@"msg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error%@", error);
    }];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交后将会进入审核状态，在未通过审核前学员无法预约您的课程" delegate:VC cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView show];
    
   }
//C1或C2的选择
- (IBAction)clickForC1:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        if (self.C1Button.selected) {
            self.C1Button.selected = NO;
        }else{
            self.C1Button.selected = YES;
        }
    }
}

- (IBAction)clickForC2:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        if (self.C2Button.selected) {
            self.C2Button.selected = NO;
        }else{
            self.C2Button.selected = YES;
        }
    }
}
- (IBAction)clickForCarModel:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        CarModelViewController *nextViewController = [[CarModelViewController alloc] initWithNibName:@"CarModelViewController" bundle:nil];

        nextViewController.blockCar = ^(NSString *carState) {
            NSLog(@"carState%@", carState);
          _coachCarLabel.text = carState;
            
        };

        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}
// 监听弹话框点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"userInfo"];
        NSString *coachImage = [CommonUtil stringForID:userInfo[@"coach_cardpicurl"]]; // 教练证正面照片地址
        NSString *coachBackImage = [CommonUtil stringForID:userInfo[@"drive_cardpicurl"]]; // 驾驶证照片地址
        NSString *carCheckImage = [CommonUtil stringForID:userInfo[@"car_cardpicfurl"]]; // 车辆年检证照片地址&车辆行驶证正面
        NSString *carCheckBackImage = [CommonUtil stringForID:userInfo[@"car_cardpicburl"]]; // 车辆行驶证反面
        
        NSNumber *isNotEmpty = [NSNumber numberWithBool:YES];
        
        if ([CommonUtil isEmpty:coachImage] && self.coachCardDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:coachBackImage] && self.coachCarCardDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:carCheckImage] && self.carCheckDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if ([CommonUtil isEmpty:carCheckBackImage] && self.carCheckBackDelBtn.hidden) {
            isNotEmpty = [NSNumber numberWithBool:NO];
        }
        if (self.schoolTextFiled.text.length == 0 || [self.schoolTextFiled.text isEqualToString:@"请输入您的驾校名称"] || !isNotEmpty) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请正确填写完所有信息后再提交" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }else{
            NSString *cardNum = [self.idCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *cardNumPt = [self.cardMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *coachNum = [self.coachCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *coachNumPt = [self.coachMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *driveNum = [self.driveCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *driveNumPt = [self.driveMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *carCNum = [self.carCheckField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carCNumPt = [self.carCheckMadeTimeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *carModel = [self.teachCarCardField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carLicense = [self.teachCarField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            //驾校
            NSString *carSchoolName = [self.schoolTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
        }
        
    }
}
//名字编辑
- (IBAction)handleEditorName:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"真实姓名" message:@"请填写" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertNameFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        textField.placeholder = @"真实姓名";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *login = alertController.textFields.firstObject;
        NSLog(@"firstObject%@", login.text);
        _coachNameLabel.text = login.text;
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    okAction.enabled = NO;
    // 3.将“取消”和“确定”按钮加入到弹框控制器中
    [alertController addAction:noAction];
    [alertController addAction:okAction];
    
    // 4.控制器 展示弹框控件，完成时不做操作
    [self presentViewController:alertController animated:YES completion:^{
        nil;
    }];
    
}

- (void)alertNameFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *nameTF = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = nameTF.text.length >= 2;
    }
}
// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}
// 重新进行选择车型
- (IBAction)clickagainCarModelDone:(id)sender {
    //    [_myCarModelArray removeAllObjects];
    //    while (self.keepLabelView.subviews.count) {
    //        UIView* child = self.keepLabelView.subviews.lastObject;
    //        [child removeFromSuperview];
    //    }
    //    self.carModelField.text = @"";
    //    _keepViewConstraint.constant = 1;
    //    _carModelViewHeight.constant = 85;
    //    _mainViewHeight.constant = 1485;
    //    [self.selectView removeFromSuperview];
}
// 完成准教车型选择
- (IBAction)clickForCarModelDone:(id)sender {
    
    
    NSInteger row = [self.carModelPicker selectedRowInComponent:0];
    if(_teachCarTag == 0){
        if(_carModelArray == 0){
            [self makeToast:@"数据有误"];
            return;
        }
        NSDictionary *dic = _carModelArray[row];
        [_myCarModelArray removeAllObjects];
        [_myCarModelArray addObject:dic];
        [self loadDataInfo];
    }else if(_teachCarTag == 1){
        if(row == (_TeachCarModeArray.count - 1)){
            self.teachCarBtnOutlet.hidden = YES;
            _teachCarCardField.text = @"";
            _teachCarCardField.placeholder = @"请输入您的教学车型";
            _teachCarID = @"";
            [self.teachCarCardField becomeFirstResponder];
        }else{
            self.teachCarBtnOutlet.hidden = NO;
            _teachCarCardField.placeholder = @"";
            NSDictionary *dic = _TeachCarModeArray[row];
            _teachCarCardField.text = dic[@"modelname"];
            _teachCarID = dic[@"modelid"];
        }
    }else{
        if(row == (_carSchoolArray.count - 1)){
            self.selectSchoolButton.hidden = YES;
            _schoolTextFiled.text = @"";
            _schoolTextFiled.text = @"未设置";
            _carSchoolID = @"";
            [self.schoolTextFiled becomeFirstResponder];
        }else{
            self.selectSchoolButton.hidden = NO;
            _schoolTextFiled.text = @"";
            NSDictionary *dic = _carSchoolArray[row];
            _schoolTextFiled.text = dic[@"name"];
            _carSchoolID = dic[@"schoolid"];
        }
    }
    [self.selectView removeFromSuperview];
}

- (IBAction)backClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
// 拍证件照片
- (IBAction)clickForPhoto:(UIButton *)sender {
    // 身份证正面
    if (sender.tag == 102) {
        NSLog(@"身份证正面");
    }
    
    // 身份证反面
    if (sender.tag == 202) {
        NSLog(@"身份证反面");
    }
    
    // 教练证
    if (sender.tag == 302) {
        NSLog(@"教练证");
    }
    // 教练车行驶证
    if (sender.tag == 402) {
        NSLog(@"教练车行驶证");
    }
}
#pragma mark - 拍照
- (CZPhotoPickerController *)photoController {
    typeof(self) weakSelf = self;
    
    return [[CZPhotoPickerController alloc] initWithPresentingViewController:self withCompletionBlock:^(UIImagePickerController *imagePickerController, NSDictionary *imageInfoDict) {
        
        [weakSelf.pickPhotoController dismissAnimated:YES];
        weakSelf.pickPhotoController = nil;
        
        if (imagePickerController == nil || imageInfoDict == nil) {
            return;
        }
        
        UIImage *image = imageInfoDict[UIImagePickerControllerOriginalImage];
        if (image != nil) {
            [self uploadPictures:image];
            image = [CommonUtil fixOrientation:image];
        }
        
        if (self.clickImageView != nil) {
            self.clickImageView.image = image;
            self.clickImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.clickLabel.hidden = YES;
            self.clickDelBtn.hidden = NO;//显示删除按钮
        }
        [self.alertView removeFromSuperview];
    }];
}
#pragma mark - LocationViewControllerDelegate
- (void)location:(LocationViewController *)viewController selectDic:(NSDictionary *)selectDic{
    isChangeCity = @"1";
    
    self.selectProvince = selectDic[@"province"];
    self.selectCity = selectDic[@"city"];
    self.selectArea = selectDic[@"area"];
    
    self.selectProvinceid = self.selectProvince.provinceID;
    self.selectCityid = self.selectCity.cityID;
    self.selectAreaid = self.selectArea.areaID;

    NSString *addrStr = nil;
    NSString *areaStr = [self.selectArea.areaName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (self.selectProvince.isZxs) { // 直辖市
        addrStr = [NSString stringWithFormat:@"%@ - %@", self.selectProvince.provinceName, areaStr];
    } else {
        addrStr =  [NSString stringWithFormat:@"%@ - %@ - %@", self.selectProvince.provinceName, self.selectCity.cityName, areaStr];
    }

    self.cityNameLabel.text = addrStr;
}
//选择城市
- (IBAction)clickForSelectCity:(UIButton *)sender{
    
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        LocationViewController *viewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
        viewController.delegate = self;
        UIViewController* controller = self.view.window.rootViewController;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            viewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }else{
            controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
        
        [controller presentViewController:viewController animated:YES completion:^{
            viewController.view.superview.backgroundColor = [UIColor clearColor];
        }];
    }
    
}
#pragma mark - DatePickerViewControllerDelegate
- (void)datePicker:(DatePickerViewController *)viewController selectedDate:(NSDate *)selectedDate{
    NSString *time = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
    //self.cardMadeTimeField.text = time;
    //self.dateTimeTextField.text = time;
    if(self.dataTag == 0){
        self.cardMadeTimeField.text = time;
    }else if(self.dataTag == 1){
        self.coachMadeTimeField.text = time;
    }else if(self.dataTag == 2){
        self.driveMadeTimeField.text = time;
    }else{
        self.carCheckMadeTimeField.text = time;
    }
    
}
#pragma mark - 弹框方法
//弹框
- (IBAction)clickForAlert:(id)sender {
    if (self.userState.intValue == 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您所提交的资料已审核通过，不能修改。若要修改，请联系客服" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else if (self.userState.intValue == 1){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您提交的资料正在审核中，不能修改" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        UIButton *button = (UIButton *)sender;
        if (button.tag == 0){
            //身份证正面
            self.clickImageView = self.idCardImageView;
            self.clickLabel = self.idCardLabel;
            self.clickDelBtn = self.idCardDelBtn;
        }else if (button.tag == 1){
            //身份证反面
            self.clickImageView = self.idCardBackImageView;
            self.clickLabel = self.idCardBackLabel;
            self.clickDelBtn = self.idCardBackDelBtn;
        }else if (button.tag == 2){
            //教练证
            self.clickImageView = self.coachCardImageView;
            self.clickLabel = self.coachCardLabel;
            self.clickDelBtn = self.coachCardDelBtn;
        }else if (button.tag == 3){
            //教练驾驶证
            self.clickImageView = self.coachCarCardImageView;
            self.clickLabel = self.coachCarCardLabel;
            self.clickDelBtn = self.coachCarCardDelBtn;
        }else if (button.tag == 4){
            //车辆年检证&教练行驶证正面
            self.clickImageView = self.carCheckImageView;
            self.clickLabel = self.carCheckLabel;
            self.clickDelBtn = self.carCheckDelBtn;
        }else if (button.tag == 5){
            //教练行驶证反面
            self.clickImageView = self.carCheckBackImageView;
            self.clickLabel = self.carCheckBackLabel;
            self.clickDelBtn = self.carCheckBackDelBtn;
        }else if (button.tag == 6){
            //教练真实头像
            self.clickImageView = self.coachTureIconImageView;
            self.clickLabel = self.coachTureIconLabel;
            self.clickDelBtn = self.coachTureIconDelBtn;
        }else{
            self.clickImageView = nil;
        }
        
        self.alertView.frame = self.view.frame;
        [self.view addSubview:self.alertView];
    }
    
}
//移除弹窗
- (IBAction)clickForCloseAlert:(id)sender {
    [self.alertView removeFromSuperview];
}
// 上传图片
- (IBAction)clickForImage:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.allowsEditing = NO;
    if (button.tag == 0 && [CZPhotoPickerController canTakePhoto]) {
        //拍照
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        //相册
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}
//删除已经添加的照片
- (IBAction)clickForDelImage:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0){
        //身份证正面
        self.idCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.idCardLabel.hidden = NO;
        self.idCardDelBtn.hidden = YES;
    }else if (button.tag == 1){
        //身份证反面
        self.idCardBackImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.idCardBackLabel.hidden = NO;
        self.idCardBackDelBtn.hidden = YES;
        
    }else if (button.tag == 2){
        //教练证
        self.coachCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachCardLabel.hidden = NO;
        self.coachCardDelBtn.hidden = YES;
        
    }else if (button.tag == 3){
        //教练驾驶证
        self.coachCarCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachCarCardLabel.hidden = NO;
        self.coachCarCardDelBtn.hidden = YES;
        
    }else if (button.tag == 4){
        //车辆年检证&车辆行驶证正面
        self.carCheckImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.carCheckLabel.hidden = NO;
        self.carCheckDelBtn.hidden = YES;
        
    }else if (button.tag == 5){
        //车辆行驶证反面
        self.carCheckBackImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.carCheckBackLabel.hidden = NO;
        self.carCheckBackDelBtn.hidden = YES;
        
    }else if (button.tag == 6){
        //教练真实头像
        self.coachTureIconImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
        self.coachTureIconLabel.hidden = NO;
        self.coachTureIconDelBtn.hidden = YES;
        
    }else{
        self.clickImageView = nil;
    }
}

- (void)getCoachDetail {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    // 取出教练ID
    NSDictionary * ds = [CommonUtil getObjectFromUD:@"userInfo"];
    //NSString *coachId  = [ds objectForKey:@"coachid"];
    [paramDic setObject:@"123" forKey:@"coachid"];
    self.warmingLabel.text = @"【资格审核通过】您已经通过教练资格审核";
   // self.commitBtn.hidden = YES;

}
//如果没有登录那么就跳转登录界面
- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
/**
 *上传图片返回服务器存储路径
 */
-(void)uploadPictures:(UIImage *)image{
    
    NSString *URL_Str = [NSString stringWithFormat:@"%@/floor/api/fileUpload", kURL_SHY];
    //carownerapi/ save_carowner
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
    
    manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:20.0];
    
    //把版本号信息传导请求头中
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS-%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"MM-Version"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];
    __weak CoachInfoViewController *VC  = self;
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    
    [session POST:URL_Str parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSData *picData = UIImageJPEGRepresentation(image, 0.5);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.png", @"id_card_front"];
        [formData appendPartWithFileData:picData name:[NSString stringWithFormat:@"file"]
                                fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"responseObject%@", responseObject);
        NSString *resultStr = [NSString stringWithFormat:@"%@", responseObject[@"result"]];
        if ([resultStr isEqualToString:@"1"]) {
            NSInteger a = VC.clickImageView.tag;
            NSArray *dataArray = responseObject[@"data"];
            NSDictionary *dataDic =dataArray[0];
            NSString *image_URL = dataDic[@"URL"];
            switch (a) {
                case 201:
                    VC.idCardPath = image_URL;
                    break;
                case 202:
                    VC.idCardBackPath = image_URL;
                    break;
                case 203:
                    VC.carCheckPath = image_URL;
                    break;
                case 204:
                    VC.carCheckBackPaht = image_URL;
                    break;
                default:
                    break;
            }
        }else{
            [VC makeToast:@"上传失败请重试!"];
            NSInteger a = VC.clickImageView.tag;
            switch (a) {
                case 201:
                    VC.coachCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
                    break;
                case 202:
                    VC.coachCarCardImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
                    break;
                case 203:
                    VC.carCheckImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
                    break;
                case 204:
                    VC.carCheckBackImageView.image = [UIImage imageNamed:@"bg_myinfo_camera"];
                    break;
                    
                default:
                    break;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error%@", error);
        [VC  makeToast:@"网络错误请重试"];
    }];
    
}


@end
