//
//  NSDateFormatter+LocaleAdditions.h
//  TestCoverageReport
//
//  Created by BJIT Ltd on 10/20/14.
//  Copyright (c) 2014 BJIT Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSDateFormatter (LocaleAdditions)
//define local calendar
- (id)initWithLocalUTCFormate;

- (NSString *)relativeDateStringForDate:(NSTimeInterval)interval;

@end
