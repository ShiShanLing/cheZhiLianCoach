//
//  MyTicketDetailTableViewCell.h
//  guangda
//
//  Created by Ray on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTicketDetailTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *backView1;
@property (strong, nonatomic) IBOutlet UILabel *ticketName1;
@property (strong, nonatomic) IBOutlet UILabel *ticketFrom1;
@property (strong, nonatomic) IBOutlet UILabel *ticketTime1;
@property (strong, nonatomic) IBOutlet UILabel *selectTag1;
@property (strong, nonatomic) IBOutlet DSButton *clickButton1;
@property (strong, nonatomic) IBOutlet UILabel *applyLabel1;

@property (strong, nonatomic) IBOutlet UIView *backView2;
@property (strong, nonatomic) IBOutlet UILabel *ticketName2;
@property (strong, nonatomic) IBOutlet UILabel *ticketFrom2;
@property (strong, nonatomic) IBOutlet UILabel *ticketTime2;
@property (strong, nonatomic) IBOutlet UILabel *selectTag2;
@property (strong, nonatomic) IBOutlet DSButton *clickButton2;
@property (strong, nonatomic) IBOutlet UILabel *applyLabel2;


@end
