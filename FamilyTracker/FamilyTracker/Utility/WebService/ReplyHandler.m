//
//  ReplyHandler.m
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "FamilyTrackerOperate.h"
#import "FamilyTrackerDefine.h"
#import "ReplyHandler.h"
//#import "GlobalData.h"

@interface ReplyHandler () {
    id _target;
    ModelManager *_modelManager;
    id <Operator> _opertor;
    id <Progress> _progress;
    id <SignupUpdater> _loginUpdater;
    id <SignupUpdater> _signupUpdater;
    id <SignupUpdater> _addMemberUpdater;
    id <DataUpdater> _updateUserUpdater;
    id <SignupUpdater> _settingsUpdater;
    id <TableUpdater> _trackAppDayNightModeUpdater;
    id <TableUpdater> _saveLocationUpdater;
    id <TableUpdater> _getLocationUpdater;
    id <TableUpdater> _getLocationHistoryUpdater;
    id <DataUpdater> _saveAlertUpdater;
    id <TableUpdater> _getAlertUpdater;
}

@end

@implementation ReplyHandler

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
    (id<DataUpdater>)saveAlertUpdater getAlertUpdate:
    (id<TableUpdater>)getAlertUpdater andTarget:
    (id)target {
        if (self = [super init]) {
            _target = target;
            _modelManager = modelManager;
            _opertor = oprtr;
            _progress = prgrss;
            _loginUpdater = loginUpdater;
            _signupUpdater = signupUpdater;
            _addMemberUpdater = addMemberUpdater;
            _updateUserUpdater = updateUserUpdater;
            _settingsUpdater = settingsUpdater;
            _trackAppDayNightModeUpdater = trackAppDayNightModeUpdater;
            _saveLocationUpdater = saveLocationUpdater;
            _getLocationUpdater = getLocationUpdater;
            _getLocationHistoryUpdater = getLocationHistoryUpdater;
            _saveAlertUpdater = saveAlertUpdater;
            _getAlertUpdater = getAlertUpdater;
        }
    return self;
}

- (void)handleMessage:(id)msg {
    //NSLog(@"CallCoreReplyHandler onOperate: msg= %@", [msg description]);
    int ope = [msg[WHAT_KEY] intValue];
    if(ope == LOGIN_SUCCESS) {                              // Login
        [_loginUpdater signupSuccess:nil isSuccess:YES];
        
    }else if(ope == LOGIN_FAILED) {
        [_loginUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        
    }else if(ope == SIGN_OUT_SUCCCEEDED) {                       // Guardian Signup
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == SIGN_OUT_FAILED) {
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == FORCE_SIGNOUT_SUCCCEEDED) {                       // ForceSignout
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == FORCE_SIGNOUT_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == SIGNUP_SUCCESS) {                      // Guardian Signup
        [_signupUpdater signupSuccess:nil isSuccess:YES];
    }else if(ope == SIGNUP_FAILED) {
        [_signupUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
    }else if(ope == RESET_PASSWORD_SUCCESS) {                      // Reset Password
        [_signupUpdater signupSuccess:msg[OBJ_KEY] isSuccess:YES];
    }else if(ope == RESET_PASSWORD_FAILED) {
        [_signupUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
    }else if(ope == GET_SETTINGS_SUCCEEDED) {                  //---Settings
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_SETTINGS_FAILED) {
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == ADD_MEMBER_SUCCEEDED) {
        // Member Signup/ Add Member
        [_addMemberUpdater signupSuccess:nil isSuccess:YES];
        
    }else if(ope == ADD_MEMBER_FAILED) {
        [_addMemberUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        
    }else if(ope == POST_LOCATION_DATA_SUCCEEDED) {// Post/Save Location
        [_saveLocationUpdater refreshUI:ope];
        
    }else if(ope == POST_LOCATION_DATA_FAILED) {
        [_saveLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_LOCATION_DATA_SUCCEEDED) {// Get Member Locations
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_LOCATION_DATA_FAILED) {
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_All_MEMBERS_SUCCEEDED) {// Get All Members
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_All_MEMBERS_FAILED) {
        [_getLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_ALERTS_SUCCEEDED) {//---Get Alerts
        [_getAlertUpdater refreshUI:ope];
        
    }else if(ope == GET_ALERTS_FAILED) {
        [_getAlertUpdater refreshUI:ope];
        
    }else if(ope == GET_NEW_ALERTS_SUCCEEDED) {//---Get Alerts
        [_saveLocationUpdater refreshUI:ope];
        
    }else if(ope == GET_NEW_ALERTS_FAILED) {
        [_saveLocationUpdater refreshUI:ope];
        
    }else if(ope == SAVE_ALERT_SUCCEEDED) {//---Save Alerts/post panic alert
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == SAVE_ALERT_FAILED) {//STOP_STREAMING_SUCCEEDED
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == STOP_STREAMING_SUCCEEDED) {//---Save Alerts/post panic alert
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == STOP_STREAMING_FAILED) {//
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == UPDATE_MEMBER_SUCCEEDED) {//---Update User Profile---//
         [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];

    }else if(ope == UPDATE_MEMBER_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];

    }else if(ope == UPDATE_MEMBER_DETAILS_SUCCEEDED) {//---Update Member Details---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == UPDATE_MEMBER_DETAILS_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == UPLOAD_USER_PICTURE_SUCCCEEDED) {//---Upload User Profile Picture---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == UPLOAD_USER_PICTURE_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }
    
    else if(ope == ACTIVE_INACTIVE_MEMBER_SUCCESS) {//--- Active Inactive Member ---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == ACTIVE_INACTIVE_MEMBER_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }
    
    else if(ope == UPDATE_SETTINGS_SUCCEEDED) {//---Update member
        [_settingsUpdater signupSuccess:msg[OBJ_KEY] isSuccess:YES];

    }else if(ope == UPDATE_SETTINGS_FAILED) {
        [_settingsUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        
    }
    else if(ope == ADD_EMERGENCY_SUCCCEEDED) {//---add emergency
       [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == ADD_EMERGENCY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == REMOVE_EMERGENCY_SUCCESS) {//---remove emergency
        //[_settingsUpdater signupSuccess:msg[OBJ_KEY] isSuccess:YES];
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == REMOVE_EMERGENCY_FAILED) {
        //[_settingsUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == ADD_BOUNDARY_SUCCCEEDED) {//---add boundary
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == ADD_BOUNDARY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == GET_BOUNDARY_SUCCCEEDED) {//---get boundary
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == GET_BOUNDARY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == DELETE_BOUNDARY_SUCCCEEDED) {//---DELETE boundary
        [_updateUserUpdater updateUI:msg withStatus:ope];
    }else if(ope == DELETE_BOUNDARY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == UPDATE_BOUNDARY_SUCCCEEDED) {//--- update boundary
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == UPDATE_BOUNDARY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED) {//Acknowledged New Alert
         [_getAlertUpdater refreshUI:ope];

    }else if(ope == ACKNOWLEDGE_NEW_ALERTS_FAILED) {
         [_getAlertUpdater refreshUI:ope];

    }else if(ope == CHANGE_PASSWORD_SUCCESS) {//ChangePassword
         [_loginUpdater signupSuccess:msg[OBJ_KEY] isSuccess:YES];
        
    }else if(ope == CHANGE_PASSWORD_FAILED) {
         [_loginUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        
    }else if(ope == ACKNOWLEDGE_READ_ALERT_SUCCCEEDED) {//Acknowledged Read Alert
        [_getAlertUpdater refreshUI:ope];

    }else if(ope == ACKNOWLEDGE_READ_ALERT_FAILED) {
        [_getAlertUpdater refreshUI:ope];

    }else if(ope == GET_MEMBER_BY_ID_SUCCEEDED) {//---GET_MEMBER_BY_ID ---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == GET_MEMBER_BY_ID_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];

    }else if(ope == LOCATION_HIDE_SUCCCEEDED) {//---GET_MEMBER_BY_ID ---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == LOCATION_HIDE_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];

    }else if(ope == GET_EMERGENCY_SUCCCEEDED) {//---get emergency contacts---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == GET_EMERGENCY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];

    }else if(ope == ACTIVATE_CODE_VERIFY_SUCCCEEDED) {//--- activate code verify  ---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == ACTIVATE_CODE_VERIFY_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
    else if(ope == DEVICE_REGISTRATION_SUCCCEEDED) { //--- DEVICE_REGISTRATION_SUCCCEEDED ---//
        [_updateUserUpdater updateUI:nil withStatus:ope];
    }else if(ope == DEVICE_REGISTRATION_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == ADD_USER_WATCH_SUCCCEEDED) {//---Add User Watch Success---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == ADD_USER_WATCH_FAILED) {//---Add User Watch fail---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == UPLOAD_MULTIMEDIA_SUCCCEEDED) {//---Upload Multimedia Success---//
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == UPLOAD_MULTIMEDIA_FAILED) {//---Upload Multimedia fail---//
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == INACTIVE_USER_WATCH_SUCCCEEDED) {//---Inactive User Watch Success---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == INACTIVE_USER_WATCH_FAILED) {//---inactive User Watch fail---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == RESEND_USER_ACTIVATION_CODE_SUCCCEEDED) {//resend activation code
        [_loginUpdater signupSuccess:msg[OBJ_KEY] isSuccess:YES];
    }else if(ope == RESEND_USER_ACTIVATION_CODE_FAILED) {
        [_loginUpdater signupSuccess:msg[OBJ_KEY] isSuccess:NO];
        
    }else if(ope == STOP_LISTENING_ALERT_SUCCCEEDED) {//---Stop Listening alert
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == STOP_LISTENING_ALERT_FAILED) {//
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == GET_ALL_USER_PACKAGE_SUCCCEEDED) {//---get emergency contacts---//
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == GET_ALL_USER_PACKAGE_FAILED) {
        [_updateUserUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == SAVE_DEVICE_USEAGES_SUCCESSED) {//---SAVE_DEVICE_USEAGES
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
        
    }else if(ope == SAVE_DEVICE_USEAGES_FAILED) {//SAVE_DEVICE_USEAGES
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == GET_DEVICE_USEAGES_SUCCESSED) {//---get device useages successed
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }else if(ope == GET_DEVICE_USEAGES_FAILED) {//--- get device useages failed
        [_saveAlertUpdater updateUI:msg[OBJ_KEY] withStatus:ope];
    }
}

@end
