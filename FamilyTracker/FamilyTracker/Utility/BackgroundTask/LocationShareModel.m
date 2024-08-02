//
//  LocationShareModel.m
//  Location
//
//  Created by Qaium Hossain on 4/27/15.
//  Copyright (c) 2015 Cisco Systems Confidential - SPG. All rights reserved.
//

#import "LocationShareModel.h"

@implementation LocationShareModel

//Class method to make sure the share model is synch across the app
+ (id)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}


@end
