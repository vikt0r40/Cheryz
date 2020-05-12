//
//  NSDate+Server.m
//  Cheryz-iOS
//
//  Created by Viktor Todorov on 12/21/16.
//  Copyright © 2016 Viktor. All rights reserved.
//

#import "NSDate+Server.h"

@implementation NSDate (Server)
-(double)serverDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[self dateWithZeroSeconds:self]];
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    
    return [newDate timeIntervalSince1970]*1000;
}
+(NSDate*)dateFromServerFormat:(double)date {
    if(date==0) return nil;
    NSDate* aDate = [NSDate dateWithTimeIntervalSince1970:date/1000.];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setCalendar:[NSCalendar currentCalendar]];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:aDate];
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    
    return newDate;

}
- (NSDate *)dateWithZeroSeconds:(NSDate *)date
{
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}
-(double)serverDateMorning {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *morningStart = [calendar dateFromComponents:components];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:morningStart];
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    
    return [newDate timeIntervalSince1970]*1000;
}
-(double)serverDateNight {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *nightEnd = [calendar dateFromComponents:components];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:nightEnd];
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    
    return [newDate timeIntervalSince1970]*1000;
}
@end
