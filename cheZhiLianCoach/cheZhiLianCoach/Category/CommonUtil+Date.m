//
//  CommonUtils+Date.m
//  Nightclub
//
//  Created by 赵 伟 on 13-11-27.
//  Copyright (c) 2013年 赵伟. All rights reserved.
//

#import "CommonUtil+Date.h"

@implementation CommonUtil (Date)

/****************** 关于时间方法 ******************/

// Date 转换 NSString (默认格式：@"yyyy-MM-dd HH:mm:ss")
+ (NSString *)getStringForDate:(NSDate *)date {
	return [self getStringForDate:date format:@"yyyy-MM-dd HH:mm:ss"];
}

// Date 转换 NSString (默认格式：自定义)
/**
 date 转时间戳

 @param date 时间date
 @param format 格式
 @return 时间戳
 */
+ (NSString *)getDateTurnString:(NSDate *)date format:(NSString *)format {
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
	return timeSp;
}
/**
 讲时间戳转成date

 @param string <#string description#>
 @param format <#format description#>
 @return <#return value description#>
 */
+ (NSDate *)getStringTurnDate:(NSString *)string; {
    NSTimeInterval time=[string doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    return detaildate;
}

/* 取二个时间的相差“秒”数 */
+ (NSNumber *)getDiffSecond:(NSDate *)fromdate toDate:(NSDate *)todate {
    NSTimeInterval fromInt = [fromdate timeIntervalSince1970];  // 获取离1970年间隔
    NSTimeInterval toInt = [todate timeIntervalSince1970];
    
    NSTimeInterval interval = toInt - fromInt;  // 获取时间差值
    return [NSNumber numberWithInt:interval*1];
}

/****************** 追加_关于时间方法 ******************/

// 取得年龄
+ (NSNumber *)getAgeFromBirthday:(NSDate *)birthdate {
    if (birthdate == nil) return 0;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //根据components参数来计算两个日起之间的差距
    //unsigned int unitFlags=NSMonthCalendarUnit | NSDayCalendarUnit;
    //SDateComponents *comps = [gregorian components:unitFlags fromDate:startDate  toDate:endDate  options:0];
    //int months = [comps month];
    //int days = [comps day];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit
                                                fromDate:birthdate
                                                  toDate:[NSDate date]
                                                 options:0];
    NSInteger years = [components year];
    
    return [NSNumber numberWithInteger:years];
}

// 发布时间表示
+ (NSString*)intervalSinceNow:(NSString*)theDate {
    NSDateFormatter*date = [[NSDateFormatter alloc] init];  // 日期格式化
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *d = [date dateFromString:theDate];              // 转换Date类型
    NSTimeInterval late=[d timeIntervalSince1970]*1;        // 时间转成时间戳
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];  // 获取现在时间（得到0秒前的日期）
    NSTimeInterval now=[dat timeIntervalSince1970]*1;       // 时间转成时间戳
    
    NSString *timeString = @"";                             // 定义时间值
    NSTimeInterval cha = now - late;                        // 获取时间戳差值
    
    // 发表在一小时之内
    if(cha/3600 < 1) {   // 小于1小时
        if(cha/60<1) {   // 小于1分钟
            timeString = @"1";
        }
        else {           // 大于1分钟
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
    }
    
    // 在一小时以上-24小时以内
    else if(cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    
    // 发表在1天以上-10天以内
    else if(cha/86400>1&&cha/864000<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    
    // 发表时间大于10天
    else {
        timeString = [self getStringForDate:d format:@"yyyy-MM-dd"];
    }
    return timeString;
}

// 取得时间差（“YYYY”-年 “MM”-月 “DD”-天 “HH”-小时 "MI"-分 “SS”-秒）
+ (NSInteger)getTimeDiff:(NSDate *)fromdate type:(NSString *)type {
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    if (fromDate == nil) return 0;
    
    //获取当前时间
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar ];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];
    
    if ([@"YYYY" isEqualToString:type]) {
        return [components year];
    }
    if ([@"MM" isEqualToString:type]) {
        return [components month];
    }
    if ([@"DD" isEqualToString:type]) {
        return [components day];
    }
    if ([@"HH" isEqualToString:type]) {
        return [components hour];
    }
    if ([@"MI" isEqualToString:type]) {
        return [components minute];
    }
    if ([@"SS" isEqualToString:type]) {
        return [components second];
    }
    return 0;
}

// 取得星座
+ (NSString *)getStarFromBirthday:(NSDate *)birthdate {
    if (birthdate == nil) {
        return @"";
    }
    NSString *birth = [self getStringForDate:birthdate format:@"MM/dd"];
    
    if ([birth compare:@"03/20"] == NSOrderedDescending
        && [birth compare:@"04/21"] == NSOrderedAscending) {
        return @"白羊座";
    } else if ([birth compare:@"04/20"] == NSOrderedDescending
               && [birth compare:@"05/21"] == NSOrderedAscending) {
        return @"金牛座";
    } else if ([birth compare:@"05/20"] == NSOrderedDescending
               && [birth compare:@"06/22"] == NSOrderedAscending) {
        return @"双子座";
    } else if ([birth compare:@"06/21"] == NSOrderedDescending
               && [birth compare:@"07/23"] == NSOrderedAscending) {
        return @"巨蟹座";
    } else if ([birth compare:@"07/22"] == NSOrderedDescending
               && [birth compare:@"08/23"] == NSOrderedAscending) {
        return @"狮子座";
    } else if ([birth compare:@"08/22"] == NSOrderedDescending
               && [birth compare:@"09/23"] == NSOrderedAscending) {
        return @"处女座";
    } else if ([birth compare:@"09/22"] == NSOrderedDescending
               && [birth compare:@"10/22"] == NSOrderedAscending) {
        return @"天秤座";
    } else if ([birth compare:@"10/21"] == NSOrderedDescending
               && [birth compare:@"11/22"] == NSOrderedAscending) {
        return @"天蝎座";
    } else if ([birth compare:@"11/21"] == NSOrderedDescending
               && [birth compare:@"12/22"] == NSOrderedAscending) {
        return @"射手座";
    } else if ([birth compare:@"01/19"] == NSOrderedDescending
               && [birth compare:@"02/19"] == NSOrderedAscending) {
        return @"水瓶座";
    } else if ([birth compare:@"02/18"] == NSOrderedDescending
               && [birth compare:@"03/21"] == NSOrderedAscending) {
        return @"双鱼座";
    } else {
        return @"摩羯座";
    }
}

/*!
 获取某个日期
 @param addDate 需要加减的日期
 @param year 需要增加的年数
 @param month 需要增加的月数
 @param day 需要增加的天数
 @return 返回NSDateComponents类型
 */
+ (NSDateComponents *)addDate:(NSDate *)addDate year:(long)year month:(long)month day:(long)day{
    //获取结束日期
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:addDate];
    [dateCom setYear:year];
    [dateCom setMonth:month];//查看month个月后日期
    [dateCom setDay:day];
    return dateCom;
}

/*!
 获取某个日期
 @param addDate 需要加减的日期
 @param year 需要增加的年数
 @param month 需要增加的月数
 @param day 需要增加的天数
 @return 返回NSDate类型
 */
+ (NSDate *)addDate2:(NSDate *)addDate year:(long)year month:(long)month day:(long)day{
    //获取结束日期
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:addDate];
    [dateCom setYear:year];
    [dateCom setMonth:month];//查看month个月后日期
    [dateCom setDay:day];
    [dateCom setHour:0];
    [dateCom setMinute:0];
    [dateCom setSecond:0];
    return [cal dateByAddingComponents:dateCom toDate:addDate options:0];
}

/*!
 获取某个时间
 @param addTime 需要加减的日期
 @param hour 需要增加的小时
 @param minute 需要增加的分钟
 @param second 需要增加的秒
 @return 返回NSDate类型
 */
+ (NSDate *)addTime:(NSDate *)addTime hour:(long)hour minute:(long)minute second:(long)second{
    //获取结束日期
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:addTime];
    [dateCom setYear:0];
    [dateCom setMonth:0];//查看month个月后日期
    [dateCom setDay:0];
    [dateCom setHour:hour];
    [dateCom setMinute:minute];
    [dateCom setSecond:second];
    return [cal dateByAddingComponents:dateCom toDate:addTime options:0];
}

+ (NSInteger) getHourOfDate:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return [dateComponent hour];
}

/*!
 获取今天是星期几
 */
+ (NSInteger)getWeekdayOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSWeekdayCalendarUnit fromDate:date];
    return [dateCom weekday];
}

/*!
 获取今天所在本月第几周
 */
+ (NSInteger)getWeekOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSWeekOfMonthCalendarUnit fromDate:date];
    return [dateCom weekOfMonth];
}


/*!
 获取今天的号数
 */
+ (NSInteger)getdayOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSDayCalendarUnit fromDate:date];
    return [dateCom day];
}

/*!
 获取今天的月份
 */
+ (NSInteger)getMonthOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom = [cal components:NSMonthCalendarUnit fromDate:date];
    return [dateCom month];
}

/*!
 获取今天的年份
 */
+ (NSInteger)getYearOfDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return [dateComponent year];
}

/*!
 获取本月有几周
 */
+ (NSInteger)getWeekCountOfDate:(NSDate *)date{
    NSDate *endDate = [self getLastDayOfDate:date];
    return [self getWeekOfDate:endDate];
}

/*!
 获取月末时间
 */
+ (NSDate *)getLastDayOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    //获取今天与月末相差的天数
    long day = range.length - [[cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date] day];
    NSDateComponents *dateCom = [self addDate:date year:0 month:0 day:day];
    return [cal dateByAddingComponents:dateCom toDate:date options:0];
}

/*!
 获取月初时间
 */
+ (NSDate *)getFirstDayOfDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayCom = [cal components:NSDayCalendarUnit fromDate:date];
    long today = [dayCom day];
    NSDateComponents *dateCom = [self addDate:date year:0 month:0 day:1-today];
    return [cal dateByAddingComponents:dateCom toDate:date options:0];
}

/*!
 判断相差几个月
 @param firstDate 被比较日期
 @param sendDate 比较的日期
 */
+ (NSInteger)compareMonth:(NSDate *)firstDate sendDate:(NSDate *)sendDate{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//NSMonthCalendarUnit
    NSDateComponents *components = [cal components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:firstDate toDate:sendDate options:0];
    return [components month];
}

//获取中文的星期
+ (NSString *)getChineseWeekday:(NSDate *)date{
    NSString *weekday = [CommonUtil getStringForDate:date format:@"EEEE"];
    if ([weekday isEqualToString:@"Monday"] ||[weekday isEqualToString:@"星期一"] ) {
        return @"星期一";
    }else if ([weekday isEqualToString:@"Tuesday"] || [weekday isEqualToString:@"星期二"]){
        return @"星期二";
    }else if ([weekday isEqualToString:@"Wednesday"] || [weekday isEqualToString:@"星期三"]){
        return @"星期三";
    }else if ([weekday isEqualToString:@"Thursday"] || [weekday isEqualToString:@"星期四"]){
        return @"星期四";
    }else if ([weekday isEqualToString:@"Friday"] || [weekday isEqualToString:@"星期五"]){
        return @"星期五";
    }else if ([weekday isEqualToString:@"Saturday"] || [weekday isEqualToString:@"星期六"]){
        return @"星期六";
    }else if ([weekday isEqualToString:@"Sunday"] || [weekday isEqualToString:@"星期日"]){
        return @"星期日";
    }
    return @"";
}

//获取英文的星期
+ (NSString *)getEnglishWeekday:(NSDate *)date{
    NSString *weekday = [CommonUtil getStringForDate:date format:@"EEEE"];
    if ([weekday isEqualToString:@"Monday"] ||[weekday isEqualToString:@"星期一"] ) {
        return @"Monday";
    }else if ([weekday isEqualToString:@"Tuesday"] || [weekday isEqualToString:@"星期二"]){
        return @"Tuesday";
    }else if ([weekday isEqualToString:@"Wednesday"] || [weekday isEqualToString:@"星期三"]){
        return @"Wednesday";
    }else if ([weekday isEqualToString:@"Thursday"] || [weekday isEqualToString:@"星期四"]){
        return @"Thursday";
    }else if ([weekday isEqualToString:@"Friday"] || [weekday isEqualToString:@"星期五"]){
        return @"Friday";
    }else if ([weekday isEqualToString:@"Saturday"] || [weekday isEqualToString:@"星期六"]){
        return @"Saturday";
    }else if ([weekday isEqualToString:@"Sunday"] || [weekday isEqualToString:@"星期日"]){
        return @"Sunday";
    }
    return @"";
}

//获取英文的月份
+ (NSString *)getEnglishMonth:(NSDate *)date{
    NSString *month = [CommonUtil getStringForDate:date format:@"MMMM"];
    if ([month isEqualToString:@"January"] ||[month isEqualToString:@"一月"] ) {
        return @"January";
    }else if ([month isEqualToString:@"February"] || [month isEqualToString:@"二月"]){
        return @"February";
    }else if ([month isEqualToString:@"March"] || [month isEqualToString:@"三月"]){
        return @"March";
    }else if ([month isEqualToString:@"April"] || [month isEqualToString:@"四月"]){
        return @"April";
    }else if ([month isEqualToString:@"May"] || [month isEqualToString:@"五月"]){
        return @"May";
    }else if ([month isEqualToString:@"June"] || [month isEqualToString:@"六月"]){
        return @"June";
    }else if ([month isEqualToString:@"July"] || [month isEqualToString:@"七月"]){
        return @"July";
    }else if ([month isEqualToString:@"August"] || [month isEqualToString:@"八月"]){
        return @"August";
    }else if ([month isEqualToString:@"September"] || [month isEqualToString:@"九月"]){
        return @"September";
    }else if ([month isEqualToString:@"October"] || [month isEqualToString:@"十月"]){
        return @"October";
    }else if ([month isEqualToString:@"November"] || [month isEqualToString:@"十一月"]){
        return @"November";
    }else if ([month isEqualToString:@"December"] || [month isEqualToString:@"十二月"]){
        return @"December";
    }
    return @"";
}

// 1970年秒差 时间戳->标准时间 String 转换 Date (默认格式：自定义)
+ (NSDate *)getDateFromTimeStamp:(NSString *)string{
    
    NSTimeInterval time = [string intValue];
    NSDate *orderDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    return orderDate;
}



@end
