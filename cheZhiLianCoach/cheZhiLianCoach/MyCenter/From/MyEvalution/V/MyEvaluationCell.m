//
//  MyEvaluationCell.m
//  guangda
//
//  Created by duanjycc on 15/3/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyEvaluationCell.h"


@interface MyEvaluationCell(){
     TQStarRatingView *ratingView;
}
@property (strong, nonatomic) IBOutlet UILabel *evaluationContentLabel;   // 评价内容
//@property (strong, nonatomic) IBOutlet UIImageView *studentIocnImageView; // 学员头像
@property (strong, nonatomic) IBOutlet UILabel *studentNameLabel;         // 学员名字
@property (strong, nonatomic) IBOutlet UILabel *evaluationTime;           // 任务时间
@property (strong, nonatomic) IBOutlet UIView *startView;                // 显示星星

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *evaluationContentHeight;
@end

@implementation MyEvaluationCell

- (void)awakeFromNib {
    // Initialization code
    ratingView = [[TQStarRatingView alloc] initWithFrame:self.startView.bounds numberOfStar:5];
    ratingView.couldClick = NO;//不可点击
    [ratingView changeStarForegroundViewWithPoint:CGPointMake(0/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    [self.startView addSubview:ratingView];
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

    [ratingView changeStarForegroundViewWithPoint:CGPointMake(self.score/5*CGRectGetWidth(self.startView.frame), 0)];//设置星级
    //[self.startView addSubview:ratingView];
    self.studentNameLabel.text = self.studentName;    // 设置学员名字
    if([CommonUtil isEmpty:self.studentIcon])         // 设置学员头像
    {
        self.studentIcon = @"";
    }
    [self.studentIocnImageView sd_setImageWithURL:[NSURL URLWithString:self.studentIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.studentIocnImageView.layer.cornerRadius = self.studentIocnImageView.bounds.size.width/2;
            self.studentIocnImageView.layer.masksToBounds = YES;
//            [self updateLogoImage:self.studentIocnImageView];//裁切头像
        }
    }];
    
    [self.coachIocnImageView sd_setImageWithURL:[NSURL URLWithString:self.coachIcon] placeholderImage:[UIImage imageNamed:@"icon_portrait_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.coachIocnImageView.layer.cornerRadius = self.coachIocnImageView.bounds.size.width/2;
            self.coachIocnImageView.layer.masksToBounds = YES;
            //            [self updateLogoImage:self.studentIocnImageView];//裁切头像
        }
    }];
    
    self.evaluationTime.text = self.evaluationData;
    NSString *evaluationContent = self.evaluationContent;
    CGSize textSize;
    if([CommonUtil isEmpty:self.evaluationContent]){
        textSize.height = 0;
    }else{
        textSize = [self sizeWithString:evaluationContent fontSize:17 sizewidth:(kScreen_widht - 77) sizeheight:0];
    }
    self.evaluationContentLabel.text = evaluationContent;
    self.evaluationContentHeight.constant = textSize.height;
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
