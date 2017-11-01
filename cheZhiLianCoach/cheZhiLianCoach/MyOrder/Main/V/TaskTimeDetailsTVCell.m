//
//  TaskTimeDetailsTVCell.m
//  cheZhiLianCoach
//
//  Created by 石山岭 on 2017/10/30.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "TaskTimeDetailsTVCell.h"

@interface TaskTimeDetailsTVCell ( )
/**
 开始-结束时间
 */
@property (weak, nonatomic) IBOutlet UILabel *stareEndTimeLable;

/**
 教练名字
 */
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;
/**
 学车地址
 */
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
/**
 价钱
 */
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation TaskTimeDetailsTVCell
- (void)layoutSubviews {

    
    self.timeEditorBtn.layer.cornerRadius = 3;
    self.timeEditorBtn.layer.masksToBounds = YES;
    self.RefusedBtn.layer.cornerRadius = 5;
    self.RefusedBtn.layer.masksToBounds =  YES;
    self.AgreedBtn.layer.cornerRadius = 5;
    self.AgreedBtn.layer.masksToBounds = YES;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
/**
 确认上下车
 @param sender 点击的按钮
 */
- (IBAction)handleTimeEditor:(DSButton *)sender {
    if ([_delegate respondsToSelector:@selector(TimeStateEditor:)]) {
        [_delegate TimeStateEditor:sender];
    }
}
/**
 拒绝取消订单

 @param sender 点击的按钮
 */
- (IBAction)handleRefusedCancelOrder:(DSButton *)sender {
    sender.tag = 0;
    if ([_delegate respondsToSelector:@selector(AgreeOrRefuseCancelOrder:)]) {
        [_delegate AgreeOrRefuseCancelOrder:sender];
    }
}

/**
 同意取消订单

 @param sender 点击的按钮
 */
- (IBAction)handleAgreeCancelOrder:(DSButton *)sender {
    sender.tag = 1;
    if ([_delegate respondsToSelector:@selector(AgreeOrRefuseCancelOrder:)]) {
        [_delegate AgreeOrRefuseCancelOrder:sender];
    }
}
-(void)setModel:(OrderTimeModel *)model {
    
    NSString *startTime = [CommonUtil InDataForString:model.startTime];//开始时间
    NSString *endTime = [CommonUtil InDataForString:model.endTime];//结束时间
    NSString *address = @"安徽省临泉县关庙镇!";//地址
    NSString *total = [NSString stringWithFormat:@"%d", model.price] ; //订单总价
    int state = model.trainState;
    if (state == 0) {
      self.stareEndTimeLable.textColor = MColor(28, 28, 28);
    }else if(state == 1){
      self.stareEndTimeLable.textColor = MColor(246, 102, 93);
    }else {
        self.stareEndTimeLable.textColor  = MColor(144, 144, 144);
    }
    //任务时间
    NSString *time = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    self.stareEndTimeLable.font = MFont(kFit(12));
    self.stareEndTimeLable.text = time;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",total];
    //地址
    self.addressLabel.text = address;
    NSString *nameStr = [NSString stringWithFormat:@"教练: %@ %@", model.coachName ,model.subType==0?@"科目二":@"科目三"];
    self.coachNameLabel.text = nameStr;
    
}
- (void)setIndexPath:(NSIndexPath *)indexPath {
    
    self.AgreedBtn.indexPath = indexPath;
    self.RefusedBtn.indexPath = indexPath;
    self.timeEditorBtn.indexPath  = indexPath;
    
}
@end
