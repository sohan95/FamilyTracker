//
//  DeviceStatus.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"

@protocol DeviceStatus
@end

@interface DeviceStatus : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> * guardianId;
@property (nonatomic, readwrite) NSString<Optional> * userId;
@property (nonatomic, readwrite) NSString<Optional> *batteryPercent;
@property (nonatomic, readwrite) NSString<Optional> * createdTime;
@property (nonatomic, readwrite) NSString<Optional> * isBatteryCharging;
@end
