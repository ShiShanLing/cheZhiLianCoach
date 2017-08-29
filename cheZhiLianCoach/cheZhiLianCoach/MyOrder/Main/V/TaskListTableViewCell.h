//
//  TaskListTableViewCell.h
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"

@interface TaskListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//时间
@property (strong, nonatomic) IBOutlet UIView *studentDetailsView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;//单价
@property (strong, nonatomic) IBOutlet UIButton *jiantouImageView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;//背景图片
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@property (strong, nonatomic) IBOutlet DSButton *getCarClick;
@property (strong, nonatomic) IBOutlet UIView *finishView;

@property (strong, nonatomic) IBOutlet DSButton *complaintBtn;  // 投诉
@property (strong, nonatomic) IBOutlet DSButton *contactBtn;    // 联系

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;//名称
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (strong, nonatomic) IBOutlet UILabel *studentNumLabel;//学员号

//取消部分订单
@property (strong, nonatomic) IBOutlet UIView *cancelView;
@property (strong, nonatomic) IBOutlet DSButton *sureCancelBtn;
@property (strong, nonatomic) IBOutlet DSButton *noCancelBtn;
@property (strong, nonatomic) IBOutlet UILabel *cancelLabel;

@property (strong, nonatomic) IBOutlet UILabel *payerType; //支付类型
@property (strong, nonatomic) NSString *payerTypeStr;
@property (strong, nonatomic) IBOutlet UILabel *payerType2;

@property (strong, nonatomic) IBOutlet UIButton *accompanyDriveBtn;
@property (strong, nonatomic) IBOutlet UIButton *rentCarButton;

@property (strong, nonatomic) IBOutlet UIView *blackLine;
@end
