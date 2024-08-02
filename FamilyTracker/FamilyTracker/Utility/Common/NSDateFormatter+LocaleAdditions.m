//
//  NSDateFormatter+LocaleAdditions.m
//  TestCoverageReport
//
//  Created by BJIT Ltd on 10/20/14.
//  Copyright (c) 2014 BJIT Ltd. All rights reserved.
//

#import "FamilyTrackerDefine.h"
#import "NSDateFormatter+LocaleAdditions.h"

@implementation NSDateFormatter (LocaleAdditions)

- (id)initWithLocalUTCFormate {
    static NSLocale* en_US_POSIX = nil;
    self = [self init];
    if (en_US_POSIX == nil) {
        en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [self setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [self setLocale:en_US_POSIX];
    [self setDateFormat:kDateFormate];
    en_US_POSIX = nil;
    return self;
}

- (NSString *)relativeDateStringForDate:(NSTimeInterval)interval
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSCalendarUnit units = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        if (components.hour > 1) {
            return [NSString stringWithFormat:@"%ld hours ago", (long)components.hour];
        }else{
            if (components.minute>1) {
                return [NSString stringWithFormat:@"%ld minutes ago", (long)components.minute];
            }else{
                return [NSString stringWithFormat:@"%ld seconds ago", (long)components.second];
            }
            
        }
        
    }
}

@end
