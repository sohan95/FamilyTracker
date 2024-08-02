//
//  CamConnectOperate.m
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "FamilyTrackerOperate.h"

@implementation FamilyTrackerOperate

//SignIn
const int LOGIN = 1011;
const int LOGIN_SUCCESS = 1012;
const int LOGIN_FAILED = 1013;
const int SAVE_USER = 1014;

//SignUP
const int SIGNUP = 1101;
const int SIGNUP_SUCCESS = 1102;
const int SIGNUP_FAILED = 1103;

//---Member SignUP---//
const int ADD_MEMBER = 1201;
const int ADD_MEMBER_SUCCEEDED = 1202;
const int ADD_MEMBER_FAILED = 1203;
const int ADD_MEMBER_SAVE = 1204;

//---Post User Location Data---//
const int POST_LOCATION_DATA = 1301;
const int POST_LOCATION_DATA_SUCCEEDED = 1302;
const int POST_LOCATION_DATA_FAILED = 1303;

//GetLocationData
const int GET_LOCATION_DATA = 1401;
const int GET_LOCATION_DATA_SUCCEEDED = 1402;
const int GET_LOCATION_DATA_FAILED = 1403;
const int GET_LOCATION_DATA_SAVE = 1404;

//GetAllMembers
const int GET_All_MEMBERS = 1501;
const int GET_All_MEMBERS_SUCCEEDED = 1502;
const int GET_All_MEMBERS_FAILED = 1503;
const int GET_All_MEMBERS_SAVE = 1504;

//GetAllMembers AFTER new member added
const int GET_All_MEMBERS_AFTER_NEW_MEMBER = 1511;
const int GET_All_MEMBERS_AFTER_NEW_MEMBER_SUCCEEDED = 1512;
const int GET_All_MEMBERS_AFTER_NEW_MEMBER_FAILED = 1513;

//GET_MEMBER_BY_ID
const int GET_MEMBER_BY_ID = 1601;
const int GET_MEMBER_BY_ID_SUCCEEDED = 1602;
const int GET_MEMBER_BY_ID_FAILED = 1603;
const int GET_MEMBER_BY_ID_SAVE = 1604;

//GET_ALERTS
const int GET_ALERTS = 1701;
const int GET_ALERTS_SUCCEEDED = 1702;
const int GET_ALERTS_FAILED = 1703;
const int GET_ALERTS_SAVE = 1704;

//GET_NEW_ALERTS
const int GET_NEW_ALERTS = 1711;
const int GET_NEW_ALERTS_SUCCEEDED = 1712;
const int GET_NEW_ALERTS_FAILED = 1713;
const int GET_NEW_ALERTS_SAVE = 1714;

//SAVE_ALERT/ Start_Streaming
const int SAVE_ALERT = 1801;
const int SAVE_ALERT_SUCCEEDED = 1802;
const int SAVE_ALERT_FAILED = 1803;

//STOP_STREAMING
const int STOP_STREAMING = 1811;
const int STOP_STREAMING_SUCCEEDED = 1812;
const int STOP_STREAMING_FAILED = 1813;

//Save Settings
const int GET_SETTINGS = 1901;
const int GET_SETTINGS_SUCCEEDED = 1902;
const int GET_SETTINGS_FAILED = 1903;
const int GET_SETTINGS_SAVE = 1904;

//---Member Update---//
const int UPDATE_MEMBER = 2001;
const int UPDATE_MEMBER_SUCCEEDED = 2002;
const int UPDATE_MEMBER_FAILED = 2003;
const int UPDATE_MEMBER_SAVE = 2004;

//--- Member Details Update---//
const int UPDATE_MEMBER_DETAILS = 2011;
const int UPDATE_MEMBER_DETAILS_SUCCEEDED = 2012;
const int UPDATE_MEMBER_DETAILS_FAILED = 2013;
const int UPDATE_MEMBER_DETAILS_SAVE = 2014;

//---Update SETTINGS---//
const int UPDATE_SETTINGS = 2101;
const int UPDATE_SETTINGS_SUCCEEDED = 2102;
const int UPDATE_SETTINGS_FAILED = 2103;
//const int UPDATE_SETTINGS_SAVED = 2104;
////
const int ACKNOWLEDGE_NEW_ALERTS = 2201;
const int ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED = 2202;
const int ACKNOWLEDGE_NEW_ALERTS_FAILED = 2203;

const int ACKNOWLEDGE_READ_ALERT = 2301;
const int ACKNOWLEDGE_READ_ALERT_SUCCCEEDED = 2302;
const int ACKNOWLEDGE_READ_ALERT_FAILED = 2303;

//UPLOAD USER PICTURE
const int UPLOAD_USER_PICTURE = 2401;
const int UPLOAD_USER_PICTURE_SUCCCEEDED = 2402;
const int UPLOAD_USER_PICTURE_FAILED = 2403;

//LOCATION_HIDE
const int LOCATION_HIDE = 2501;
const int LOCATION_HIDE_SUCCCEEDED = 2502;
const int LOCATION_HIDE_FAILED = 2503;

// Add Emergency Contacts
const int ADD_EMERGENCY = 2601;
const int ADD_EMERGENCY_SUCCCEEDED = 2602;
const int ADD_EMERGENCY_FAILED = 2603;

// SignOut
const int SIGN_OUT = 2701;
const int SIGN_OUT_SUCCCEEDED = 2702;
const int SIGN_OUT_FAILED = 2703;

// SMS_ACTIVATE
const int ACTIVATE_CODE_VERIFY = 2801;
const int ACTIVATE_CODE_VERIFY_SUCCCEEDED = 2802;
const int ACTIVATE_CODE_VERIFY_FAILED = 2803;

// Get Emergency Contacts
const int GET_EMERGENCY = 2901;
const int GET_EMERGENCY_SUCCCEEDED = 2902;
const int GET_EMERGENCY_FAILED = 2903;

// forceSignOut
const int FORCE_SIGNOUT = 3001;
const int FORCE_SIGNOUT_SUCCCEEDED = 3002;
const int FORCE_SIGNOUT_FAILED = 3003;

// remove emergencycontact service
const int REMOVE_EMERGENCY = 3101;
const int REMOVE_EMERGENCY_SUCCESS = 3102;
const int REMOVE_EMERGENCY_FAILED = 3103;

// change password service
const int CHANGE_PASSWORD = 3201;
const int CHANGE_PASSWORD_SUCCESS = 3202;
const int CHANGE_PASSWORD_FAILED = 3203;

// reset password service
const int RESET_PASSWORD = 3301;
const int RESET_PASSWORD_SUCCESS = 3302;
const int RESET_PASSWORD_FAILED = 3303;

// active inactive member service
const int ACTIVE_INACTIVE_MEMBER = 3401;
const int ACTIVE_INACTIVE_MEMBER_SUCCESS = 3402;
const int ACTIVE_INACTIVE_MEMBER_FAILED = 3403;

// Add Boundary service
const int ADD_BOUNDARY = 3501;
const int ADD_BOUNDARY_SUCCCEEDED = 3502;
const int ADD_BOUNDARY_FAILED = 3503;

// Get Boundary service
const int GET_BOUNDARY = 3601;
const int GET_BOUNDARY_SUCCCEEDED = 3602;
const int GET_BOUNDARY_FAILED = 3603;

// Delete Boundary service
const int DELETE_BOUNDARY = 3701;
const int DELETE_BOUNDARY_SUCCCEEDED = 3702;
const int DELETE_BOUNDARY_FAILED = 3703;

// Update Boundary service
const int UPDATE_BOUNDARY = 3801;
const int UPDATE_BOUNDARY_SUCCCEEDED = 3802;
const int UPDATE_BOUNDARY_FAILED = 3803;


// Device registration for push notification
const int DEVICE_REGISTRATION = 3901;
const int DEVICE_REGISTRATION_SUCCCEEDED = 3902;
const int DEVICE_REGISTRATION_FAILED = 3903;

// Add User Watch
const int ADD_USER_WATCH = 4001;
const int ADD_USER_WATCH_SUCCCEEDED = 4002;
const int ADD_USER_WATCH_FAILED = 4003;

// Upload Multimedia Resource
const int UPLOAD_MULTIMEDIA = 4101;
const int UPLOAD_MULTIMEDIA_SUCCCEEDED = 4102;
const int UPLOAD_MULTIMEDIA_FAILED = 4103;

// InActive  User Watch
const int INACTIVE_USER_WATCH = 4201;
const int INACTIVE_USER_WATCH_SUCCCEEDED = 4202;
const int INACTIVE_USER_WATCH_FAILED = 4203;

// Resend User Activation Code
const int RESEND_USER_ACTIVATION_CODE = 4301;
const int RESEND_USER_ACTIVATION_CODE_SUCCCEEDED = 4302;
const int RESEND_USER_ACTIVATION_CODE_FAILED = 4303;

// Stop Listening alert Code
const int STOP_LISTENING_ALERT = 4401;
const int STOP_LISTENING_ALERT_SUCCCEEDED = 4402;
const int STOP_LISTENING_ALERT_FAILED = 4403;

// Get All User Package
const int GET_ALL_USER_PACKAGE = 4501;
const int GET_ALL_USER_PACKAGE_SUCCCEEDED = 4502;
const int GET_ALL_USER_PACKAGE_FAILED = 4503;

//Save Device useages status data
const int SAVE_DEVICE_USEAGES = 4601;
const int SAVE_DEVICE_USEAGES_SUCCESSED = 4602;
const int SAVE_DEVICE_USEAGES_FAILED = 4603;

//Get Device useages status
const int GET_DEVICE_USEAGES = 4701;
const int GET_DEVICE_USEAGES_SUCCESSED = 4702;
const int GET_DEVICE_USEAGES_FAILED = 4703;
const int GET_DEVICE_USEAGES_SAVE = 4704;

//ProgressHUD
const int UPDATE = 9001;
const int WAKEUP = 9001;
const int PROGRESS_CLOSE = 9101;
const int PROGRESS_MSG = 9102;
const int PROGRESS_ERROR = 9103;
const int PROGRESS_TOAST = 9104;
const int PROGRESS_ERR = 9105;

+ (id)messageForOperationCode:(NSUInteger)code{
    NSDictionary *msg = @{@"what":[NSNumber numberWithInteger:code],
                          @"when":[NSDate date]};
    return msg;
}

+ (id)messageForOperationCode:(NSUInteger)code andObject:(id)obj{
    NSDictionary *msg = [[self class] messageForOperationCode:code];
    NSMutableDictionary *newMsgDict = [NSMutableDictionary dictionaryWithDictionary:msg];
    newMsgDict[@"obj"] = obj;
    return newMsgDict;
}

@end
