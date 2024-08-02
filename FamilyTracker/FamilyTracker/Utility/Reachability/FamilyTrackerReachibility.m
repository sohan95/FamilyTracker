//
//  SAReachibility.m
//  ReportForResults
//
//  Created by makboney on 1/17/15.
//  Copyright (c) 2015 SurroundApps. All rights reserved.
//

#import "FamilyTrackerReachibility.h"

@implementation FamilyTrackerReachibility
+ (FamilyTrackerReachibility *)sharedManager{

    static FamilyTrackerReachibility *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable {
    return [[[FamilyTrackerReachibility sharedManager] reachability] isReachable];
}

+ (BOOL)isUnreachable {
    return ![[[FamilyTrackerReachibility sharedManager] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[[FamilyTrackerReachibility sharedManager] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[[FamilyTrackerReachibility sharedManager] reachability] isReachableViaWiFi];
}

#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        self.reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        
        // Start Monitoring
        [self.reachability startNotifier];
    }
    
    return self;
}
@end
