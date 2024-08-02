//
//  MemberData.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/24/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "MemberData.h"

@implementation MemberData

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"guardian_id" : @"guardianId",
                                                       @"id" : @"identifier",
                                                       @"user_name" : @"userName",
                                                       @"contact" : @"contact",
                                                       @"email" : @"email",
                                                       @"first_name" : @"firstName",
                                                       @"last_name" : @"lastName",
                                                       @"is_location_hide" : @"isLocationHide",
                                                       @"settings" : @"settings",
                                                       @"payment_status" : @"paymentStatus",
                                                       @"trial_period_start" : @"trialPeriodStart",
                                                       @"user_settings" : @"userSettings",
                                                       @"guarduian_settings" : @"guardianSettings",
                                                       @"is_active":@"isActive"
                                                       }];
}

@end

