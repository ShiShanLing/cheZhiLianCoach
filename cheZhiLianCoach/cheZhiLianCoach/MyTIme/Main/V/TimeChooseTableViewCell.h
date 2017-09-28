//
//  TimeChooseTableViewCell.h
//  timeChoose
//
//  Created by 石山岭 on 2017/8/3.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeChooseTableViewCellDelegate <NSObject>

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)swipe;

- (void)ClickIndex:(NSIndexPath *)indexPath;

@end


@interface TimeChooseTableViewCell : UITableViewCell
/**
 * 上午下午晚上
 */
@property (nonatomic, strong)UILabel *PeriodTimeLabel;

/**
 *可变数组
 */
@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, weak)id<TimeChooseTableViewCellDelegate>delegate;

/**
 *
 */
@property (nonatomic, assign)NSInteger cellSection;

@end
