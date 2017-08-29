/*
 * Copyright (c) 13/11/2012 Mario Negro (@emenegro)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DSPullToRefreshManager.h"
#import "DSPullToRefreshView.h"

static CGFloat const kAnimationDuration = 0.2f;

@interface DSPullToRefreshManager()

/*
 * The pull-to-refresh view to add to the top of the table.
 */
@property (nonatomic, readwrite, strong) DSPullToRefreshView *pullToRefreshView;

/*
 * Table view in which pull to refresh view will be added.
 */
@property (nonatomic, readwrite, assign) UITableView *table;

/*
 * Client object that observes changes in the pull-to-refresh.
 */
@property (nonatomic, readwrite, weak) id<DSPullToRefreshManagerClient> client;

@end

@implementation DSPullToRefreshManager

#pragma mark -
#pragma mark Instance initialization

/*
 * Initializes the manager object with the information to link view and table
 */
- (id)initWithPullToRefreshViewHeight:(CGFloat)height tableView:(UITableView *)table withClient:(id<DSPullToRefreshManagerClient>)client {

    if (self = [super init]) {
        
        self.client = client;
        self.table = table;        
        self.pullToRefreshView = [[DSPullToRefreshView alloc] initWithFrame:CGRectMake(0.0f, -height, CGRectGetWidth([self.table frame]), height)];
        self.pullToRefreshView.backgroundColor = [UIColor clearColor];
        
        [self.table addSubview:self.pullToRefreshView];
    }
    
    return self;
}

#pragma mark -
#pragma mark Table view scroll management

/*
 * Checks state of control depending on tableView scroll offset
 */
- (void)tableViewScrolled {
    
    if (![self.pullToRefreshView isHidden] && ![self.pullToRefreshView isLoading]) {
        
        CGFloat offset = [self.table contentOffset].y;

        if (offset >= 0.0f) {
        
            [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateIdle withOffset:offset];
            
        } else if (offset <= 0.0f && offset >= -[self.pullToRefreshView fixedHeight]) {
                
            [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStatePull withOffset:offset];
            
        } else {
            
            [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateRelease withOffset:offset];
        }
    }
}

/*
 * Checks releasing of the tableView
 */
- (void)tableViewReleased {
    
    if (![self.pullToRefreshView isHidden] && ![self.pullToRefreshView isLoading]) {
        
        CGFloat offset = [self.table contentOffset].y;
        
        if (offset <= 0.0f && offset < -[self.pullToRefreshView fixedHeight]) {
            
            [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateLoading withOffset:offset];
            
            UIEdgeInsets insets = UIEdgeInsetsMake([self.pullToRefreshView fixedHeight], 0.0f, 0.0f, 0.0f);
            
            [UIView animateWithDuration:kAnimationDuration animations:^{

                [self.table setContentInset:insets];
            }];
            
            [self.client pullToRefreshTriggered:self];
        }
    }
}

/*
 * The reload of the table is completed
 */
- (void)tableViewReloadFinishedAnimated:(BOOL)animated {
    [self tableViewReloadFinished:[NSDate date] Animated:animated];
}

- (void)tableViewReloadFailedAnimated:(BOOL)animated {
    [self tableViewReloadFinished:nil Animated:animated];
}

- (void)tableViewReloadFinished:(NSDate *)finishDate Animated:(BOOL)animated {
    
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f) animations:^{
        
        [self.table setContentInset:UIEdgeInsetsZero];
    
    } completion:^(BOOL finished) {
        if (finishDate) {
            [self.pullToRefreshView setLastUpdateDate:finishDate];
        }
        
        [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
    }];    
}

- (void)tableViewReloadStartAnimated:(BOOL)animated {
    [self tableViewReloadStart:nil Animated:animated];
}

- (void)tableViewReloadStart:(NSDate *)startDate Animated:(BOOL)animated {
    UIEdgeInsets insets = UIEdgeInsetsMake([self.pullToRefreshView fixedHeight], 0.0f, 0.0f, 0.0f);
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0.0f) animations:^{
        
        [self.table setContentInset:insets];
        
    } completion:^(BOOL finished) {
        if (startDate) {
            [self.pullToRefreshView setLastUpdateDate:startDate];
        } else {
            [self.pullToRefreshView setLastUpdateDate:nil];
        }
        //[self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
        
        [self.pullToRefreshView changeStateOfControl:DSPullToRefreshViewStateLoading withOffset:-[self.pullToRefreshView fixedHeight]];
    }];
}

#pragma mark -
#pragma mark Properties

/*
 * Sets the pull-to-refresh view visible or not. Visible by default
 */
- (void)setPullToRefreshViewVisible:(BOOL)visible {
    
    [self.pullToRefreshView setHidden:!visible];
}

@end