//
//  HistoryTableViewCell.m
//  guangda
//
//  Created by Dino on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "HistoryTableViewCell.h"


@implementation HistoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.myStarRatingView = [[TQStarRatingView alloc] initWithFrame:self.myStarView.bounds numberOfStar:5];
    self.myStarRatingView.couldClick = NO;
    [self.myStarView addSubview:self.myStarRatingView];
    
    self.studentStarRatingView = [[TQStarRatingView alloc] initWithFrame:self.studentStarView.bounds numberOfStar:5];
    self.studentStarRatingView.couldClick = NO;
    [self.studentStarView addSubview:self.studentStarRatingView];
    
    [self.nameButton setBackgroundColor:[UIColor clearColor]];
    //
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
