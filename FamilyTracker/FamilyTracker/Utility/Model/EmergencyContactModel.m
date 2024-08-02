//
//  EmergencyContact.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/14/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "EmergencyContactModel.h"

@implementation EmergencyContactModel

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc]
            initWithDictionary:@{@"user_id" : @"identifier",
                                @"id" : @"contactId",
                                @"contact" : @"contactArray",
                                @"contact_name" : @"contactName",
                                @"contact_pic" : @"contactImage",
                                 @"list_order" : @"listOrder"}];
}

@end
