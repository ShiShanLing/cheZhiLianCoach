//
//  LocationViewController.m
//  guangda
//
//  Created by 吴筠秋 on 15/4/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreText/CoreText.h>

@interface LocationViewController ()

@property (strong, nonatomic) NSArray *provinces;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    if (self.selectDic == nil) {
        self.selectDic = [NSMutableDictionary dictionary];
    }
    [self initData];
}

- (void)initData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"china.plist" ofType:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dict[@"china"];
    self.provinces = [XBProvince provincesWithArray:array];
    
    self.selectProvince = self.provinces[0];
    self.selectCity = self.selectProvince.citiesArray[0];
    self.selectArea = self.selectCity.areasArray[0];
}

- (IBAction)buttonOKClick:(id)sender {
    
    [self.selectDic setObject:self.selectProvince forKey:@"province"];
    [self.selectDic setObject:self.selectCity forKey:@"city"];
    [self.selectDic setObject:self.selectArea forKey:@"area"];
  
    if (_delegate && [_delegate respondsToSelector:@selector(location:selectDic:)]) {
        [_delegate location:self selectDic:self.selectDic];
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)clickForCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 省
    if (component == 0) {
        return self.provinces.count;
    }
    // 市
    else if (component == 1) {
        return self.selectProvince.citiesArray.count;
    }
    // 区
    else {
        return self.selectCity.areasArray.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return CGRectGetWidth([UIScreen mainScreen].bounds) / 3;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds)/ 3;
    // 省
    if (component == 0) {
        XBProvince *province = self.provinces[row];
        NSString *provinceName = province.provinceName;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = provinceName;
        
        label.textColor = MColor(200, 200, 200);
        [view addSubview:label];
        return view;
        
    }
    // 市
    else if (component == 1) {
        XBCity *city = self.selectProvince.citiesArray[row];
        NSString *cityName = city.cityName;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = cityName;
        
        label.textColor = MColor(200, 200, 200);
        [view addSubview:label];
        return view;
        
    }
    // 区
    else {
        XBArea *area = self.selectCity.areasArray[row];
        NSString *areaName = area.areaName;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = areaName;
        
        label.textColor = MColor(200, 200, 200);

        
        [view addSubview:label];
        return view;
        
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // 省
    if (component == 0) {
        self.selectProvince = self.provinces[row];
        self.selectCity = self.selectProvince.citiesArray[0];
        self.selectArea = self.selectCity.areasArray[0];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }
    // 市
    else if (component == 1) {
        self.selectCity = self.selectProvince.citiesArray[row];
        self.selectArea = self.selectCity.areasArray[0];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    // 区
    else {
        self.selectArea = self.selectCity.areasArray[row];
    }
}

@end
