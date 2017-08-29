//
//  CoinRecordListTableViewCell.m
//  guangda
//
//  Created by Ray on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinRecordListTableViewCell.h"

@implementation CoinRecordListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.cheakBtn.layer.cornerRadius = 3;
    self.cheakBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
