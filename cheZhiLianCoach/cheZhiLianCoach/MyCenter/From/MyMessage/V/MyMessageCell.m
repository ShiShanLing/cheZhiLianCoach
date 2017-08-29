//
//  MyMessageCell.m
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyMessageCell.h"

@interface MyMessageCell()
@property (strong, nonatomic) IBOutlet UIImageView *textBgImageView;
@property (strong, nonatomic) IBOutlet UILabel *messageContentLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@end

@implementation MyMessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(NSArray *)arrayData {
    self.textLabelHeight.constant = self.messageHeight;
    self.messageContentLabel.text = self.messageContent;
    self.dateLabel.text = self.messageDate;
    self.textViewHeight.constant = 26 + self.messageHeight;
    //UIImage *bgImage = [[UIImage imageNamed:@"bg_message_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(56, 100, 56, 100)];
    UIImage *bgImage = [[UIImage imageNamed:@"bg_message_bubblexiao"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 40, 28, 40)];
    //UIImage *bgImage = [UIImage imageNamed:@"bg_message_bubble"];
    [self.textBgImageView setImage:bgImage];
}

@end
