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

#import <Foundation/Foundation.h>

/**
 * Enumerates control's state
 */
typedef enum {
    
    DSPullToRefreshViewStateIdle = 0, //<! The control is invisible right after being created or after a reloading was completed
    DSPullToRefreshViewStatePull, //<! The control is becoming visible and shows "pull to refresh" message
    DSPullToRefreshViewStateRelease, //<! The control is whole visible and shows "release to load" message
    DSPullToRefreshViewStateLoading, //<! The control is loading and shows activity indicator
    DSPullToRefreshViewStateinit


} DSPullToRefreshViewState;

/**
 * Pull to refresh view. Its state, visuals and behavior is managed by an instance of `DSPullToRefreshManager`.
 */
@interface DSPullToRefreshView : UIView

/**
 * Returns YES if the view is in Loading state.
 */
@property (nonatomic, readonly) BOOL isLoading;

/**
 * Last update date.
 */
@property (nonatomic, readwrite, strong) NSDate *lastUpdateDate;

/**
 * Fixed height of the view. This value is used to check the triggering of the refreshing.
 */
@property (nonatomic, readonly) CGFloat fixedHeight;

/**
 * Changes the state of the control depending in state and offset values.
 *
 * Values of *DSPullToRefreshViewState*:
 *
 * - `DSPullToRefreshViewStateIdle` The control is invisible right after being created or after a reloading was completed.
 * - `DSPullToRefreshViewStatePull` The control is becoming visible and shows "pull to refresh" message.
 * - `DSPullToRefreshViewStateRelease` The control is whole visible and shows "release to load" message.
 * - `DSPullToRefreshViewStateLoading` The control is loading and shows activity indicator.
 *
 * @param state The state to set.
 * @param offset The offset of the table scroll.
 */
- (void)changeStateOfControl:(DSPullToRefreshViewState)state withOffset:(CGFloat)offset;

@end
