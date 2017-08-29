//
//  ComplainMeCell.h
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComplainMeCell : UITableViewCell

@property (assign, nonatomic) int hasDealedWith; // 是否已处理 0:未处理 1:已处理
- (void)loadData:(NSArray *)arrayData;
@property (copy, nonatomic) NSString *complainContent;    // 投诉内容
@property (assign, nonatomic) NSInteger complainBecauseLenght;  // 投诉原因长度
@property (copy, nonatomic) NSString *complainData;       // 任务时间
@property (copy, nonatomic) NSString *studentIcon;        // 学员头像
@property (assign, nonatomic) int clheight; // 投诉内容到下划线的距离
@property (assign, nonatomic) NSInteger type2;

@property (strong, nonatomic) NSMutableArray *contentHgtArr; // 内容高度数组
@property (strong, nonatomic) IBOutlet UIButton *studentInfoBtn;
@property (strong, nonatomic) IBOutlet UIView *depositView; // 存放label
@property (strong, nonatomic) IBOutlet UIImageView *studentIconImageView; // 学员头像

@end
