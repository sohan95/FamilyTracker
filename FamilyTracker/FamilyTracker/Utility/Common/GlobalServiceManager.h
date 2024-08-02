//
//  GlobalServiceManager.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/27/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"
#import "ModelManager.h"
#import "ServiceHandler.h"

@interface GlobalServiceManager : NSObject {
    UIStoryboard *sb;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    NSDictionary *requestBodyDic;
    Reachability* reachability;
    int internetConnectionStatus;
}

+ (GlobalServiceManager *)sharedInstance;

- (void)acknowledgeNewAlertService;
- (void)acknowledgedReadAlertService:(NSString *)notificationId;
- (void)gotoChatViewController;
- (void)gotoPlayAudioStream:(NSString *)urlStr andId:(NSString *)alertId;
- (void)gotoPlayVideoStream:(NSString *)urlStr;
- (void)stopStreamingService;
- (void)sendOffLineMessage;
- (void)autoLoginPreLoading;
- (void)synEmergencyContact;
- (void)synchronizedOffLineToOnLine;
- (void)syncOfflineData;
- (void)deviceRegistrationForPushNotification;
- (void)lazyImageLoderForProfileImage;
- (void)startNonePanicAlert;
- (void)stopListeningalertService:(NSString *)notificationId;



@end
