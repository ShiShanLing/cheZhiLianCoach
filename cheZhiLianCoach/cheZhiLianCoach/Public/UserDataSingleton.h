//
//  UserDataSingleton.h
//  cheZhiLian
//
//  Created by 石山岭 on 2017/8/17.
//  Copyright © 2017年 石山岭. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *临时存储用户信息的单例 作用是在用户登录期间各个界面直接获取用的一些基本信息  当本地存储的信息不被销毁是这些数据失败被销毁的 因为当用户打开App的时候会自动在单例里面给数据赋值
 */
@interface UserDataSingleton : NSObject
+ (UserDataSingleton *)mainSingleton;

@property (nonatomic, copy)NSString *subState;
@property (nonatomic, copy)NSString *studentsId;
@property (nonatomic, copy)NSString *memberId;
@property (nonatomic, copy)NSString *coachId;
@end
