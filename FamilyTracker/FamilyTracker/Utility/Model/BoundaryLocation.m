//
//  BoundaryLocation.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "BoundaryLocation.h"

@implementation BoundaryLocation

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"long" : @"log"
                                                       }];
}

@end
