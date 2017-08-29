//
//  CoinRecordListTableViewCell.h
//  guangda
//
//  Created by Ray on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoinRecordListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *coinType;
@property (strong, nonatomic) IBOutlet UILabel *coinForm;
@property (strong, nonatomic) IBOutlet UIButton *cheakBtn;
@property (strong, nonatomic) IBOutlet UILabel *coinTime;
@property (strong, nonatomic) IBOutlet UILabel *coinNum;

@end
