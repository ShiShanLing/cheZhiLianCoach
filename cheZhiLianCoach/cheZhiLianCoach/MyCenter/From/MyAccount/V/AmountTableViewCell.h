//
//  AmountTableViewCell.h
//  guangda
//
//  Created by 吴筠秋 on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmountTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;

@property (strong, nonatomic) IBOutlet UILabel *desLabel;//描述
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *desHeightConstraint;
@property (strong, nonatomic) NSString *width;


/** 赋值
 * @param type      类型 "1.学员支付 2.提现 3.充值"
 * @param time      时间
 * @param amount    价格
 */
- (void)setType:(NSString *)type time:(NSString *)time amount:(NSString *)amount;

/**
 * 给描述赋值
 */
- (void)setDesDic:(NSDictionary *)dic;
@end
