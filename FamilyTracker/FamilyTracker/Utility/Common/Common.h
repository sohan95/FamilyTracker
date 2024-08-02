//
//  Common.h
//  OnTheMove
//
//  Created by Zeeshan Khan on 8/23/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FamilyTrackerDefine.h"

@interface Common : NSObject

+(void)displayToast:(NSString *)message title:(NSString*)title duration:(NSInteger)value;
+(void)displayToast:(NSString *)message title:(NSString*)title;

+ (NSString *)getEpochTimeFromServerTime:(NSString*)dateStr;
+ (NSString *)getEpochTimeFromDate:(NSDate*)date;
+ (NSString*)getStringFromEpochTime:(NSString *)epochTime;
+ (BOOL)isNullObject:(id)object;
+ (NSString*)getUserName:(NSString*)userId;

@end
