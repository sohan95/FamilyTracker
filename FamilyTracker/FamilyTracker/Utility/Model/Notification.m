//
//  Notification.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/19/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "Notification.h"

@implementation Notification


//- (instancetype)init {
//    if (self = [super init]) {
////        _messageTitle = [[LanguageModel alloc] init];
////        _location = [[LocationModel alloc] init];
//    }
//    return self;
//}


+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                        @"alert_type":@"alertType",
                                                        @"created_time":@"createdTime",
                                                        @"created_user": @"createdUser",
                                                        @"id": @"identifier",
                                                        @"is_seen": @"isSeen",
                                                        @"link": @"link",
                                                        @"massage_body": @"messageBody",
                                                        @"message_title": @"messageTitle",
                                                        @"user_id": @"userId",
                                                        @"family_id": @"familyId",
                                                        @"resource_type":@"resourceType",
                                                        @"ref_id":@"referenceId"
                                                       }];
}


@end
