//
//  ChatModel.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "ChatModel.h"

@implementation ChatModel

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"room" : @"roomName",
                                                       @"host" : @"hostName",
                                                       @"ip" : @"ipAddress"
                                                       }];
}
@end
