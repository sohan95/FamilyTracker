//
//  ReplyHandler.h
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelManager.h"
#import "TableUpdater.h"
#import "Operator.h"
#import "Progress.h"
#import "LoginUpdater.h"
#import "SignupUpdater.h"
#import "DataUpdater.h"

@interface ReplyHandler : NSObject

- (instancetype)initWithModelManager:(ModelManager *)modelManager operator:
(id<Operator>)oprtr progress:
(id<Progress>)prgrss signupUpdate:
(id<SignupUpdater>)signupUpdater addMemberUpdate:
(id<SignupUpdater>)addMemberUpdater updateUserUpdate:
(id<DataUpdater>)updateUserUpdater settingsUpdate:
(id<SignupUpdater>)settingsUpdater loginUpdate:
(id<SignupUpdater>)loginUpdater trackAppDayNightModeUpdate:
(id<TableUpdater>)trackAppDayNightModeUpdater saveLocationUpdate:
(id<TableUpdater>)saveLocationUpdater getLocationUpdate:
(id<TableUpdater>)getLocationUpdater getLocationHistoryUpdate:
(id<TableUpdater>)getLocationHistoryUpdater saveAlertUpdate:
(id<TableUpdater>)saveAlertUpdater getAlertUpdate:
(id<TableUpdater>)getAlertUpdater andTarget:
(id)target;

- (void)handleMessage:(id)msg;

@end
