//
//  timeStateCVCell.h
//  timeChoose
//
//  Created by 石山岭 on 2017/8/3.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface timeStateCVCell : UICollectionViewCell

/**
 *
 */
@property (nonatomic, strong) UIImageView *backgroundImage;
/**
 *
 */
@property (nonatomic, strong) UILabel *SubjectName;
/**
 *
 */
@property (nonatomic, strong) UILabel *timeLabel;
/**
 *
 */
@property (nonatomic, strong) UILabel *priceLabel;

- (void)ModifyState:(CoachTimeListModel *)model indexPath:(NSIndexPath *)indexPath section:(NSInteger)section;

@end
