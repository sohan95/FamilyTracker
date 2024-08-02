//
//  BatteryStatManager.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "BatteryStatManager.h"
#import "Common.h"
#import "GlobalServiceManager.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "BatteryStatusViewController.h"

@implementation BatteryStatManager {
    NSTimer *deviceStatusTimer;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}

static BatteryStatManager *instance = nil;
- (instancetype)init {
    if (self = [super init]) {
        _batterylevel = 0;
        _isSendBatteryLowAlert = NO;
        _modelManager = [ModelManager sharedInstance];
        [self initService];
        
        // Register for battery level and state change notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryStateChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification object:nil];
        
        if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
            [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        }
        
        if (!deviceStatusTimer) {
            deviceStatusTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateDeviceLabelStatus) userInfo:nil repeats:YES];
        }
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateDeviceLabelStatus) userInfo:nil repeats:NO];
        
    }
    return self;
}

+ (BatteryStatManager *)sharedInstance {
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}


- (void)batteryLevelChanged:(NSNotification *)notification {
    [self updateBatteryLevel];
}

- (void)batteryStateChanged:(NSNotification *)notification {
    [self updateBatteryState];
}

- (void)updateBatteryLevel {
    _batterylevel = (int)[UIDevice currentDevice].batteryLevel*100;
//    NSString *str = [NSString stringWithFormat:@"BatteryL=%d",_batterylevel];
//    [Common displayToast:str title:nil duration:5];
    
    [self saveDeviceUseagesService];
    if (_batterylevel%2 == 0) {
        [self saveDeviceUseagesService];
    }
    //--- Battery charge percentage---//
    if (_batterylevel < 20) {
        if (!_isSendBatteryLowAlert) {
            // [[post battery min charge panic]]
            _isSendBatteryLowAlert = YES;
//            [self sendBatteryLowAlertService];
        }
    } else {
        _isSendBatteryLowAlert = NO;
    }
    
   
    NSLog(@"%d",_batterylevel);
}

- (void)updateBatteryState {
    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    _batteryState = currentState;
    switch (currentState) {
        case UIDeviceBatteryStateUnknown:
//            [Common displayToast:@"Unknown" title:nil];
            _isCharging = 0;
//            _batterylevel = (int)[UIDevice currentDevice].batteryLevel*100;
            [self saveDeviceUseagesService];
            break;
        case UIDeviceBatteryStateUnplugged:
//            [Common displayToast:@"Unplugged" title:nil];
            _isCharging = 0;
//            _batterylevel = (int)[UIDevice currentDevice].batteryLevel*100;
            [self saveDeviceUseagesService];
            break;
        case UIDeviceBatteryStateCharging:
//            [Common displayToast:@"Charging" title:nil];
            _isCharging = 1;
//            _batterylevel = (int)[UIDevice currentDevice].batteryLevel*100;
            [self saveDeviceUseagesService];
            break;
        case UIDeviceBatteryStateFull:
//            [Common displayToast:@"Full" title:nil];
            _isCharging = 1;
//            _batterylevel = (int)[UIDevice currentDevice].batteryLevel*100;
            [self saveDeviceUseagesService];
            break;
        default:
            break;
    }
}

- (void)updateDeviceLabelStatus {
    if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    //--- Battery charge percentage---//
    _batterylevel = (int)([[UIDevice currentDevice] batteryLevel]*100);
    NSLog(@"battery : %d percent", _batterylevel);
//    [self updateBatteryState];
    [self saveDeviceUseagesService];
    
    if (_batterylevel < 20) {
       // [[post battery min charge panic]]
        //[self sendBatteryLowAlertService];
    }
}

#pragma mark - User Defined Methods -
- (void)initService {
    //Initialize Service CallBack Handler
    ReplyHandler * _handler = [[ReplyHandler alloc]
                               initWithModelManager:_modelManager
                               operator:nil
                               progress:nil
                               signupUpdate:nil
                               addMemberUpdate:nil
                               updateUserUpdate:nil
                               settingsUpdate:nil
                               loginUpdate:nil
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:nil
                               getLocationUpdate:nil
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:(id)self
                               getAlertUpdate:(id)self
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}

- (void)saveDeviceUseagesService {
    if (![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    //--- Battery charge percentage---//
    _batterylevel = (int)([[UIDevice currentDevice] batteryLevel]*100);
    if (_modelManager.user.sessionToken.length > 0) {
        NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                      kGuardianId:_modelManager.user.guardianId,
                                      kUser_id_key:_modelManager.user.identifier,
                                      kBattery_percent:[NSNumber numberWithInt:_batterylevel],
                                      kIs_battery_charging:[NSNumber numberWithInt:_isCharging] //if false 0, if true 1, default 0
                                      };
        NSDictionary *requestBody1 = @{
                                       WHAT_KEY:[NSNumber numberWithInt:SAVE_DEVICE_USEAGES],
                                       WHEN_KEY:[NSDate date],
                                       OBJ_KEY:requestBody
                                       };
        [_serviceHandler onOperate:requestBody1];
    }
}

- (void)getDeviceUseageService {
    if (_modelManager.user.sessionToken.length > 0) {
        NSDictionary *requestBody = @{
                                      kTokenKey:_modelManager.user.sessionToken,
                                      kGuardianId:_modelManager.user.guardianId
                                      };
        NSDictionary *requestBody1 = @{
                                       WHAT_KEY:[NSNumber numberWithInt:GET_DEVICE_USEAGES],
                                       WHEN_KEY:[NSDate date],
                                       OBJ_KEY:requestBody
                                       };
        [_serviceHandler onOperate:requestBody1];
    }
}

- (void)sendBatteryLowAlertService {
    NSString *isSendSms = @"0";
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.userSettings];
    if([[settingDic valueForKey:@"1006"] isEqualToString:@"SMS"]) {
        isSendSms = @"1";
    }
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:_modelManager.user.guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  //kAlert_type:_alertType,
                                  kResourceTypeKey: kAlertResourceTypeAudio,
                                  kIsSendSMS: isSendSms,
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == SAVE_DEVICE_USEAGES_SUCCESSED) {
            if([[GlobalData sharedInstance].currentVC isKindOfClass:[BatteryStatusViewController class]]) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"BatteryNotification"
                 object:nil];
            }
        } else if(sourceType == SAVE_DEVICE_USEAGES_FAILED) {
            NSLog(@"save device usages failed");
        } else if(sourceType == GET_DEVICE_USEAGES_SUCCESSED) {
            NSLog(@"get device useages successed");
        } else if(sourceType == GET_DEVICE_USEAGES_FAILED) {
            NSLog(@"get device useages failed");
        } if(sourceType == SAVE_ALERT_SUCCEEDED) {//---post Battey Low Alerts
//            [Common displayToast:NSLocalizedString(@"Battery Low alert has been sent.", nil)  title:nil duration:1];
        } else if(sourceType == SAVE_ALERT_FAILED) {
//            [Common displayToast:NSLocalizedString(@"Battery Low alert failed to send!", nil)  title:nil duration:1];
        }
    });
}

@end
