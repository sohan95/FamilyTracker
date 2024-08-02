//
//  DeviceStatus.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "DeviceStatus.h"

@implementation DeviceStatus

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"guardian_id" : @"guardianId",
                                                       @"user_id" : @"userId",
                                                       @"battery_percent" : @"batteryPercent",
                                                       @"created_time" : @"createdTime",
                                                       @"is_battery_charging" : @"isBatteryCharging",
                                                       }];
}

@end
