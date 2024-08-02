//
//  LocationTracker.m
//  Location
//
//  Created by Qaium Hossain on 4/27/15.
//  Copyright (c) 2015 Cisco Systems Confidential - SPG. All rights reserved.
//

#import "LocationTracker.h"
#import "AppDelegate.h"
#import "Common.h"
#import "FamilyTrackerDefine.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "FamilyTrackerReachibility.h"
#import "DbHelper.h"
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        _modelManager = [ModelManager sharedInstance];
        [self initService];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
	}
	return self;
}

- (void)applicationEnterBackground {
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates {
    NSLog(@"restartLocationUpdates");
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");

	if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        [Common displayToast:LOCATION_SERVICE_DISABLE_TEXT title:LOCATION_SERVICE_DISABLE_TITLE];
		
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
              [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
	}
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        CLLocationDistance theAltitude = newLocation.altitude;
        
        /*NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }*/
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;
            self.myLastLocationAltitude = theAltitude;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:kLocationLatitude];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:kLocationLongitude];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:kLocationAccuracy];
            [dict setObject:[NSNumber numberWithFloat:theAltitude] forKey:kLocationAltitude];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
            self.shareModel.myLocation = self.myLastLocation;
        }
    }
    
    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                    userInfo:nil
                                                     repeats:NO];
    [self performSelectorInBackground:@selector(updateLocationToServer) withObject:nil];

}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds {
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
//    NSLog(@"locationManager stop Updating after 10 seconds");
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
            [Common displayToast:CHECK_NETWORK_CONNECTION_TEXT title:CHECK_NETWORK_CONNECTION_TITLE];
            break;
        case kCLErrorDenied:
            [Common displayToast:LOCATION_SERVICE_ENABLE_TEXT title:LOCATION_SERVICE_ENABLE_TITLE];
            break;
        default:
            break;
    }
}

#pragma mark - Service Call -

-(void)initService {
    _handler = [[ReplyHandler alloc]
                                   initWithModelManager:_modelManager
                                   operator:nil
                                   progress:nil
                                   signupUpdate:nil
                                   addMemberUpdate:nil
                                   updateUserUpdate:nil
                                   settingsUpdate:nil
                                   loginUpdate:nil
                                   trackAppDayNightModeUpdate:(id)self
                                   saveLocationUpdate:(id)self
                                   getLocationUpdate:nil
                                   getLocationHistoryUpdate:nil
                                   saveAlertUpdate:nil
                                   getAlertUpdate:nil
                                   andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];

}

////GET NewAlerts---//
- (void)getAlertsService {
    if (_modelManager.user && _modelManager.user.sessionToken && _modelManager.user.identifier) {
        NSString *guardianId = @"";
        if([_modelManager.user.role integerValue] == 1) {
            guardianId = _modelManager.user.identifier;
        }else {
            guardianId = _modelManager.user.guardianId;
        }

        NSDictionary *requestHeader = @{kFamily_id_key:guardianId,
                                        kUser_id_key:_modelManager.user.identifier,
                                        kTokenKey:_modelManager.user.sessionToken};
        
        NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_NEW_ALERTS],
                           WHEN_KEY:[NSDate date],
                           OBJ_KEY:requestHeader
                           };
        [_serviceHandler onOperate:requestBodyDic];
    }
}

- (void)updateDeviceStatus {
    if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    //--- Battery charge percentage---//
    int percentage = (int)([[UIDevice currentDevice] batteryLevel]*100);
    NSLog(@"battery : %d percent", percentage);
    
    //---Battery Charging State---//
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnknown) {
        NSLog(@"Device is charging unknown.");
        [Common displayToast:@"charging unknown" title:@"Battery"];
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {// on battery, discharging
        NSLog(@"Device is charging unplugged.");
        [Common displayToast:@"charging unplugged" title:@"Battery"];
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging) {// plugged in, less than 100%
        NSLog(@"Device is charging.");
        [Common displayToast:@"charging" title:@"Battery"];
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {// plugged in, at 100%
        NSLog(@"Device is charge Full.");
    }
}

//Send the location to Server
- (void)updateLocationToServer {
//    if (!deviceStatusTimer) {
//        deviceStatusTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(updateDeviceStatus) userInfo:nil repeats:YES];
//    }
    
//    [self updateDeviceStatus];
    // Find the best location from the array based on accuracy
    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        if(i==0)
            myBestLocation = currentLocation;
        else{
            if([[currentLocation objectForKey:kLocationAccuracy]floatValue]<=[[myBestLocation objectForKey:kLocationAccuracy]floatValue]){
                myBestLocation = currentLocation;
            }
        }
    }
//    NSLog(@"My Best location:%@",myBestLocation);
    
    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
    if(self.shareModel.myLocationArray.count == 0) {
        NSLog(@"Unable to get location, use the last known location");

        self.myLocation=self.myLastLocation;
        self.myLocationAccuracy=self.myLastLocationAccuracy;
        self.myLocationAltitude = self.myLastLocationAltitude;
        
    } else {
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude = [[myBestLocation objectForKey:kLocationLatitude]floatValue];
        theBestLocation.longitude = [[myBestLocation objectForKey:kLocationLongitude]floatValue];
        self.myLocation=theBestLocation;
        self.myLocationAccuracy = [[myBestLocation objectForKey:kLocationAccuracy]floatValue];
        self.myLocationAltitude = [[myBestLocation objectForKey:kLocationAltitude]floatValue];
    }

    [GlobalData sharedInstance].userLocation.latitude = _myLocation.latitude;
    [GlobalData sharedInstance].userLocation.latitude = _myLocation.longitude;
    
    if (_modelManager.user.userName && _modelManager.user.sessionToken.length>1) {
        NSString *userId = _modelManager.user.userName;
        NSString *username = @"";

        if (_modelManager.user.lastName == nil ||
            _modelManager.user.lastName.length < 1) {
            username = [NSString stringWithFormat:@"%@",_modelManager.user.firstName];

        }else {
            username = [NSString stringWithFormat:@"%@ %@",_modelManager.user.firstName,_modelManager.user.lastName];
        }

        username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        long long timeStampInt = [@(floor([[NSDate date] timeIntervalSince1970] * 1000))longLongValue];
        // NSTimeInterval is defined as double
        NSNumber *timeStampObj = [NSNumber numberWithLongLong:timeStampInt];

        // working
        if([FamilyTrackerReachibility isUnreachable]) {
            NSMutableDictionary * locationData = [[NSMutableDictionary alloc] init];
            if(_myOffLineLastLocation.longitude == 0 && _myOffLineLastLocation.latitude == 0) {
                [locationData setValue:[NSString stringWithFormat:@"%f",self.myLocation.latitude] forKey:k_Db_Latitude];
                [locationData setValue:[NSString stringWithFormat:@"%f",self.myLocation.longitude] forKey:k_Db_Longitude];
                [locationData setValue:[timeStampObj stringValue] forKey:K_Db_timeStamp];
                if(self.myLocation.latitude != 0.0 && self.myLocation.longitude != 0.0) {
                    [[DbHelper sharedInstance] insertPostLocation:locationData];
                }
                _myOffLineLastLocation = self.myLocation;
            } else {
                CLLocation *location1 = [[CLLocation alloc] initWithLatitude:self.myLocation.latitude longitude:self.myLocation.longitude];
                CLLocation *location2 = [[CLLocation alloc] initWithLatitude:_myOffLineLastLocation.latitude longitude:_myOffLineLastLocation.longitude];
                float distance = fabs([location1 distanceFromLocation:location2]);
                if(distance >= 5.0f) {
                    [locationData setValue:[NSString stringWithFormat:@"%f",self.myLocation.latitude] forKey:k_Db_Latitude];
                    [locationData setValue:[NSString stringWithFormat:@"%f",self.myLocation.longitude] forKey:k_Db_Longitude];
                    [locationData setValue:[timeStampObj stringValue] forKey:K_Db_timeStamp];
                    if(self.myLocation.latitude != 0.0 && self.myLocation.longitude != 0.0) {
                        [[DbHelper sharedInstance] insertPostLocation:locationData];
                    }
                    _myOffLineLastLocation = self.myLocation;
//                    NSMutableArray * locations = [[NSMutableArray alloc] init];
//                    locations = [[DbHelper sharedInstance] getLocations:@""];
//                    NSLog(@"%lu",(unsigned long)locations.count);
                }
            }
            
        } else {
            /*-- check user movie 50 meters. if move 50 meters than location post --*/
            if(_myOffLineLastLocation.longitude == 0 && _myOffLineLastLocation.latitude == 0) {
                _myOffLineLastLocation = self.myLocation;
            } else {
                CLLocation *location1 = [[CLLocation alloc] initWithLatitude:self.myLocation.latitude longitude:self.myLocation.longitude];
                CLLocation *location2 = [[CLLocation alloc] initWithLatitude:_myOffLineLastLocation.latitude longitude:_myOffLineLastLocation.longitude];
                float distance = fabs([location1 distanceFromLocation:location2]);
                if(distance >= 5.0f) {
                    _myOffLineLastLocation = self.myLocation;
                } else {
                    return;
                }
            }
//            _myOffLineLastLocation = self.myLocation;
            NSDictionary *locationDict = @{@"name":@"user", @"type":@"geolocation",@"datapoints":@[@[timeStampObj, @{@"latitude":[NSNumber numberWithDouble:self.myLocation.latitude],@"longitude":[NSNumber numberWithDouble:self.myLocation.longitude]}]], @"tags":@{@"id":userId, @"name":username}};
            
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInt:POST_LOCATION_DATA],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:locationDict
                                     };
            
            [_serviceHandler onOperate:newMsg];
        }
    }
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc] init];
}

#pragma mark- Callback Method
- (void)refreshUI:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (sourceType == POST_LOCATION_DATA_FAILED) {
            //[Common displayToast:@"Location posting failed" title:nil duration:1.0];
        }else if (sourceType == POST_LOCATION_DATA_SUCCEEDED) {
            
        }else if (sourceType == GET_NEW_ALERTS_SUCCEEDED) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AlertBatchNotification"
             object:nil];
        }else if (sourceType == GET_NEW_ALERTS_FAILED) {
           
        }
    });
}

@end
