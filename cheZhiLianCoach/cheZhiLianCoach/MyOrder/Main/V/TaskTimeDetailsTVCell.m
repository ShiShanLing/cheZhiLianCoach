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
 时间状态编辑
 */
@property (weak, nonatomic) IBOutlet UIButton *timeEditBtn;
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
/**
 同意取消订单
 */
@property (weak, nonatomic) IBOutlet UIButton *AgreedBtn;
/**
 拒绝取消订单
 */
@property (weak, nonatomic) IBOutlet UIButton *RefusedBtn;
/**
 确认上下车
 */
@property (weak, nonatomic) IBOutlet UIButton *timeEditorBtn;



@end

@implementation TaskTimeDetailsTVCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timeEditorBtn.layer.cornerRadius = 3;
        self.timeEditBtn.layer.masksToBounds = YES;
        self.RefusedBtn.layer.cornerRadius = 5;
        self.RefusedBtn.layer.masksToBounds =  YES;
        self.AgreedBtn.layer.cornerRadius = 5;
        self.AgreedBtn.layer.masksToBounds = YES;
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
- (IBAction)handleTimeEditor:(UIButton *)sender {
}

/**
 拒绝取消订单

 @param sender 点击的按钮
 */
- (IBAction)handleRefusedCancelOrder:(UIButton *)sender {
}

/**
 同意取消订单

 @param sender 点击的按钮
 */
- (IBAction)handleAgreeCancelOrder:(UIButton *)sender {
    
}
-(void)setModel:(OrderTimeModel *)model {
    
    NSString *startTime = [CommonUtil InDataForString:model.startTime];//开始时间
    NSString *endTime = [CommonUtil InDataForString:model.endTime];//结束时间
    NSString *address = @"安徽省临泉县关庙镇!";//地址
    NSString *total = [NSString stringWithFormat:@"%d", model.price] ; //订单总价
    int state = model.trainState;
    if (state != 0) {
        self.stareEndTimeLable.textColor = MColor(246, 102, 93);
    }else{
        self.stareEndTimeLable.textColor = MColor(28, 28, 28);
    }
    //任务时间
    NSString *time = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    self.stareEndTimeLable.font = MFont(kFit(12));
    self.stareEndTimeLable.text = time;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",total];
    //地址
    self.addressLabel.text = address;
    self.coachNameLabel.text = model.coachName;
    
}
@end
