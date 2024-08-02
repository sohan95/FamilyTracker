//
//  LocationModel.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/27/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel

- (instancetype)initWithLatitude:(double)lat longitude:(double)lng {
    self = [super init];
    if (self) {
        self.latitude = lat;
        self.longitude = lng;
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"lat" : @"latitude",
                                                       @"lng" : @"longitude"
                                                       }];
}

@end
