//
//  MyMessageCell.h
//  guangda
//
//  Created by duanjycc on 15/3/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessageCell : UITableViewCell

- (void)loadData:(NSArray *)arrayData;
@property (copy, nonatomic) NSString *messageContent;
@property (copy, nonatomic) NSString *messageDate;
@property (copy, nonatomic) UIImage *bgImage;
@property (assign, nonatomic) CGFloat messageHeight;
@property (strong, nonatomic) IBOutlet UIButton *officialBtn;
@end
