//
//  LoginViewController.h
//  guangda
//
//  Created by Dino on 15/3/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "JKCountDownButton.h"
/**
 *登录界面
 */
@interface LoginViewController : GreyTopViewController   //登陆类

@property (strong, nonatomic) IBOutlet JKCountDownButton *vcodeButton;

- (IBAction)clickForGetVcode:(id)sender;

@property (strong, nonatomic) NSString *errMessage;

@end
