//
//  DSButton.h
//  wedding
//
//  Created by Jianyong Duan on 14/11/24.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSButton : UIButton


//name
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic) NSInteger index;

@property (nonatomic, copy) NSString *urlString;
//cellL里面是否上下车的标志
@property (nonatomic, copy) NSString *trainState;
/**
 *在cell里面的的下标
 */
@property (nonatomic, copy) NSIndexPath *indexPath;

@property (strong, nonatomic) NSString *phone;

@end
