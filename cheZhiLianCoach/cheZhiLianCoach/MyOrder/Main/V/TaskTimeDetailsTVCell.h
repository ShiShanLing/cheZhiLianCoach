//
//  TaskTimeDetailsTVCell.h
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskTimeDetailsTVCellDeleagte <NSObject>

/**
 *确认上下车
 *@param sender DSButton
 */
- (void)TimeStateEditor:(DSButton *)sender ;
/**
  *同意或者拒绝取消订单   tag值 拒绝 0 同意 1
  *@param sender <#sender description#>
 */
- (void)AgreeOrRefuseCancelOrder:(DSButton *)sender;

@end


@interface TaskTimeDetailsTVCell : UITableViewCell

@property (nonatomic, strong)OrderTimeModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, weak)id<TaskTimeDetailsTVCellDeleagte>delegate;

@property (nonatomic, strong)NSIndexPath *indexPath;
/**
 确认上下车
 */
@property (weak, nonatomic) IBOutlet DSButton *timeEditorBtn;
/**
 同意取消订单
 */
@property (weak, nonatomic) IBOutlet DSButton *AgreedBtn;
/**
 拒绝取消订单
 */
@property (weak, nonatomic) IBOutlet DSButton *RefusedBtn;
@end
