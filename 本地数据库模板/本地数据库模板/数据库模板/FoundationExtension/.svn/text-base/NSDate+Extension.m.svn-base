//
//  NSDate+Extension.m
//  XesSpeiyouSystemClient
//
//  Created by v v on 13-5-7.
//  Copyright (c) 2013年 XueErSi. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)
+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+ (NSString*)stringMonthDayFormat:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *dateStr = [NSDate stringFromDate:date];
    NSString *year = @"yyyy-";
    NSString *second = @":ss";
    return [dateStr substringWithRange:NSMakeRange([year length], [dateStr length] - [year length] - [second length])];
}

+ (long long)getTimeNow
{
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    //[formatter setDateFormat:@"YYYY.MM.dd.hh.mm.ss"];
    //    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    date = [formatter stringFromDate:[NSDate date]];
    
    //    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    //    NSLog(@"%@", timeNow);
    
    long long temp = [date longLongValue];
    
    //    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    //    NSInteger date = (NSInteger)time;
    //     NSLog(@"%lld", temp);
    
    return temp;
}

- (long long)javaTime
{
    return [self timeIntervalSince1970] * 1000;
}
@end
