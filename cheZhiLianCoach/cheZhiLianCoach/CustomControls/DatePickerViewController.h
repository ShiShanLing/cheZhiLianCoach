//
//  DatePickerViewController.h
//  wedding
//
//  Created by Jianyong Duan on 14/11/24.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewControllerDelegate;

@interface DatePickerViewController : UIViewController

@property (weak, nonatomic) id<DatePickerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonOK;
@property (assign, nonatomic) NSInteger dicTag;

@property (assign, nonatomic) NSString *pushString;

- (IBAction)buttonOKClick:(id)sender;
- (IBAction)clickForCancel:(id)sender;


//参数
@property (nonatomic, strong) NSDate *selectDate;

@end

@protocol DatePickerViewControllerDelegate <NSObject>

@optional

- (void)datePicker:(DatePickerViewController *)viewController selectedDate:(NSDate *)selectedDate;

@end
