//
//  CommonUtil.h
//  wedding
//
//  Created by duanjycc on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

/**
 *  共同处理类单例实例化
 *
 *  @return 共同处理类单例
 */
+ (instancetype)currentUtil;

// 判断空字符串
+ (BOOL)isEmpty:(NSString *)string;
+ (NSString *)stringForID:(id)objectid;

//图片方向处理
+ (UIImage *)fixOrientation:(UIImage *)srcImg;

//读取 NSUserDefaults
+ (id)getObjectFromUD:(NSString *)key;

//存储 NSUserDefaults
+ (void)saveObjectToUD:(id)value key:(NSString *)key;
+ (void)deleteObjectFromUD:(NSString *)key;

//MD5加密
+ (NSString *)md5:(NSString *)password;

//手机号码验证
+ (BOOL)checkPhonenum:(NSString *)phone;

//获得设备型号
+ (NSString *)getCurrentDeviceModel;

//判断是否登录
- (BOOL)isLogin;
- (BOOL)isLogin:(BOOL)needLogin;
- (NSString *)getLoginUserid;


//****************** 关于时间方法 <S> ******************

/**
 计算一个时间与现在的时间的差值

 @param fromdate date
 @return 如果是天 那就返回天 如果不足一天那就返回 小时数 如果不足一个小时那就返回分钟数
 */
+ (NSString *)getTimeDiff:(NSDate *)fromdate;
/**
 NSdate转NSString

 @param date date
 @param format 样式 默认 yyyy-MM-dd HH:mm:ss
 @return 时间字符串
 */
+ (NSString *)getStringForDate:(NSDate *)date format:(NSString *)format;


/**
 时间字符串转date

 @param string 时间字符串
 @param format 样式
 @return 时间的NSDate
 */
+ (NSDate *)getDateForString:(NSString *)string format:(NSString *)format;
//获取当前时间的时间戳
+ (NSString*)getCurrentTimes;
// 记录debug数据(log)
+ (void)writeDebugLogName:(NSString *)name data:(NSString *)data;


// 根据文字，字号及固定宽(固定高)来计算高(宽)
+ (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height;

// 窗口弹出动画
+ (void)shakeToShow:(UIView*)aView;
+ (UIImage *) maskImage: (UIImage *) sourceImage withMask: (UIImage *) image;
// 图片缩小
+ (UIImage *)scaleImage:(UIImage *)image minLength:(float)length;

+ (void) logout;

@end
