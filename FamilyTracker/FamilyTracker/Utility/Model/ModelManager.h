//
//  ModelManager.h
//  ModelManager
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Dto.h"
#import "MemberData.h"
#import "MemberLocation.h"
#import "SettingModel.h"
#import "Notification.h"
#import "LocationHistory.h"
//#import "GlobalData.h"
#import "EmergencyContactModel.h"
#import "Members.h"
#import "MemberLocations.h"
#import "Notifications.h"
#import "Settings.h"
#import "PanicAlertStatus.h"
#import "UserDevices.h"

@interface ModelManager : JSONModel<Dto>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Members *members;
@property (nonatomic, strong) MemberLocations *memberLocations;
@property (nonatomic, strong) Notifications *notifications;
@property (nonatomic, strong) Settings *settings;
//@property (nonatomic, strong) UserDevices *userDevices;
@property (nonatomic, strong) NSMutableArray<DeviceStatus> *deviceStatusArray;

@property (nonatomic, strong) NSString *currentVCName;
@property (nonatomic, strong) NSNumber *totalNewAlerts;
@property (nonatomic, strong) NSString *nextPageForAlert;
@property (nonatomic, strong) Notification *liveStreamingAlert;
@property (nonatomic, strong) NSString * defaultLanguage;
@property (nonatomic, strong) NSMutableArray<EmergencyContactModel> *emergencyContacts;
@property (nonatomic, strong) NSString * firebaseToken;
@property (nonatomic) BOOL isSilentAudioStreamRunning;
@property (nonatomic, nonnull) NSString *silentAudioStreamingIdentifier;
@property (nonatomic, nonnull) NSString *silentAudioStreamingFamilyId;
@property (nonatomic, nonnull) NSString *silentAudioStreamingCreatedUser;
@property (nonatomic) BOOL isPanicRunning;
@property (nonatomic) BOOL isPanicStop;

@property (nonatomic, strong) NSString *currentPanicText;
@property (nonatomic, readwrite) NSMutableArray<PanicAlertStatus> *runningPanics;

+ (ModelManager *)sharedInstance;
- (void)logOut;
- (void)reset;

@end
