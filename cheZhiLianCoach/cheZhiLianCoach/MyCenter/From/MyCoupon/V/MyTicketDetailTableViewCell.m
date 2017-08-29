//
//  MyTicketDetailTableViewCell.m
//  guangda
//
//  Created by Ray on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyTicketDetailTableViewCell.h"

@implementation MyTicketDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backView1.layer.borderWidth = 1;
    self.backView1.layer.borderColor = MColor(201, 201, 201).CGColor;
    self.backView2.layer.borderWidth = 1;
    self.backView2.layer.borderColor = MColor(201, 201, 201).CGColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
