//
//  CustomTabBar.h
//  Portais
//
//  Created by Jianyong Duan on 15/3/10.
//  Copyright (c) 2015年 zjLocalPortais. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomTabBarDelegate;

@interface CustomTabBar : UIView

@property(nonatomic,assign) id<CustomTabBarDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIControl *controlDy;
@property(nonatomic,assign) UIControl   *selectedItem;
@property (strong, nonatomic) IBOutlet UIControl *controlMy;

//action
- (IBAction)itemClick:(UIControl *)sender;

@end

@protocol CustomTabBarDelegate<NSObject>
@optional

- (void)customTabBar:(CustomTabBar *)tabBar didSelectItem:(UIControl *)item;


@end