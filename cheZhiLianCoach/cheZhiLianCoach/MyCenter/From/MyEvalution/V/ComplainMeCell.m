//
//  ComplainMeCell.m
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ComplainMeCell.h"

@interface ComplainMeCell()
@property (strong, nonatomic) IBOutlet UIImageView *dealedImageView;    // 已处理图标
@property (strong, nonatomic) IBOutlet UILabel *complainContentLabel;   // 投诉内容
@property (strong, nonatomic) IBOutlet UILabel *taskTimeLabel;          // 任务时间
@property (strong, nonatomic) IBOutlet UILabel *handleLable;            // 处理状态


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *complainContentHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *portraitY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *studentInfoBtnY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentAndLine; //内容到线的距离


@end

@implementation ComplainMeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 对头像裁剪成六边形
- (void)updateLogoImage:(UIImageView *)imageView{
    if (imageView == nil) {
        return;
    }
    imageView.image = [CommonUtil maskImage:imageView.image withMask:[UIImage imageNamed:@"shape.png"]];
}


- (void)loadData:(NSArray *)arrayData {
    self.taskTimeLabel.text = self.complainData;      // 设置任务时间
    NSString *complainContent = self.complainContent; // 设置投诉内容
    self.contentAndLine.constant = self.clheight + 15;
    if([CommonUtil isEmpty:self.studentIcon])         // 设置学员头像
    {
        self.studentIcon = @"";
    }
//    [self.studentIconImageView sd_setImageWithURL:[NSURL URLWithString:self.studentIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if(image != nil){
            self.studentIconImageView.image = [UIImage imageNamed:@"icon_portrait_default"];
            self.studentIconImageView.layer.cornerRadius = self.studentIconImageView.bounds.size.width/2;
            self.studentIconImageView.layer.masksToBounds = YES;
//            [self updateLogoImage:self.studentIconImageView];//裁切头像
//        }
//    }];
    
    //延时调用是为了等图片显示出来之后再进行裁剪
    //[self performSelector:@selector(updateLogoImage:) withObject:self.studentIconImageView afterDelay:0];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:complainContent];
    [str addAttribute:NSForegroundColorAttributeName value:MColor(33, 180, 120) range:NSMakeRange(0,self.complainBecauseLenght)];
    self.complainContentLabel.attributedText = str;
    CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
    self.complainContentHeight.constant = textSize.height;
    
    // 已处理
    if (self.hasDealedWith == 1) {
        self.handleLable.hidden = YES;
        self.dealedImageView.hidden = NO;
        self.portraitY.constant = 46;
        self.studentInfoBtnY.constant = 46;
        self.complainContentLabel.textColor = MColor(210, 210, 210);
        self.taskTimeLabel.textColor = MColor(210, 210, 210);
    }else{
        self.handleLable.hidden = NO;
        self.complainContentLabel.textColor = MColor(37, 37, 37);
        [str addAttribute:NSForegroundColorAttributeName value:MColor(33, 180, 120) range:NSMakeRange(0,self.complainBecauseLenght)];
        self.complainContentLabel.attributedText = str;
        CGSize textSize = [self sizeWithString:complainContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
        self.complainContentHeight.constant = textSize.height;
        self.dealedImageView.hidden = YES;
        self.portraitY.constant = 17;
        self.studentInfoBtnY.constant = 17;
        self.taskTimeLabel.textColor = MColor(37, 37, 37);
    }
    if(self.type2 == 1 || self.type2 == 2 ){
        self.complainContentLabel.textColor = MColor(210, 210, 210);
    }
}

// 根据文字，字号及固定宽(固定高)来计算高(宽)
- (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height
{
    
    // 用何种字体显示
    UIFont *font = [UIFont systemFontOfSize:fontsize];
    
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment=NSTextAlignmentLeft;
        
        NSAttributedString *attributeText=[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
        CGSize labelsize = [attributeText boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        expectedLabelSize = CGSizeMake(ceilf(labelsize.width),ceilf(labelsize.height));
    } else {
        expectedLabelSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:NSLineBreakByCharWrapping];
    }
    
    // 计算出显示完内容的最小尺寸
    
    return expectedLabelSize;
}

@end
