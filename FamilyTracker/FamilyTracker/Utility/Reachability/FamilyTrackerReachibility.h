//
//  SAReachibility.h
//  ReportForResults
//
//  Created by makboney on 1/17/15.
//  Copyright (c) 2015 SurroundApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface FamilyTrackerReachibility : NSObject
@property (strong, nonatomic) Reachability *reachability;

+ (FamilyTrackerReachibility *)sharedManager;

+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
