//
//  UserDevices.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/28/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"
#import "DeviceStatus.h"

@protocol UserDevices
@end

@interface UserDevices : JSONModel<Dto>

@property (nonatomic, strong) NSMutableArray<DeviceStatus,Optional> *rows;

@end
