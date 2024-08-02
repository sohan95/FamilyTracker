//
//  Members.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "Members.h"

@implementation Members

- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<MemberData> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"resultset":@"rows"}];
}

@end
