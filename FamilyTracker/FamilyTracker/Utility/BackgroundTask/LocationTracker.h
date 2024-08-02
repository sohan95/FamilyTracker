//
//  LocationTracker.h
//  Location
//
//  Created by Qaium Hossain on 4/27/15.
//  Copyright (c) 2015 Cisco Systems Confidential - SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"
#import "FamilyTrackerOperate.h"
#import "ModelManager.h"
#import "ReplyHandler.h"

@class AppDelegate;
@class ServiceHandler;

@interface LocationTracker : NSObject <CLLocationManagerDelegate>
{
    AppDelegate *delegate;
    ServiceHandler *_serviceHandler;
    ModelManager *_modelManager;
    ReplyHandler * _handler;
}

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;
@property (nonatomic) CLLocationDistance myLastLocationAltitude;
@property (nonatomic) CLLocationCoordinate2D myOffLineLastLocation;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) CLLocationDistance myLocationAltitude;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;
- (void)getAlertsService;


@end
