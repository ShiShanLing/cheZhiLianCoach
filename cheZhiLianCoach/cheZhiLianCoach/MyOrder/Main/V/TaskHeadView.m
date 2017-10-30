//
//  TaskHeadView.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/27.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "TaskHeadView.h"

@interface TaskHeadView ()
/**
 背景
 */
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
/**
 用户头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
/**
 用户名字
 */
@property (weak, nonatomic) IBOutlet UILabel *usetNameLabel;
/**
 时间
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/**
 学员名字
 */
@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;
/**
 学员电话
 */
@property (weak, nonatomic) IBOutlet UILabel *studentPhoneLabel;
/**
 学员证号
 */
@property (weak, nonatomic) IBOutlet UILabel *studentCardNumLabel;


@end
//首先 需要手动切割一下 背景色的圆角 然后需要调整 上间距
@implementation TaskHeadView
//打短信
- (IBAction)handleTexting:(DSButton *)sender {
    
    
}
//打电话
- (IBAction)handleMakePhone:(DSButton *)sender {
    
}


@end
