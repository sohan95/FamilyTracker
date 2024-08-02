//
//  BatteryStatManager.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatteryStatManager : NSObject

+ (BatteryStatManager *)sharedInstance;

@property (nonatomic, assign) int batterylevel;
@property (nonatomic, assign) UIDeviceBatteryState batteryState;
@property (nonatomic, assign) int isCharging;
@property (nonatomic, assign) BOOL isSendBatteryLowAlert;

- (void)saveDeviceUseagesService;
- (void)getDeviceUseageService;
- (void)sendBatteryLowAlertService;

@end
