//
//  UIScrollView+DPEmptyDataSet.h
//  DPEmptyDataRefresh
//
//  Created by 人众 on 2017/10/24.
//
//

#import <UIKit/UIKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


typedef void(^ClickBlock)();
@interface UIScrollView (DPEmptyDataSet)<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic) ClickBlock clickBlock;                // 点击事件
@property (nonatomic, assign) CGFloat offset;               // 垂直偏移量
@property (nonatomic, strong) NSString *emptyText;          // 空数据显示内容
@property (nonatomic, strong) UIImage *emptyImage;          // 空数据的图片

@property (nonatomic, strong) NSString *buttonText;         //下边按钮的文字

- (void)setupEmptyData:(ClickBlock)clickBlock;
- (void)setupEmptyDataText:(NSString *)text tapBlock:(ClickBlock)clickBlock;
- (void)setupEmptyDataText:(NSString *)text verticalOffset:(CGFloat)offset tapBlock:(ClickBlock)clickBlock;
- (void)setupEmptyDataText:(NSString *)text verticalOffset:(CGFloat)offset emptyImage:(UIImage *)image buttonText:(NSString *)buttonText tapBlock:(ClickBlock)clickBlock;


@end
