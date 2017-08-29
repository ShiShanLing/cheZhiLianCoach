//
//  SearchAddrViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface SearchAddrViewController : GreyTopViewController  //定位上车地址

//input
@property (strong, nonatomic) NSString *latitude;//维度
@property (strong, nonatomic) NSString *longitude;//经度
@property (strong, nonatomic) NSString *address;//地址
@end
