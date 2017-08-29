//
//  LocationViewController.h
//  guangda
//
//  Created by 吴筠秋 on 15/4/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "BaseViewController.h"

@protocol LocationViewControllerDelegate;

@interface LocationViewController : BaseViewController

@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonOK;

- (IBAction)buttonOKClick:(id)sender;
- (IBAction)clickForCancel:(id)sender;


//参数
//@property (nonatomic, strong) NSString *selectCity;
//@property (nonatomic, strong) NSString *selectPro;
@property (strong, nonatomic) NSMutableDictionary *selectDic;

@property (strong, nonatomic) XBProvince *selectProvince;
@property (strong, nonatomic) XBCity *selectCity;
@property (strong, nonatomic) XBArea *selectArea;

@end

@protocol LocationViewControllerDelegate <NSObject>

@optional

- (void)location:(LocationViewController *)viewController selectDic:(NSDictionary *)selectDic;

@end
