//
//  ModelManager.m
//  ModelManager
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ModelManager.h"
#import "ChatManager.h"
#import "FamilyTrackerDefine.h"
#import "AppDelegate.h"
#import "DbHelper.h"

static ModelManager *instance = nil;


@implementation ModelManager

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

+ (ModelManager *)sharedInstance {
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

- (void)logOut {
    _user = nil;
    _currentVCName = @"";
    _settings = nil;
    _notifications = nil;
    _members = nil;
    _memberLocations = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTOLOGIN_BODY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTOLOGIN_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_OFFLINE_IMAGE_CHANGE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:OFFLINE_IMAGE_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:OFFLINE_IMAGE_64_STRING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BOUNDARY_TOUCH_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDrawBoundaryTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ChatManager instance] leaveRoom];
    
    [self reset];
    
    // add murtuza
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_OFFLINE_MESSAGE_STORE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_UPDATED_CONTACTLIST];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_OFFLINE_CONTACT_STORE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // retet Db
    [[DbHelper sharedInstance] resetAllTable];
}

- (void)reset {
    _members = [Members new];
    _memberLocations = [MemberLocations new];
    _notifications = [Notifications new];
    _settings = [Settings new];
    _deviceStatusArray = [[NSMutableArray<DeviceStatus> alloc] init];
    _currentVCName = [[NSString alloc] init];
    _totalNewAlerts = [[NSNumber alloc] init];
    _nextPageForAlert = [[NSString alloc] init];
    _liveStreamingAlert = [[Notification alloc] init];
    _emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.trialExpiredTimer) {
        [delegate.trialExpiredTimer invalidate];
        delegate.trialExpiredTimer = nil;
    }
    _runningPanics = [[NSMutableArray<PanicAlertStatus> alloc] init];
}

@end
