//
//  MemberBoundary.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "MemberBoundary.h"

@implementation MemberBoundary

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"user_id" : @"identifier",
                                                       @"guardian_id" : @"guardianId",
                                                       @"boundary" : @"boundaryArray"
                                                       }];
}


@end
