//
//  CommonUtils+Date.h
//  Nightclub
//
//  Created by 赵 伟 on 13-11-27.
//  Copyright (c) 2013年 赵伟. All rights reserved.
//
//  共同方法——时间
//

#import <Foundation/Foundation.h>
#import "CommonUtil.h"

@interface CommonUtil (Date)

/****************** 关于时间方法 <S> ******************/

// Date 转换 NSString (默认格式：@"yyyy-MM-dd HH:mm:ss")
+ (NSString *)getStringForDate:(NSDate *)date;

// Date 转换 NSString (默认格式：自定义)
+ (NSString *)getStringForDate:(NSDate *)date format:(NSString *)format;

// NSString 转换 Date (默认格式：自定义)
+ (NSDate *)getDateForString:(NSString *)string format:(NSString *)format;

/* 取二个时间的相差“秒”数 */
+ (NSNumber *)getDiffSecond:(NSDate *)fromdate toDate:(NSDate *)todate;

/****************** 追加_关于时间方法 ******************/

// 取得年龄
+ (NSNumber *)getAgeFromBirthday:(NSDate *)birthdate;

// 发布时间表示
+ (NSString *)intervalSinceNow:(NSString *)theDate;

// 取得时间差（“YYYY”-年 “MM”-月 “DD”-天 “HH”-小时 "MI"-分 “SS”-秒）
+ (NSInteger)getTimeDiff:(NSDate *)fromdate type:(NSString *)type;

// 取得星座
+ (NSString *)getStarFromBirthday:(NSDate *)birthdate;


/*!
 获取某个日期
 @param addDate 需要加减的日期
 @param year 需要增加的年数
 @param month 需要增加的月数
 @param day 需要增加的天数
 @return 返回NSDateComponents类型
 */
+ (NSDateComponents *)addDate:(NSDate *)addDate year:(long)year month:(long)month day:(long)day;

/*!
 获取某个日期
 @param addDate 需要加减的日期
 @param year 需要增加的年数
 @param month 需要增加的月数
 @param day 需要增加的天数
 @return 返回NSDate类型
 */
+ (NSDate *)addDate2:(NSDate *)addDate year:(long)year month:(long)month day:(long)day;

/*!
 获取某个时间
 @param addTime 需要加减的日期
 @param hour 需要增加的小时
 @param minute 需要增加的分钟
 @param second 需要增加的秒
 @return 返回NSDate类型
 */
+ (NSDate *)addTime:(NSDate *)addTime hour:(long)hour minute:(long)minute second:(long)second;

/*!
 获取今天是星期几
 */
+ (NSInteger)getWeekdayOfDate:(NSDate *)date;

/*!
 获取今天所在本月第几周
 */
+ (NSInteger)getWeekOfDate:(NSDate *)date;

/*!
 获取今天的号数
 */
+ (NSInteger)getdayOfDate:(NSDate *)date;

/*!
 获取今天的月份
 */
+ (NSInteger)getMonthOfDate:(NSDate *)date;

/*!
 获取本月有几周
 */
+ (NSInteger)getWeekCountOfDate:(NSDate *)date;

/*!
 获取月末时间
 */
+ (NSDate *)getLastDayOfDate:(NSDate *)date;

/*!
 获取月初时间
 */
+ (NSDate *)getFirstDayOfDate:(NSDate *)date;

/*!
 判断相差几个月
 @param firstDate 被比较日期
 @param sendDate 比较的日期
 */
+ (NSInteger)compareMonth:(NSDate *)firstDate sendDate:(NSDate *)sendDate;

//获取中文的星期
+ (NSString *)getChineseWeekday:(NSDate *)date;

//获取英文的星期
+ (NSString *)getEnglishWeekday:(NSDate *)date;

//获取英文的月份
+ (NSString *)getEnglishMonth:(NSDate *)date;

//获取中文的星期
+ (NSString *)getChineseWeekday:(NSDate *)date;

//获取英文的星期
+ (NSString *)getEnglishWeekday:(NSDate *)date;

//获取英文的月份
+ (NSString *)getEnglishMonth:(NSDate *)date;

/*! 1970年秒差 时间戳->标准时间 String 转换 Date (默认格式：自定义)
 */
+ (NSDate *)getDateFromTimeStamp:(NSString *)string;

/**获取Date 的小时**/
+ (NSInteger) getHourOfDate:(NSDate*)date;

+ (NSInteger)getYearOfDate:(NSDate *)date;
+ (NSString*)getCurrentTimes;
@end
