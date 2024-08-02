//
//  ServiceHandler.m
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ServiceHandler.h"
#import "FamilyTrackerOperate.h"
#import "ReplyOperator.h"
#import "ServiceProgress.h"
#import "FamilyTrackerDefine.h"
#import "JsonUtil.h"
#import "MemberData.h"
#import "MemberLocation.h"
#import "SettingModel.h"
#import "GlobalData.h"
#import "LocationHistory.h"
#import "AppDelegate.h"
#import "GlobalServiceManager.h"
#import "AudioViewController.h"
#import "StreamVideoVC.h"

@implementation ServiceHandler {
    ReplyHandler *_handler;
}

static ReplyOperator *operator;

- (instancetype)initWithReplyHandler:(ReplyHandler *)handler {
    if (self = [super init]) {
        operator = [[ReplyOperator alloc] init];
        //_modelManager = [[ModelManager alloc] init];
        _modelManager = [ModelManager sharedInstance];
        _progress = [[ServiceProgress alloc] initWithOperator:operator];
        _http = [[Http alloc] initWithProgress:_progress];
        _handler = handler;
    }
    return self;
}

- (void)onOperate:(id)msg {
    [self handleMsg:msg];
}

- (void)handleMsg:(id)msg {
    NSUInteger op = [msg[WHAT_KEY] integerValue];
    if (op == LOGIN) {
        //TODO::do login and parop	NSUInteger	2901se user
        //dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [_http authenticateUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:SAVE_USER],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:LOGIN_SUCCESS],WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:LOGIN_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:LOGIN_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == SIGN_OUT) {
        //TODO::do login and parse user
        //dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [_http signOutUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SIGN_OUT_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SIGN_OUT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:SIGN_OUT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == FORCE_SIGNOUT) {
        //TODO::do login and parse user
        //dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [_http forceSignOutUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:FORCE_SIGNOUT_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:FORCE_SIGNOUT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:FORCE_SIGNOUT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == SIGNUP) {
        [_http doSignupWithUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP_SUCCESS],
                                          WHEN_KEY:[NSDate date]}];

            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:SIGNUP_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == RESET_PASSWORD) {
        [_http resetPassword:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:RESET_PASSWORD_SUCCESS],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:RESET_PASSWORD_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:RESET_PASSWORD_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == ADD_MEMBER) {
        [_http doSignupWithUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER_SUCCEEDED],
                                          WHEN_KEY:[NSDate date]}];

            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == UPDATE_MEMBER) {
        [_http doSignupWithUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_SUCCEEDED],
                                          WHEN_KEY:[NSDate date]}];

            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == UPDATE_MEMBER_DETAILS) { // UPDATE_MEMBER_DETAILS
        [_http doSignupWithUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_DETAILS_SUCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_DETAILS_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_DETAILS_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == UPDATE_SETTINGS) {
        [_http doSignupWithUser:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_SETTINGS_SUCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_SETTINGS_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_SETTINGS_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == ACTIVE_INACTIVE_MEMBER) {
        [_http activeInactiveMember:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVE_INACTIVE_MEMBER_SUCCESS],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVE_INACTIVE_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVE_INACTIVE_MEMBER_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == ADD_EMERGENCY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http addEmergencyContact:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_EMERGENCY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == GET_EMERGENCY) { // Get emergency
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getEmergency:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == GET_ALL_USER_PACKAGE) { // Get emergency
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getAllPackages:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALL_USER_PACKAGE_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALL_USER_PACKAGE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALL_USER_PACKAGE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == ADD_BOUNDARY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http addMapBoundary:dataDic completionBlock:^(id object, NSError *error){
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_BOUNDARY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == GET_BOUNDARY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getMapBoundary:dataDic completionBlock:^(id object, NSError *error){
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_BOUNDARY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == DELETE_BOUNDARY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http deleteMapBoundary:dataDic completionBlock:^(id object, NSError *error){
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:DELETE_BOUNDARY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:DELETE_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:DELETE_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == UPDATE_BOUNDARY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http updateMapBoundary:dataDic completionBlock:^(id object, NSError *error){
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_BOUNDARY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_BOUNDARY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == POST_LOCATION_DATA){
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http postLocationData:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:POST_LOCATION_DATA_FAILED],WHEN_KEY:[NSDate date]}];

            }else if(object == nil || object == (id)[NSNull null]){
               [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:POST_LOCATION_DATA_FAILED],WHEN_KEY:[NSDate date]}];

            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:POST_LOCATION_DATA_SUCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == GET_LOCATION_DATA){
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getLocationData:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_LOCATION_DATA_FAILED],WHEN_KEY:[NSDate date]}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_LOCATION_DATA_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                //--For saving data---//
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_LOCATION_DATA_SAVE],WHEN_KEY:[NSDate date],OBJ_KEY:object};
                [self onOperate:newMsg];
                
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_LOCATION_DATA_SUCCEEDED],WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == GET_All_MEMBERS) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getAllMembersByGuardianId:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_FAILED],WHEN_KEY:[NSDate date]}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                //--For saving data---//
                //NSArray *memberData = [object valueForKey:kResultsetKey];
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_SUCCEEDED],WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == GET_All_MEMBERS_AFTER_NEW_MEMBER) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getAllMembersByGuardianId:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                //[_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_AFTER_NEW_MEMBER_FAILED],WHEN_KEY:[NSDate date]}];
            }else if(object == nil || object == (id)[NSNull null]){
                //[_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                //--For saving data---//
//                NSArray *memberData = [object valueForKey:kResultsetKey];
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_All_MEMBERS_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
            }
        }];
    }else if (op == CHANGE_PASSWORD) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http changePassword:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:CHANGE_PASSWORD_SUCCESS],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:CHANGE_PASSWORD_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:CHANGE_PASSWORD_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == GET_MEMBER_BY_ID) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getMemberById:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID_SUCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == GET_ALERTS) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getAlertWithPaging:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                //--For saving data---//
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_ALERTS_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_ALERTS_SUCCEEDED],WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == GET_NEW_ALERTS) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getAlertWithPaging:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_NEW_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_NEW_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_NEW_ALERTS_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_NEW_ALERTS_SUCCEEDED],WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == SAVE_ALERT){
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http saveAlert:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_ALERT_SUCCEEDED],
                                            WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == STOP_STREAMING) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http stopStreaming:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_STREAMING_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_STREAMING_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_STREAMING_SUCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == STOP_LISTENING_ALERT) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http stopListeningAlert:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_LISTENING_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_LISTENING_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:STOP_LISTENING_ALERT_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }
    
    else if (op == GET_SETTINGS) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getSettings:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_SETTINGS_FAILED],WHEN_KEY:[NSDate date]}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_SETTINGS_FAILED],WHEN_KEY:[NSDate date]}];
            }else {
                //--For saving data---//
//                NSArray *memberData = [object valueForKey:kResultsetKey];
                //---To save in ModelData ---//
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_SETTINGS_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_SETTINGS_SUCCEEDED],WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == ACKNOWLEDGE_NEW_ALERTS) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http acknowledgeNewAlerts:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_NEW_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_NEW_ALERTS_FAILED],WHEN_KEY:[NSDate date]}];

            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == ACKNOWLEDGE_READ_ALERT) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http acknowledgeReadAlert:dataDic completionBlock:^(id object, NSError *error) {
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_READ_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date]}];

            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_READ_ALERT_FAILED],
                                          WHEN_KEY:[NSDate date]}];

            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACKNOWLEDGE_READ_ALERT_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
            }
        }];
    }else if (op == UPLOAD_USER_PICTURE) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http upLoadUserPicture:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_USER_PICTURE_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];

            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_USER_PICTURE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_USER_PICTURE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == LOCATION_HIDE) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http postLocationHideByMember:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:LOCATION_HIDE_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:LOCATION_HIDE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:LOCATION_HIDE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == ACTIVATE_CODE_VERIFY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http smsActivateCodeVerify:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
//                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_ACTIVATION_CODE_NOT_VERIFIED];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVATE_CODE_VERIFY_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVATE_CODE_VERIFY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ACTIVATE_CODE_VERIFY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == REMOVE_EMERGENCY) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http removeEmergencyContact:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:REMOVE_EMERGENCY_SUCCESS],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:REMOVE_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:REMOVE_EMERGENCY_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == DEVICE_REGISTRATION) {
        [_http deviceregistration:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:DEVICE_REGISTRATION_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:DEVICE_REGISTRATION_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:DEVICE_REGISTRATION_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }
    else if (op == ADD_USER_WATCH) {
        [_http addUserWatch:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_USER_WATCH_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:ADD_USER_WATCH_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:ADD_USER_WATCH_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }
    
    else if (op == INACTIVE_USER_WATCH) {
        [_http addUserWatch:msg[OBJ_KEY] andWithCompletionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:INACTIVE_USER_WATCH_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:INACTIVE_USER_WATCH_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:INACTIVE_USER_WATCH_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }
    else if (op == UPLOAD_MULTIMEDIA) {
        [_http upLoadMultimedia:msg[OBJ_KEY] completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_MULTIMEDIA_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_MULTIMEDIA_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_MULTIMEDIA_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == RESEND_USER_ACTIVATION_CODE) {
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http resendActionCode:dataDic completionBlock:^(id object, NSError *error) {
            if (object && !error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:RESEND_USER_ACTIVATION_CODE_SUCCCEEDED],
                                          WHEN_KEY:[NSDate date]}];
                
            }else if(object == nil || object == (id)[NSNull null]) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:RESEND_USER_ACTIVATION_CODE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{
                                          WHAT_KEY:[NSNumber numberWithInteger:RESEND_USER_ACTIVATION_CODE_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }else if (op == SAVE_DEVICE_USEAGES){
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http saveDeviceUseages:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_DEVICE_USEAGES_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_DEVICE_USEAGES_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:SAVE_DEVICE_USEAGES_SUCCESSED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    } else if (op == GET_DEVICE_USEAGES){
        NSMutableDictionary *dataDic = msg[OBJ_KEY];
        [_http getDeviceUsages:dataDic completionBlock:^(id object, NSError *error){
            if (error) {
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_DEVICE_USEAGES_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }else if(object == nil || object == (id)[NSNull null]){
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_DEVICE_USEAGES_FAILED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:error}];
            }else {
                NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_DEVICE_USEAGES_SAVE],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:object};
                [self onOperate:newMsg];
                [_handler handleMessage:@{WHAT_KEY:[NSNumber numberWithInteger:GET_DEVICE_USEAGES_SUCCESSED],
                                          WHEN_KEY:[NSDate date],
                                          OBJ_KEY:object}];
            }
        }];
    }
    
    //---For saving response data---//------------------------------------------------------------------------------
    else if (op == SAVE_USER){
        if (_modelManager.user == nil) {
            _modelManager.user = [[User alloc] init];
        }
        NSError *error = nil;
        _modelManager.user = [[User alloc] initWithDictionary:(NSDictionary*)msg[OBJ_KEY] error:&error];
        if (_modelManager.user.userSettings[@"1004"] == nil ||
            [_modelManager.user.userSettings[@"1004"] isEqual:(id)[NSNull null]] ||
            [_modelManager.user.userSettings[@"1004"] isEqualToString:@"<null>"]) {
            _modelManager.user.userSettings[@"1004"] = @"0";
        }
        [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
        //---get locally saved data---//
//        User *offLineUser = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:NSStringFromClass([User class])];
//        NSLog(@"%@", offLineUser);
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_modelManager.user];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:AUTOLOGIN_BODY];
        [defaults setValue:@"1" forKey:AUTOLOGIN_STATUS];
        [defaults synchronize];
    }
    else if (op == UPDATE_MEMBER_SAVE) {
        NSDictionary *userDic =[NSDictionary new];
        userDic = (NSDictionary*)msg[OBJ_KEY];
        _modelManager.user.firstName = userDic[kUserFirstName];
        _modelManager.user.lastName = userDic[kUserLastName];
        _modelManager.user.gender = userDic[kUserGender];
        _modelManager.user.contact = userDic[kUserContact];
        _modelManager.user.email = userDic[kUserEmail];
        _modelManager.user.dob = userDic[kDateOfBirth];
        _modelManager.user.address = userDic[kUserAddrress];
        [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
    }
    else if (op == GET_All_MEMBERS_SAVE) {
        if (msg[OBJ_KEY]) {
            if (_modelManager.members == nil) {
                _modelManager.members = [[Members alloc] init];
            }else {
                [_modelManager.members.rows removeAllObjects];
            }
            NSError *error = nil;
            _modelManager.members =   [[Members alloc] initWithDictionary:msg[OBJ_KEY] error:&error];
            [JsonUtil saveObject:_modelManager.members withFile:NSStringFromClass([Members class])];
            //---get locally saved data---//
//            Members *offlineMember = [JsonUtil loadObject:NSStringFromClass([Members class]) withFile:@"Members"];
//            NSLog(@"%@", offlineMember);
        }
    }
    else if (op == GET_LOCATION_DATA_SAVE) {
        if (msg[OBJ_KEY]) {
            if (_modelManager.memberLocations == nil) {
                _modelManager.memberLocations = [[MemberLocations alloc] init];
            }else {
                [_modelManager.memberLocations.rows removeAllObjects];
            }
            NSArray *resultArray = msg[OBJ_KEY];
            MemberLocation *userLoc = [MemberLocation new];
            for (NSDictionary *locDic in resultArray) {
                MemberLocation *memberLoc = [MemberLocation new];
                //---set timestamp,lat and long---//
                NSArray *valuesArray = [locDic valueForKey:kValuesKey_GetLocation];
                if (valuesArray.count > 0) {
                    //---set id and name---//
                    NSDictionary *tags = [locDic valueForKey:kTagsKey_GetLocation];
                    if (tags) {
                        memberLoc.userName = [tags valueForKey:kIdKey_GetLocation][0];
                        NSString *fullName = (NSString*)[[tags valueForKey:kNameKey_GetLocation] lastObject];
                        fullName = [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        memberLoc.name = fullName;
                        fullName = nil;
                    }
                    NSArray *values = [[locDic valueForKey:kValuesKey_GetLocation] objectAtIndex:0];
                    if (values) {
                        memberLoc.timestamp = (NSNumber *)[values objectAtIndex:0];
                        memberLoc.latitude = [[[values objectAtIndex:1] valueForKey:kLatitudeKey_GetLocation] doubleValue];
                        memberLoc.longitude = [[[values objectAtIndex:1] valueForKey:kLongitudeKey_GetLocation] doubleValue];
                        //---for user sorting---//
                        if ([memberLoc.userName isEqualToString:_modelManager.user.userName]) {
                            userLoc = memberLoc;
                        } else {
                            [_modelManager.memberLocations.rows addObject:memberLoc];
                        }
                    }
                }
            }
            
            if (userLoc) {
                 [_modelManager.memberLocations.rows addObject:userLoc];
            }
            
            [JsonUtil saveObject:_modelManager.memberLocations withFile:NSStringFromClass([MemberLocations class])];
            //---get locally saved data---//
            //        MemberLocations *offlineMember = [JsonUtil loadObject:NSStringFromClass([MemberLocations class]) withFile:@"MemberLocations"];
            //        NSLog(@"%@", offlineMember);
        }
    }
    else if (op == GET_SETTINGS_SAVE) {
        //---sohan---//
        if (_modelManager.settings == nil) {
            _modelManager.settings = [[Settings alloc] init];
        }else {
            [_modelManager.settings.rows removeAllObjects];
        }
        NSError *error = nil;
        _modelManager.settings =   [[Settings alloc] initWithDictionary:msg[OBJ_KEY] error:&error];
        [JsonUtil saveObject:_modelManager.settings withFile:NSStringFromClass([Settings class])];
        //---get locally saved data---//
//        Settings *offlineMember = [JsonUtil loadObject:NSStringFromClass([Settings class]) withFile:NSStringFromClass([Settings class])];
//        NSLog(@"%@", offlineMember);
    }
    else if (op == GET_ALERTS_SAVE) {
        if (msg[OBJ_KEY]) {
            //---nextPage for get Alerts---//
            NSDictionary *nextDic = (NSDictionary*)[msg[OBJ_KEY] valueForKey:kNext_key];
            if( nextDic == nil || nextDic == (id)[NSNull null]) {
                _modelManager.nextPageForAlert = @"";
            }else {
                _modelManager.nextPageForAlert = [nextDic valueForKey:kNextPage_key];
            }
            //Get Alerts
            NSError *error = nil;
            Notifications *notifications = [[Notifications alloc] initWithDictionary:msg[OBJ_KEY] error:&error];
            if (![GlobalData sharedInstance]._allAlertFullList) {
                [GlobalData sharedInstance]._allAlertFullList = [[Notifications alloc] init];
                [GlobalData sharedInstance]._allAlertFullList = notifications;
            }
            else {
                [[GlobalData sharedInstance]._allAlertFullList.rows addObjectsFromArray:notifications.rows];
            }
            NSLog(@"count = %ld",(unsigned long)[GlobalData sharedInstance]._allAlertFullList.rows.count);
            if (!_modelManager.notifications) {
                _modelManager.notifications = [[Notifications alloc] init];
            }else {
                _modelManager.notifications = nil;
            }
            _modelManager.notifications = [GlobalData sharedInstance].
             _allAlertFullList;
            [JsonUtil saveObject:_modelManager.notifications withFile:NSStringFromClass([Notifications class])];
            //---get locally saved data---//
//            Notifications *offlineMember = [JsonUtil loadObject:NSStringFromClass([Notifications class]) withFile:NSStringFromClass([Notifications class])];
//            NSLog(@"%@", offlineMember);
        }
    }else if (op == GET_NEW_ALERTS_SAVE) {
        if (msg[OBJ_KEY]) {            
            //--- Set Total New AlertNumber ---//
            NSNumber *totalNewAlerts = [[msg[OBJ_KEY] valueForKey:kMetadata_key] valueForKey:kNew_key];
            int totalNewAlertCount = ([totalNewAlerts intValue] < 30)?[totalNewAlerts intValue]:30;
            if ([totalNewAlerts intValue] > 0 && [totalNewAlerts intValue] > [_modelManager.totalNewAlerts intValue]) {
                NSMutableArray *newAlertArray = [msg[OBJ_KEY] valueForKey:kResultsetKey];
                if (newAlertArray == nil || [newAlertArray isEqual:(id)[NSNull null]] || totalNewAlertCount > newAlertArray.count) {
                    return;
                }
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                 if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                     for (int i = 0; i < totalNewAlertCount; i++) {
                         NSDictionary *alertDic = newAlertArray[i];
                         UILocalNotification * notification = [[UILocalNotification alloc] init];
                         notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
                         notification.timeZone = [[NSCalendar currentCalendar] timeZone];
                         
                         if ([alertDic[kNotification_message_title] isEqual:(id)[NSNull null]] ||
                             alertDic[kNotification_message_title] == nil) {
                         }else {
                             notification.alertBody = alertDic[kNotification_message_title][_modelManager.defaultLanguage];
                         }
                         //---check empty link
                         NSString *urlLinkStr = @"";
                         if ([alertDic[kLink] isEqual:(id)[NSNull null]] ||
                             alertDic[kLink] == nil) {
                             urlLinkStr = @"";
                         }else {
                             urlLinkStr = alertDic[kLink];
                         }

                         notification.hasAction = YES;
                         notification.alertAction = NSLocalizedString(@"View", nil);
                         [notification setCategory:@"custom_category_id"];
                         
                         //Third part
                         if ([alertDic[kAlert_type] isEqualToString:kAlert_type_panic]) {
                             if ([_modelManager.user.settings[kPanicAlertPermission] boolValue]) {
                                  [delegate setVolumeUp];
                                  notification.userInfo = @{kAlert_type : kAlert_type_panic,
                                                            kLink : urlLinkStr,
                                                            kIdentifier : alertDic[kIdentifier]};
                                //--2nd part of notification
                                  notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                                  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                              }
                         }
                         else {
                              if ([alertDic[kAlert_type] isEqualToString:kAlert_type_videoStreaming]) {
                                 notification.soundName = @"ReceivedMessage.wav";
                                 notification.userInfo = @{kAlert_type : alertDic[kAlert_type],
                                                           kLink : urlLinkStr,
                                                           kIdentifier : alertDic[kIdentifier]};
                             }else if ([alertDic[kAlert_type] isEqualToString:kAlert_type_audioStreaming]) {
                                 notification.soundName = @"ReceivedMessage.wav";
                                 notification.userInfo = @{kAlert_type :alertDic[kAlert_type],
                                                           kLink : urlLinkStr,
                                                           kIdentifier : alertDic[kIdentifier]};
                             }else {
                                 notification.soundName = @"ReceivedMessage.wav";
                                 notification.userInfo = @{kAlert_type : kAlert_type_other,
                                                           kLink : urlLinkStr};
                             }
                             
                            //--2nd part of notification
                             notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                             [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                         }
                     }
                }
                else {
                    //if (![GlobalData sharedInstance].isInPanic) {
                        for (int i = 0; i < totalNewAlertCount; i++) {
                            NSDictionary *alertDic = newAlertArray[i];
                            if ([alertDic[kAlert_type] isEqualToString:kAlertType_TimeOut]) {
                                if ([GlobalData sharedInstance].isInPanic) {
                                    [GlobalData sharedInstance].isInPanic = NO;
                                }
                                if([[GlobalData sharedInstance].currentVC isKindOfClass:[AudioViewController class]]) {
                                    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:@"stopAudioStreamingNotification"
                                     object:nil];
                                    break;
                                }else if([[GlobalData sharedInstance].currentVC isKindOfClass:[StreamVideoVC class]]) {
                                    [[NSNotificationCenter defaultCenter]
                                     postNotificationName:@"stopVideoStreamingNotification"
                                     object:nil];
                                    break;
                                }
                            }
                            if ([alertDic[kAlert_type] isEqualToString:kAlert_type_panic]) {
                                if ([_modelManager.user.settings[kPanicAlertPermission] boolValue]) {
                                    [delegate setVolumeUp];
                                    //[delegate PlayPanicAlert];
                                    break;
                                }
                            }
                        }
                   // }
                }
            }
            //_modelManager.totalNewAlerts = totalNewAlerts;
            //---if app is background---//
        }
    } else if (op == GET_DEVICE_USEAGES_SAVE) {
        if (_modelManager.deviceStatusArray == nil) {
            _modelManager.deviceStatusArray = [[NSMutableArray<DeviceStatus> alloc] init];
        }else {
            [_modelManager.deviceStatusArray removeAllObjects];
        }
        NSError *error = nil;
        for (NSDictionary *dic in msg[OBJ_KEY]) {
            DeviceStatus *dStatus = [[DeviceStatus alloc]  initWithDictionary:dic error:&error];
            [_modelManager.deviceStatusArray addObject:dStatus];
        }
        
    }
}

@end
