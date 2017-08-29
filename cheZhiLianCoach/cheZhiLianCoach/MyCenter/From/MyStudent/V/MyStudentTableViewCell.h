//
//  TaskListTableViewCell.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"

@interface MyStudentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//时间
@property (strong, nonatomic) IBOutlet UIView *studentDetailsView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;//单价
@property (strong, nonatomic) IBOutlet UIImageView *jiantouImageView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;//背景图片
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconRight;
@property (strong, nonatomic) IBOutlet DSButton *getCarClick;
@property (strong, nonatomic) IBOutlet UIView *finishView;

@property (strong, nonatomic) IBOutlet DSButton *complaintBtn;  // 投诉
@property (strong, nonatomic) IBOutlet DSButton *contactBtn;    // 联系

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;//名称
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (strong, nonatomic) IBOutlet UILabel *studentNumLabel;//学员号




@end
