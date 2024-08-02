//
//  Notifications.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "Notifications.h"
#import "FamilyTrackerDefine.h"


@implementation Notifications
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<Notification> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"resultset":@"rows"}];
    //kNextPage_key:@"nextPageForAlert"
}
@end
