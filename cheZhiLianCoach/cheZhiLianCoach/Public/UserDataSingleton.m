//
//  UserDataSingleton.m
//  cheZhiLian
//
//  Created by 石山岭 on 2017/8/17.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import "UserDataSingleton.h"

@implementation UserDataSingleton
+ (UserDataSingleton *)mainSingleton {
    static UserDataSingleton *ton = nil;
    if (ton == nil) {
        ton = [[UserDataSingleton alloc] init];
    }
    return ton;
}
@end
