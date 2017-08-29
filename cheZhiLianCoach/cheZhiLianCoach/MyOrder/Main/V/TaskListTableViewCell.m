//
//  TaskListTableViewCell.m
//  guangda
//
//  Created by Dino on 15/3/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "TaskListTableViewCell.h"

@implementation TaskListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.sureCancelBtn.layer.cornerRadius = 3;
    self.sureCancelBtn.layer.masksToBounds = YES;
    
    self.noCancelBtn.layer.cornerRadius = 3;
    self.noCancelBtn.layer.masksToBounds = YES;
    
    self.payerType.layer.cornerRadius = 2;
    self.payerType.layer.masksToBounds = YES;
    self.payerType.layer.borderColor = MColor(210, 210, 210).CGColor;
    self.payerType.layer.borderWidth = 0.5;
    
    self.payerType2.layer.cornerRadius = 2;
    self.payerType2.layer.masksToBounds = YES;
    self.payerType2.layer.borderColor = MColor(210, 210, 210).CGColor;
    self.payerType2.layer.borderWidth = 0.5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
