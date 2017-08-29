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

#import "DSPullToRefreshView.h"

/*
 * Defines the localized strings table
 */
#define DS_PTR_LOCALIZED_STRINGS_TABLE                                 @"DSPullToRefresh"

/*
 * Texts to show in different states
 */
#define TXT_DS_PTR_PULL                                                @"下拉可以刷新"
#define TXT_DS_PTR_RELEASE                                             @"松开开始刷新"
#define TXT_DS_PTR_LOADING                                             @"正在刷新..."
#define TXT_DS_PRT_LAST_UPDATE_FORMAT                                  @"刷新时间: %@"

/*
 * Defines icon image
 */
#define DS_PTR_ICON_IMAGE                                              @"DSPullToRefreshIcon.png"

@interface DSPullToRefreshView()

/*
 * View that contains all controls.
 */
@property (nonatomic, readwrite, strong) UIView *containerView;

/*
 * Image view of the icon.
 */
@property (nonatomic, readwrite, strong) UIImageView *iconImageView;

/*
 * Activity indicator to show while loading (hiding the icon).
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *loadingActivityIndicator;

/*
 * Label to set state message.
 */
@property (nonatomic, readwrite, strong) UILabel *topLabel;

/*
 * Label to set last update message.
 */
@property (nonatomic, readwrite, strong) UILabel *bottomLabel;

/*
 * Current state of the control.
 */
@property (nonatomic, readwrite, assign) DSPullToRefreshViewState state;

/*
 * YES to apply rotation to the icon while view is in `DSPullToRefreshViewStatePull` state.
 */
@property (nonatomic, readwrite, assign) BOOL rotateIconWhileBecomingVisible;

/*
 * Date formatter to show the last update message in the correct format.
 */
@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;

@end

@implementation DSPullToRefreshView

@dynamic isLoading;
@synthesize containerView = containerView_;
@synthesize lastUpdateDate = lastUpdateDate_;
@synthesize iconImageView = iconImageView_;
@synthesize fixedHeight = fixedHeight_;
@synthesize loadingActivityIndicator = loadingActivityIndicator_;
@synthesize topLabel = topLabel_;
@synthesize bottomLabel = bottomLabel_;
@synthesize state = state_;
@synthesize rotateIconWhileBecomingVisible = rotateIconWhileBecomingVisible_;
@synthesize dateFormatter = dateFormatter_;

#pragma mark -
#pragma mark Initialization

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 * @param frame The frame rectangle for the view, measured in points.
 * @return An initialized view object or nil if the object couldn't be created.
 */
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        containerView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        
        [containerView_ setBackgroundColor:[UIColor clearColor]];
        [containerView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        
        [self addSubview:containerView_];
        
        UIImage *iconImage = [UIImage imageNamed:DS_PTR_ICON_IMAGE];
        
        iconImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, round(CGRectGetHeight(frame) / 2.0f) - round(iconImage.size.height / 2.0f), iconImage.size.width, iconImage.size.height)];
        [iconImageView_ setContentMode:UIViewContentModeCenter];
        [iconImageView_ setImage:iconImage];
        [iconImageView_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:iconImageView_];
        
        loadingActivityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingActivityIndicator_ setCenter:[iconImageView_ center]];
        [loadingActivityIndicator_ setHidesWhenStopped:YES];
        [loadingActivityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

        [containerView_ addSubview:loadingActivityIndicator_];
        
        //UIColor *labelsColor = [UIColor colorWithRed:76.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
        UIColor *labelsColor = MColor(36, 36, 36);
        
        CGFloat topMargin = 10.0f;
        CGFloat gap = 20.0f;
        
        topLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX([iconImageView_ frame]) + gap, topMargin, CGRectGetWidth(frame) - CGRectGetMaxX([iconImageView_ frame]) - gap * 2.0f, round((CGRectGetHeight(frame) - topMargin * 2.0f) / 2.0f))];
        [topLabel_ setBackgroundColor:[UIColor clearColor]];
        [topLabel_ setTextColor:labelsColor];
        [topLabel_ setFont:[UIFont systemFontOfSize:12.0f]];
        [topLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:topLabel_];
        
        bottomLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX([topLabel_ frame]), CGRectGetMaxY([topLabel_ frame]), CGRectGetWidth([topLabel_ frame]), CGRectGetHeight([topLabel_ frame]))];
        [bottomLabel_ setBackgroundColor:[UIColor clearColor]];
        [bottomLabel_ setTextColor:labelsColor];
        [bottomLabel_ setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [bottomLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        
        [containerView_ addSubview:bottomLabel_];
        
        fixedHeight_ = CGRectGetHeight(frame);
        rotateIconWhileBecomingVisible_ = YES;
        lastUpdateDate_ = [NSDate date];
        
        [self changeStateOfControl:DSPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];        
    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Lays out subviews.
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize topSize = [[topLabel_ text] sizeWithFont:[topLabel_ font]];
    CGSize bottomSize = [[bottomLabel_ text] sizeWithFont:[bottomLabel_ font]];
    
    CGRect frame = [topLabel_ frame];
    frame.size.width = topSize.width;
    [topLabel_ setFrame:frame];
    
    frame = [bottomLabel_ frame];
    frame.size.width = bottomSize.width;
    [bottomLabel_ setFrame:frame];
    
    UILabel *largerLabel = (topSize.width > bottomSize.width ? topLabel_ : bottomLabel_);

    frame = [containerView_ frame];
    frame.size.width = CGRectGetMaxX([largerLabel frame]);
    [containerView_ setFrame:frame];
    
    [containerView_ setCenter:CGPointMake([self center].x, [containerView_ center].y)];
}

/*
 * Changes the state of the control depending in state and offset values
 */
- (void)changeStateOfControl:(DSPullToRefreshViewState)state withOffset:(CGFloat)offset {
    
    state_ = state;
    
    CGFloat height = fixedHeight_;
    CGFloat yOrigin = -fixedHeight_;
    
    switch (state_) {
        
        case DSPullToRefreshViewStateIdle: {
            
            [iconImageView_ setTransform:CGAffineTransformIdentity];
            [iconImageView_ setHidden:NO];
            
            [loadingActivityIndicator_ stopAnimating];
            
            [bottomLabel_ setText:TXT_DS_PTR_PULL];
            
            if (dateFormatter_ == nil) {
            
                dateFormatter_ = [[NSDateFormatter alloc] init];
                
                [dateFormatter_ setLocale:[NSLocale currentLocale]];
                [dateFormatter_ setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter_ setTimeStyle:NSDateFormatterMediumStyle];
            }
            
            if (lastUpdateDate_ == nil) {
                [topLabel_ setText:@""];
            } else {
                [topLabel_ setText:[NSString stringWithFormat:TXT_DS_PRT_LAST_UPDATE_FORMAT, [dateFormatter_ stringFromDate:lastUpdateDate_]]];
            }
            
            break;
            
        } case DSPullToRefreshViewStatePull: {
            
            if (rotateIconWhileBecomingVisible_) {
            
                CGFloat angle = (-offset * M_PI) / CGRectGetHeight([self frame]);
                
                [iconImageView_ setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
                
            } else {
            
                [iconImageView_ setTransform:CGAffineTransformIdentity];
            }
            
            [bottomLabel_ setText:TXT_DS_PTR_PULL];
            
            break;
            
        } case DSPullToRefreshViewStateRelease: {
            
            iconImageView_.transform = CGAffineTransformMakeRotation(M_PI);
            
            [bottomLabel_ setText:TXT_DS_PTR_RELEASE];
            
            height = -offset;
            yOrigin = offset;
            
            break;
            
        } case DSPullToRefreshViewStateLoading: {
            
            [iconImageView_ setHidden:YES];
            
            [loadingActivityIndicator_ startAnimating];
            
            [bottomLabel_ setText:TXT_DS_PTR_LOADING];
            
            height = -offset;
            yOrigin = offset;
            
            if (lastUpdateDate_ == nil) {
                [topLabel_ setText:@""];
            } else {
                [topLabel_ setText:[NSString stringWithFormat:TXT_DS_PRT_LAST_UPDATE_FORMAT, [dateFormatter_ stringFromDate:lastUpdateDate_]]];
            }
            
            break;
            
        } default:
            break;
    }
    
    CGRect frame = [self frame];
    frame.size.height = height;
    frame.origin.y = yOrigin;    
    [self setFrame:frame];
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Properties

/*
 * Returns state of activity indicator
 */
- (BOOL)isLoading {
    
    return [loadingActivityIndicator_ isAnimating];
}

@end
