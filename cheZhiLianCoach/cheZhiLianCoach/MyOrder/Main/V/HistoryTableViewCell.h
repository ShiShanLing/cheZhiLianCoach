//
//  HistoryTableViewCell.h
//  guangda
//
//  Created by Dino on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"
#import "TQStarRatingView.h"

@interface HistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) IBOutlet UIView *studentDetailsView;

@property (strong, nonatomic) IBOutlet UIImageView *jiantouImageView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;//头像
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconRight;
@property (strong, nonatomic) IBOutlet UIControl *myCommentDetailsBtn;      // 我的评价详情click
@property (strong, nonatomic) IBOutlet UIControl *studentCommentDetailsBtn; // 学员评价详情click
@property (strong, nonatomic) IBOutlet DSButton *goCommentClick;

@property (strong, nonatomic) IBOutlet DSButton *complaintBtn;  // 投诉
@property (strong, nonatomic) IBOutlet DSButton *contactBtn;    // 联系

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//时间

@property (strong, nonatomic) IBOutlet UIButton *nameButton;

@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;  //电话字段
@property (strong, nonatomic) IBOutlet UILabel *studentNumLabel; //学员姓名字段

//星星view
@property (strong, nonatomic) IBOutlet UIView *myStarView;//我的评价
@property (strong, nonatomic) IBOutlet UIView *studentStarView;//学员的评价
@property (strong, nonatomic) TQStarRatingView *myStarRatingView;//我的星星view
@property (strong, nonatomic) TQStarRatingView *studentStarRatingView;//学员的星星view

//学员评价view
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *studentScoreHeightConstraint;//学员view的高度
@property (strong, nonatomic) IBOutlet UILabel *studentContentLabel;
@property (strong, nonatomic) IBOutlet UILabel *studentTitleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *payerType; //支付类型

@property (strong, nonatomic) IBOutlet UILabel *cancelLabel;

@property (strong, nonatomic) IBOutlet UIButton *accompanyDriveBtn;

@property (strong, nonatomic) IBOutlet UILabel *rentLabel;  //租用金字段
@end
