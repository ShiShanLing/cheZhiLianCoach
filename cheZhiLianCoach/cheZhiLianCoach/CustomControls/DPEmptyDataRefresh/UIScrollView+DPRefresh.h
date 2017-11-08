//
//  UIScrollView+DPRefresh.h
//  DPEmptyDataRefresh
//
//  Created by 人众 on 2017/10/24.
//
//

#import <UIKit/UIKit.h>

@interface UIScrollView (DPRefresh)
- (void)setRefreshWithHeaderBlock:(void(^)())headerBlock
                      footerBlock:(void(^)())footerBlock;


- (void)headerBeginRefreshing;
- (void)headerEndRefreshing;
- (void)footerEndRefreshing;
- (void)footerNoMoreData;

- (void)hideHeaderRefresh;
- (void)hideFooterRefresh;

@end
