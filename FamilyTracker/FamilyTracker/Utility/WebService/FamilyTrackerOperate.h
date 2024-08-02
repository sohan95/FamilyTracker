//
//  CamConnectOperate.h
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FamilyTrackerOperate : NSObject
//SignIn
extern int const LOGIN;
extern int const LOGIN_SUCCESS;
extern int const LOGIN_FAILED;

extern int const SAVE_USER;
//Signup
extern int const SIGNUP;
extern int const SIGNUP_SUCCESS;
extern int const SIGNUP_FAILED;

//---Add Member/Member Signup---//
extern int const ADD_MEMBER;
extern int const ADD_MEMBER_SUCCEEDED;
extern int const ADD_MEMBER_FAILED;
extern int const ADD_MEMBER_SAVE;

//Post LocationData
extern int const POST_LOCATION_DATA;
extern int const POST_LOCATION_DATA_SUCCEEDED;
extern int const POST_LOCATION_DATA_FAILED;

//Get LocationData
extern int const GET_LOCATION_DATA;
extern int const GET_LOCATION_DATA_SUCCEEDED;
extern int const GET_LOCATION_DATA_FAILED;
extern int const GET_LOCATION_DATA_SAVE;

//GetAllMembers
extern int const GET_All_MEMBERS;
extern int const GET_All_MEMBERS_SUCCEEDED;
extern int const GET_All_MEMBERS_FAILED;
extern int const GET_All_MEMBERS_SAVE;

//GET_MEMBER_BY_ID
extern int const GET_MEMBER_BY_ID;
extern int const GET_MEMBER_BY_ID_SUCCEEDED;
extern int const GET_MEMBER_BY_ID_FAILED;
extern int const GET_MEMBER_BY_ID_SAVE;

//GET_ALERTS
extern int const GET_ALERTS;
extern int const GET_ALERTS_SUCCEEDED;
extern int const GET_ALERTS_FAILED;
extern int const GET_ALERTS_SAVE;
//GetAllMembers AFTER new member added
extern int const GET_All_MEMBERS_AFTER_NEW_MEMBER;
extern int const GET_All_MEMBERS_AFTER_NEW_MEMBER_SUCCEEDED;
extern int const GET_All_MEMBERS_AFTER_NEW_MEMBER_FAILED;

//GET_NEW_ALERTS
extern int const GET_NEW_ALERTS;
extern int const GET_NEW_ALERTS_SUCCEEDED;
extern int const GET_NEW_ALERTS_FAILED;
extern int const GET_NEW_ALERTS_SAVE;

//SAVE_ALERT / START_STREAMING
extern int const SAVE_ALERT;
extern int const SAVE_ALERT_SUCCEEDED;
extern int const SAVE_ALERT_FAILED;

//STOP_STREAMING
extern int const STOP_STREAMING;
extern int const STOP_STREAMING_SUCCEEDED;
extern int const STOP_STREAMING_FAILED;

//Save Settings
extern int const GET_SETTINGS;
extern int const GET_SETTINGS_SUCCEEDED;
extern int const GET_SETTINGS_FAILED;
extern int const GET_SETTINGS_SAVE;

//---Member Update---//
extern int const UPDATE_MEMBER;
extern int const UPDATE_MEMBER_SUCCEEDED;
extern int const UPDATE_MEMBER_FAILED;
extern int const UPDATE_MEMBER_SAVE;

//--- Member Details Update---//
extern int const UPDATE_MEMBER_DETAILS;
extern int const UPDATE_MEMBER_DETAILS_SUCCEEDED;
extern int const UPDATE_MEMBER_DETAILS_FAILED;
extern int const UPDATE_MEMBER_DETAILS_SAVE;

//---Update SETTINGS---//
extern int const UPDATE_SETTINGS;
extern int const UPDATE_SETTINGS_SUCCEEDED;
extern int const UPDATE_SETTINGS_FAILED;
//extern int const UPDATE_SETTINGS_SAVED;

extern int const ACKNOWLEDGE_NEW_ALERTS;
extern int const ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED;
extern int const ACKNOWLEDGE_NEW_ALERTS_FAILED;

extern int const ACKNOWLEDGE_READ_ALERT;
extern int const ACKNOWLEDGE_READ_ALERT_SUCCCEEDED;
extern int const ACKNOWLEDGE_READ_ALERT_FAILED;

//UPLOAD USER PICTURE
extern int const UPLOAD_USER_PICTURE;
extern int const UPLOAD_USER_PICTURE_SUCCCEEDED;
extern int const UPLOAD_USER_PICTURE_FAILED;

//LOCATION_HIDE
extern int const LOCATION_HIDE;
extern int const LOCATION_HIDE_SUCCCEEDED;
extern int const LOCATION_HIDE_FAILED;

// Add Emergency Contacts
extern int const ADD_EMERGENCY;
extern int const ADD_EMERGENCY_SUCCCEEDED;
extern int const ADD_EMERGENCY_FAILED;

// SignOut
extern int const SIGN_OUT;
extern int const SIGN_OUT_SUCCCEEDED;
extern int const SIGN_OUT_FAILED;

// Get Emergency Contacts
extern int const GET_EMERGENCY;
extern int const GET_EMERGENCY_SUCCCEEDED;
extern int const GET_EMERGENCY_FAILED;

// SMS_ACTIVATE
extern int const ACTIVATE_CODE_VERIFY;
extern int const ACTIVATE_CODE_VERIFY_SUCCCEEDED;
extern int const ACTIVATE_CODE_VERIFY_FAILED;

// forceSignOut
extern int const FORCE_SIGNOUT;
extern int const FORCE_SIGNOUT_SUCCCEEDED;
extern int const FORCE_SIGNOUT_FAILED;

// remove emergency
extern int const REMOVE_EMERGENCY;
extern int const REMOVE_EMERGENCY_SUCCESS;
extern int const REMOVE_EMERGENCY_FAILED;

// remove change password
extern int const CHANGE_PASSWORD;
extern int const CHANGE_PASSWORD_SUCCESS;
extern int const CHANGE_PASSWORD_FAILED;

// reset password service
extern int const RESET_PASSWORD;
extern int const RESET_PASSWORD_SUCCESS;
extern int const RESET_PASSWORD_FAILED;

// active inactive member service
extern int const ACTIVE_INACTIVE_MEMBER;
extern int const ACTIVE_INACTIVE_MEMBER_SUCCESS;
extern int const ACTIVE_INACTIVE_MEMBER_FAILED;

// Add Boundary service
extern int const ADD_BOUNDARY;
extern int const ADD_BOUNDARY_SUCCCEEDED;
extern int const ADD_BOUNDARY_FAILED;

// Get Boundary service
extern int const GET_BOUNDARY;
extern int const GET_BOUNDARY_SUCCCEEDED;
extern int const GET_BOUNDARY_FAILED;

// Delete Boundary service
extern int const DELETE_BOUNDARY;
extern int const DELETE_BOUNDARY_SUCCCEEDED;
extern int const DELETE_BOUNDARY_FAILED;

// Update Boundary service
extern int const UPDATE_BOUNDARY;
extern int const UPDATE_BOUNDARY_SUCCCEEDED;
extern int const UPDATE_BOUNDARY_FAILED;

// Device registration for push notification
extern int const DEVICE_REGISTRATION;
extern int const DEVICE_REGISTRATION_SUCCCEEDED;
extern int const DEVICE_REGISTRATION_FAILED;

// Add User Watch
extern int const ADD_USER_WATCH;
extern int const ADD_USER_WATCH_SUCCCEEDED;
extern int const ADD_USER_WATCH_FAILED;

// Upload Multimedia Resource
extern int const UPLOAD_MULTIMEDIA;
extern int const UPLOAD_MULTIMEDIA_SUCCCEEDED;
extern int const UPLOAD_MULTIMEDIA_FAILED;

// InActive  User Watch
extern int const INACTIVE_USER_WATCH;
extern int const INACTIVE_USER_WATCH_SUCCCEEDED;
extern int const INACTIVE_USER_WATCH_FAILED;

// Resend User Activation Code
extern int const RESEND_USER_ACTIVATION_CODE;
extern int const RESEND_USER_ACTIVATION_CODE_SUCCCEEDED;
extern int const RESEND_USER_ACTIVATION_CODE_FAILED;

extern int const STOP_LISTENING_ALERT;
extern int const STOP_LISTENING_ALERT_SUCCCEEDED;
extern int const STOP_LISTENING_ALERT_FAILED;

// Get All User Package
extern int const GET_ALL_USER_PACKAGE;
extern int const GET_ALL_USER_PACKAGE_SUCCCEEDED;
extern int const GET_ALL_USER_PACKAGE_FAILED;

//Save Device useages status data
extern int const SAVE_DEVICE_USEAGES;
extern int const SAVE_DEVICE_USEAGES_SUCCESSED;
extern int const SAVE_DEVICE_USEAGES_FAILED;

//Get Device useages status
extern int const GET_DEVICE_USEAGES;
extern int const GET_DEVICE_USEAGES_SUCCESSED;
extern int const GET_DEVICE_USEAGES_FAILED;
extern int const GET_DEVICE_USEAGES_SAVE;

//ProgressHUD
extern const int UPDATE;
extern const int WAKEUP;
extern const int PROGRESS_CLOSE;
extern const int PROGRESS_MSG;
extern const int PROGRESS_ERROR;
extern const int PROGRESS_TOAST;
extern const int PROGRESS_ERR;

+ (id)messageForOperationCode:(NSUInteger)code;
+ (id)messageForOperationCode:(NSUInteger)code andObject:(id)obj;
@end
