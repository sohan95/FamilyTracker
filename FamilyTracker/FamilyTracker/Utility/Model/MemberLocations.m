//
//  MemberLocations.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "MemberLocations.h"

@implementation MemberLocations
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<MemberLocation> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"resultset":@"rows"}];
}
@end
