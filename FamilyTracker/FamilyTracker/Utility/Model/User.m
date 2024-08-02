//
//  User.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "User.h"

@implementation User

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"date_of_birth" : @"dob",
                                                       @"first_name" : @"firstName",
                                                       @"guardian_id" : @"guardianId",
                                                       @"id" : @"identifier",
                                                       @"last_name" : @"lastName",
                                                       @"user_name" : @"userName",
                                                       @"is_active":@"isActive",
                                                       @"is_location_hide":@"isLocationHide",
                                                       @"payment_status":@"paymentStatus",
                                                       @"profile_pic" : @"profilePicture",
                                                       @"ejabbered" : @"chatSetting",
                                                       @"is_trialperiod" : @"isTrialperiod",
                                                       @"guarduian_settings" : @"guarduianSettings",
                                                       @"user_settings" : @"userSettings",
                                                       @"trial_period_start" : @"trialPeriodStart",
                                                       @"boundary" : @"boundaryArray"
                                                       }];
}
@end
