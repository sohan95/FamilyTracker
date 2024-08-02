//
//  LocationShareModel.h
//  Location
//
//  Created by Qaium Hossain on 4/27/15.
//  Copyright (c) 2015 Cisco Systems Confidential - SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationShareModel : NSObject

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer * delay10Seconds;
@property (nonatomic) BackgroundTaskManager * bgTask;
@property (nonatomic) NSMutableArray *myLocationArray;
@property (nonatomic) CLLocationCoordinate2D myLocation;

+(id)sharedModel;

@end
