//
//  CustomTabBar.m
//  Portais
//
//  Created by Jianyong Duan on 15/3/10.
//  Copyright (c) 2015年 zjLocalPortais. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)itemClick:(UIControl *)sender {
    if (!self.selectedItem) {
        self.selectedItem = self.controlDy;
    }
    
    if (sender == self.selectedItem) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customTabBar:didSelectItem:)]) {
        [self.delegate customTabBar:self didSelectItem:sender];
    }
    
    [self deselectControl:self.selectedItem];
    [self selectControl:sender];
}

- (void)deselectControl:(UIControl *)control {
    UIImageView *imageView = (UIImageView *)[control viewWithTag:101];
    UILabel *label = (UILabel *)[control viewWithTag:102];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar_icon_%ld", (long)control.tag]];
    label.textColor = [UIColor whiteColor];
    control.backgroundColor = [UIColor blackColor];
}

- (void)selectControl:(UIControl *)control {
    UIImageView *imageView = (UIImageView *)[control viewWithTag:101];
    UILabel *label = (UILabel *)[control viewWithTag:102];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar_icon_%ld_h", (long)control.tag]];
    label.textColor = [UIColor blackColor];
    control.backgroundColor = [UIColor whiteColor];
    
    self.selectedItem = control;
}

@end
