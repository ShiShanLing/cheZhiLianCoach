//
//  UIPlaceHolderTextView.h
//  BabyPhoto
//
//  Created by ITS 段建勇 on 11-11-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIPlaceHolderTextView : UITextView {
	NSString *placeholder;
	UIColor *placeholderColor;
	
@private
	UILabel *placeHolderLabel;
}

@property (nonatomic, retain) UILabel *placeHolderLabel;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification *)notification;

@end
