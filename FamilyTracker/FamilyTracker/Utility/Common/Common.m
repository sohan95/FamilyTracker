//
//  Common.m
//  OnTheMove
//
//  Created by Zeeshan Khan on 8/23/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "Common.h"
#import "MemberData.h"
#import "ModelManager.h"
@implementation Common

+(void)displayToast:(NSString *)message title:(NSString*)title duration:(NSInteger)value{
    
    UIAlertController * toast = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:NSLocalizedString(message, nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:toast animated:YES completion:^{
    }];
    
    NSInteger duration = value;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{[toast dismissViewControllerAnimated:YES completion:nil];});
}

+(void)displayToast:(NSString *)message title:(NSString*)title{
    
    UIAlertController * toast = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:NSLocalizedString(message, nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:toast animated:YES completion:^{
    }];
    
    int duration = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^{[toast dismissViewControllerAnimated:YES completion:nil];});
}

+ (NSString *)getEpochTimeFromServerTime:(NSString*)dateStr {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSX"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
//    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
//    date = [date
    //NSTimeInterval nowEpochSeconds = [date timeIntervalSince1970];
    NSTimeInterval nowEpochSeconds =  [@(floor([date timeIntervalSince1970] * 1000)) longLongValue];
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:nowEpochSeconds];
    NSString *epochTimeStr = [myDoubleNumber stringValue];
    return epochTimeStr;
}

+ (NSString *)getEpochTimeFromDate:(NSDate*)date {
    NSTimeInterval nowEpochSeconds =  [@(floor([date timeIntervalSince1970] * 1000)) longLongValue];
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:nowEpochSeconds];
    NSString *epochTimeStr = [myDoubleNumber stringValue];
    return epochTimeStr;
}

+ (NSString*)getStringFromEpochTime:(NSString *)epochTime {
    //NSString *epochTime = @"1352716800";
    // (Step 1) Convert epoch time to SECONDS since 1970
    NSTimeInterval seconds = [epochTime doubleValue];
    //NSLog (@"Epoch time %@ equates to %qi seconds since 1970", epochTime, (long long) seconds);
    // (Step 2) Create NSDate object
    //NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    NSDate *epochNSDate = [NSDate dateWithTimeIntervalSince1970:(seconds / 1000)];
    //NSLog (@"Epoch time %@ equates to UTC %@", epochTime, epochNSDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:epochNSDate];
    return formattedDate;
}

+ (BOOL)isNullObject:(id)object {
    if(object == nil || [object isEqual:(id)[NSNull null]] || [(NSString*)object isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}

+ (NSString*)getUserName:(NSString*)userId {
    for (MemberData *member in  [ModelManager sharedInstance].members.rows) { //_modelManager.members.rows
        if ([member.identifier isEqualToString:userId]) {
            return member.userName;
        }
    }
    return @"";
}

@end
