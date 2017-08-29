/*
 * Copyright (c) 2012 Mario Negro Martín
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

#import "DSBottomPullToMoreManager.h"
#import "DSBottomPullToMoreView.h"

CGFloat const kAnimationDuration = 0.2f;

@interface DSBottomPullToMoreManager()

/*
 * Pull-to-More view
 */
@property (nonatomic, readwrite, strong) DSBottomPullToMoreView *pullToMoreView;

/*
 * Table view which p-t-r view will be added
 */
@property (nonatomic, readwrite, assign) UITableView *table;

/*
 * Client object that observes changes
 */
@property (nonatomic, readwrite, assign) id<DSBottomPullToMoreManagerClient> client;

/*
 * Returns the correct offset to apply to the pull-to-More view, depending on contentSize
 *
 * @return The offset
 * @private
 */
- (CGFloat)tableScrollOffset;

@end

@implementation DSBottomPullToMoreManager

@synthesize pullToMoreView = pullToMoreView_;

#pragma mark -
#pragma mark Instance initialization

/*
 * Initializes the manager object with the information to link view and table
 */
- (id)initWithPullToMoreViewHeight:(CGFloat)height tableView:(UITableView *)table withClient:(id<DSBottomPullToMoreManagerClient>)client {

    if (self = [super init]) {
        
        self.client = client;
        self.table = table;
        pullToMoreView_ = [[DSBottomPullToMoreView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([_table frame]), height)];
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Returns the correct offset to apply to the pull-to-More view, depending on contentSize
 */
- (CGFloat)tableScrollOffset {
    
    CGFloat offset = 0.0f;        
    
    if ([_table contentSize].height < CGRectGetHeight([_table frame])) {
        
        offset = -[_table contentOffset].y;
        
    } else {
        
        offset = ([_table contentSize].height - [_table contentOffset].y) - CGRectGetHeight([_table frame]);
    }
    
    return offset;
}

/*
 * Relocate pull-to-More view
 */
- (void)relocatePullToMoreView {
    
    CGFloat yOrigin = 0.0f;
    
    if ([_table contentSize].height >= CGRectGetHeight([_table frame])) {
        
        yOrigin = [_table contentSize].height;
        
    } else {
        
        yOrigin = CGRectGetHeight([_table frame]);
    }
    
    CGRect frame = [pullToMoreView_ frame];
    frame.origin.y = yOrigin;
    [pullToMoreView_ setFrame:frame];
    
    [_table addSubview:pullToMoreView_];
}

/*
 * Sets the pull-to-More view visible or not. Visible by default
 */
- (void)setPullToMoreViewVisible:(BOOL)visible {
    
    [pullToMoreView_ setHidden:!visible];
}

#pragma mark -
#pragma mark Table view scroll management

/*
 * Checks state of control depending on tableView scroll offset
 */
- (void)tableViewScrolled {
    
    if (![pullToMoreView_ isHidden] && ![pullToMoreView_ isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];

        if (offset >= 0.0f) {
            
            [pullToMoreView_ changeStateOfControl:DSBottomPullToMoreViewStateIdle offset:offset];
            
        } else if (offset <= 0.0f && offset >= -[pullToMoreView_ fixedHeight]) {
                
            [pullToMoreView_ changeStateOfControl:DSBottomPullToMoreViewStatePull offset:offset];
            
        } else {
            
            [pullToMoreView_ changeStateOfControl:DSBottomPullToMoreViewStateRelease offset:offset];
        }
    }
}

/*
 * Checks releasing of the tableView
 */
- (void)tableViewReleased {
    
    if (![pullToMoreView_ isHidden] && ![pullToMoreView_ isLoading]) {
        
        CGFloat offset = [self tableScrollOffset];
        CGFloat height = -[pullToMoreView_ fixedHeight];
        
        if (offset <= 0.0f && offset < height) {
            
            [_client bottomPullToMoreTriggered:self];
            
            [pullToMoreView_ changeStateOfControl:DSBottomPullToMoreViewStateLoading offset:offset];
            
            [UIView animateWithDuration:kAnimationDuration animations:^{
                
                if ([_table contentSize].height >= CGRectGetHeight([_table frame])) {
                
                    [_table setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f)];
                    
                } else {
                    
                    [_table setContentInset:UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f)];
                }
            }];
        }
    }
}

/*
 * The reload of the table is completed
 */
- (void)tableViewReloadFinished {
    
    [_table setContentInset:UIEdgeInsetsZero];

    [self relocatePullToMoreView];

    [pullToMoreView_ changeStateOfControl:DSBottomPullToMoreViewStateIdle offset:CGFLOAT_MAX];
}

@end