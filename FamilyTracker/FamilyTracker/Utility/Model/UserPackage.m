//
//  UserPackage.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/21/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "UserPackage.h"

@implementation UserPackage

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id" : @"Id"
                                                       }];
}

@end
