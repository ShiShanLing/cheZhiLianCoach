//
//  DSButton.h
//  wedding
//
//  Created by Jianyong Duan on 14/11/24.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSButton : UIButton

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic) NSInteger index;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, copy) NSIndexPath *indexPath;

@property (strong, nonatomic) NSString *phone;

@end
