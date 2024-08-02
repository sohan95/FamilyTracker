//
//  Boundary.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "Boundary.h"

@implementation Boundary

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                        @"boundary" : @"subBoundaryArray"
                                                       }];
}

@end
