//
//  MyEvaluationCell.h
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQStarRatingView.h"

@interface MyEvaluationCell : UITableViewCell

@property (copy, nonatomic) NSString *evaluationContent; // 评价内容
@property (copy, nonatomic) NSString *evaluationData;    // 任务时间
@property (copy, nonatomic) NSString *studentName;       // 学员名字
@property (copy, nonatomic) NSString *studentIcon;       // 学员头像
@property (copy, nonatomic) NSString *coachIcon;       // 学员头像
@property (assign, nonatomic) float score;               // 评分

@property (strong, nonatomic) IBOutlet UIImageView *coachIocnImageView;
@property (strong, nonatomic) IBOutlet UIImageView *studentIocnImageView; // 学员头像

@property (strong, nonatomic) IBOutlet UIButton *studentInfoBtn;
- (void)loadData:(NSArray *)arrayData;

@end
