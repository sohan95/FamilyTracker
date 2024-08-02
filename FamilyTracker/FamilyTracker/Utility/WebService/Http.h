//
//  Http.h
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

typedef void (^FTBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^FTArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^FTObjectResultBlock)(id object, NSError *error);

#import <Foundation/Foundation.h>
#import "Progress.h"
#import "ModelManager.h"
#import "FamilyTrackerReachibility.h"
#import "AppDelegate.h"

@interface Http : NSObject {
    AppDelegate *delegate;
    
}

@property (nonatomic, retain) NSURLSessionConfiguration *defaultConfiguration;
@property (nonatomic, retain) NSURLSession *defaultSession;

- (instancetype)initWithProgress:(id<Progress>)progress;
- (void)doSignupWithUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)authenticateUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)signOutUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)forceSignOutUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)postLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)receiveLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;

//---new services---//
- (void)getAlertWithPaging:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)saveAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)stopStreaming:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getAllMembersByGuardianId:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getMemberById:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getSettings:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)acknowledgeNewAlerts:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)acknowledgeReadAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
//
- (void)upLoadUserPicture:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)upLoadMultimedia:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)postLocationHideByMember:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)addEmergencyContact:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)smsActivateCodeVerify:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getEmergency:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)removeEmergencyContact:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)changePassword:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)resetPassword:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)activeInactiveMember:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;

- (void)addMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)deleteMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)updateMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)deviceregistration:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)addUserWatch:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)inActiveUserWatch:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block;
- (void)resendActionCode:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)stopListeningAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getAllPackages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)saveDeviceUseages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;
- (void)getDeviceUsages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block;

@end
