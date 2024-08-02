//
//  CamConnectDefine.h
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FamilyTrackerDefine : NSObject

//App Id
#define kAppId @"28"
#define kAppIdKey @"appId"

//URL
//#define kFamilyTrackerBaseURL @"http://spapi.surround.family:4000"//kBatteryBaseUrl
#define kFamilyTrackerBaseURL @"http://spapi.surround.family"
//#define kFamilyTrackerBaseURL @"http://52.52.70.168:3550"
//#define kFamilyTrackerBaseURL @"http://52.221.84.181:4000"
//#define kFamilyTrackerBaseURL @"http://192.168.102.25:3500" // local
//#define kFamilyTrackerBaseURL_Local @"http://192.168.102.25:4000" //LocalServerIp
#define kGetAllMemberService @"api/v1/account/getMembers?"
#define kGetMemberByIdService @"api/v1/account/getMemberById?"
#define kGetAlertsWithPagingService @"api/v1/alerts?"
#define kSaveAlertService @"api/v1/alerts?"
#define kStopStreamingService @"api/v1/alerts/stopStreaming?"
#define kUploadUserPictureService @"api/v1/account/profilePic?"
#define kUploadMultimediaBaseURL @"http://52.221.45.167:3240"
#define kUploadMultimediaService @"api/v1/uploadfile"

#define kGetSettingsService @"api/v1/settings?"
#define kSignInService @"api/v1/account/signin"
//#define kSignInService @"http://192.168.102.20:3500/api/v1/account/signin"
#define kSignOutService @"api/v1/account/signOut"
#define kSignUpService @"api/v1/account/signup"
#define kAcknowledgedNewAlertsService @"api/v1/alerts/acknowledge?"
#define kAcknowledgedReadAlertService @"api/v1/alerts/markAsRead?"
#define kLocationHideByMemberService @"api/v1/account//locationHideByMember"
#define kAddEmergencyService @"api/v1/account/AddEmergencyContact"
#define kSMSActivateService @"api/v1/account/activate?"
#define kGetEmergencyService @"api/v1/account/getEmergencyContact?"
#define kForceSignOutService @"api/v1/account/forceSignOut"
#define kRemoveEmergencyService @"api/v1/account/deleteEmergencyContact"
#define kChangePasswordService @"api/v1/account/changePassword?"
#define kResetPasswordService @"api/v1/account/resetPassword"
#define kActiveInactiveMemberService @"api/v1/account/memberStatus?"
#define kAddBoundaryService @"api/v1/account/addBoundary"
#define kGetBoundaryService @"api/v1/account/getUserWiseBoundary?user_id="
#define kDeleteBoundaryService @"api/v1/account/deleteBoundary"
#define kUpdateBoundaryService @"api/v1/account/updateBoundary"
#define kDeviceRegister @"api/v1/account/notification/register"
#define kAddUserWacth @"api/v1/watch/addUserWatch"
#define kInActiveUserWacth @"api/v1/watch/inactiveUserWatch"
#define kresendActionCode @"api/v1/account/resendUserActivationCode"
#define kStopListeningAlert @"api/v1/alerts/stopListening"
#define kAllUserPackages @"api/v1/package/getAllUserPackagesByGuardian?"

#define kSaveDeviceUsagesService @"api/v1/devices/usages"
#define kGetDeviceUsagesService @"api/v1/devices/usages?"

//---Location Services---//
//#define kLocationServerBaseURL @"http://192.168.102.38:3300" //Local Server
#define kLocationServerBaseURL @"http://35.167.140.127:3300"


#define kReceiveLocationDataService @"receiveLocationData"
#define SAVE_LOCATION_DATA_SERVICE @"saveLocationData"
#define GET_LOCATION_DATA_SERVICE @"receiveLocationData"

//---IceCast configuration---//
#define kIceCast_IpAddressValue @"52.52.126.218"
#define kIceCast_PortValue @"8000"
#define kIceCast_UserIdValue @"source"
#define kIceCast_PasswordValue @"radioS1zip"//"hackme"
#define kIceCast_CodeStorageValue @"audio/mpeg"
#define kIceCast_BitRateValue @"44100"

//---HTTP Request---//
#define kRequestTimeOut 40.0f
//---Post/Save Location---//
#define kSaveLocationInterval 15.0f

extern NSString * const BAD_REQUEST;
extern NSString * const UNAUTHORIZED;
extern NSString * const UNKNOWN;

extern NSString * const HANDLE_REPLY_OPERATOR;

//extern NSString * const LOAD_CAMERA_ERROR_MSG;
extern NSString * const kUserInforKey;
extern NSString * const kUserInforValue;
extern NSString * const kNetworkErrorDomain;
extern int const kNetworkErrorStatusCode;
//#define kClosePopUpViewCode 999

#define kTokenKey @"Authorization"
#define kApp_id_Key @"app_id"
#define kCreated_user @"created_user"
#define kLink @"link"

#define kAlert_type @"alert_type"
#define kAlert_type_OfflinePanic @"0"
#define kAlert_type_panic @"1"
#define kAlert_type_stop @"110"
#define kAlert_type_roleChange @"3"
#define kAlert_type_bounday_touched @"4"
#define kAlert_type_bounday_unTouched @"5"
#define kAlert_type_silent_audio_streaming_on @"101201"
#define kAlert_type_silent_audio_streaming_off @"101200"
//#define kAlert_type_videoStreamingStop @"1010"
#define kAlert_type_videoStreaming @"1011"
#define kAlert_type_audioStreaming @"1012"
#define kAlert_type_audioStreamingStop @"1013"
#define kAlert_type_acknowledge_alert @"2000"
#define kAlert_type_stop_listening @"1015"
#define kAlert_type_chat @"chatNotification"
#define kAlert_type_other @"otherAlert"
#define kcontactid @"contact_id"
#define kIsSendSMS @"isSendSMS"
#define acknowledge_message_key @"acknowledge_message"

#define kNotification_message_title @"message_title"
#define kNotification_massage_body @"massage_body"
#define kPayload @"payload";
#define kPushNotificationType @"type";

#define kFileTitleKey @"FileTitle"
#define kFileContentKey @"FileContent"
#define kFileTypeIdKey @"FileTypeId"
#define kFileExtensionKey @"FileExtension"
#define kUserIdCamelLetterKey @"UserId"
#define kUserNameCamelLetterName @"UserName"

//---GetAlerts Key---//
#define kFamily_id_key @"family_id"
#define kUser_id_key @"user_id"
#define kUserid_key @"userid"
#define kNextPage_key @"nextPage"
#define kAlert_id_key @"alert_id"
#define kNext_key @"next"
#define kMetadata_key @"metadata"
#define kNew_key @"new"
#define kIsLocationHide_key @"is_location_hide"
#define kOldPassword_key @"old_password"
#define kNewPassword_key @"new_password"
#define kDevice_id @"device_id"
#define kReg_token @"reg_token"
#define kWatch_id @"watch_id"
#define kBattery_percent @"battery_percent"
#define kIs_battery_charging @"is_battery_charging"
    ///
#define kLocationKey @"location"
#define klatitudeKey @"lat"
#define kLongitudeKey @"lng"
#define kResourceTypeKey @"resource_type"
#define kBoundaryIdKey @"boundary_id"
#define kothersKey @"others"
//UploadPicture
#define kFormat_key @"format"
#define kImage_data_key @"image_data"
//sendSMS
#define kContactNo @"contactNo"
//Json Key
#define kResultKeyCapitalStart @"Result"
#define kResultKeySmallStart @"result"
#define JSON_KEY @"json"
# define WHAT_KEY @"what"
# define WHEN_KEY @"when"
# define OBJ_KEY @"obj"
# define kLocationPostSuccessKey @"success"
//getLocationService Key
#define kQueriesKey_GetLocation @"queries"
#define kResultsKey_GetLocation @"results"
#define kResultsetKey @"resultset"
#define kRemainingTrialPeridKey @"remainingTrialPerid"
#define kTrialPeriodMsgKey @"trialPeriodMsg"

#define kTagsKey_GetLocation @"tags"
#define kIdKey_GetLocation @"id"
#define kNameKey_GetLocation @"name"
#define kValuesKey_GetLocation @"values"
#define kLatitudeKey_GetLocation @"latitude"
#define kLongitudeKey_GetLocation @"longitude"

#define kPasswordKey @"password"
#define kDeviceTypeKey @"deviceType"
#define kDeviceNoKey @"deviceNo"
#define kNotifyMeByKey @"notify_me_by"
#define kCodeKey @"code"
#define USER_ID_KEY @"Id"
#define USER_ID_FULL_KEY_SMALL @"userId"
#define USER_ID_FULL_KEY_CAPITAL @"UserId"
#define FIRST_NAME_KEY @"FirstName"
#define LAST_NAME_KEY @"LastName"
#define SESSION_TOKEN_KEY @"SessionToken"
#define FIRST_NAME_KEY_SMALL @"firstName"
#define LAST_NAME_KEY_SMALL @"lastName"
//#define SESSION_TOKEN_KEY_SMALL @"sessionToken"

//---For Guardian Signup and Member Signup---//
#define kIdentifier @"id"
#define kUserFirstName @"first_name"
#define kUserLastName @"last_name"
#define kAge @"age"
#define kUserGender @"gender"
#define kUserAddrress @"address"
#define kUserContact @"contact"
#define kListOrder @"list_order"
#define kUserEmail @"email"
#define kUserName @"user_name"
#define kPassword @"password"
#define kUserRole @"role"
#define kGuardianId @"guardian_id"
#define kDateOfBirth @"date_of_birth"
#define kSettings @"settings"
#define kGuardianSettings @"guarduian_settings"
#define kRelationship @"relation"
#define kUserContactName @"contact_name"
#define kIsActive @"is_active"
#define kBoundaryName @"boundary_name"

//---User Signup Response Key---//
#define kMessageKey @"message"

//Keys for IM
#define kMsgKey @"msg"
#define kSenderKey @"sender"
#define kSenderNameKey @"senderName"
#define kMsgTypeKey @"type"
#define kGroupChatKey @"groupchat"
#define kTimeKey @"time"
#define kTimeStampKey @"timestamp"
#define kStatusKey @"status"
#define kMsgLogKey @"msgLog"
#define kOfflineMsgKey @"OfflineMessages"
#define kUnseenKey @"unseen"
#define kMsgCountKey @"msgCount"
#define kMsgTimeKey @"msgTime"
#define kUnseenUserMsgLog @"unseenUserMsgLog"
#define kBadgeCount @"badgeCount"
#define kLastMessageKey @"LastMessage"
#define kMSG_TYPE_KEY @"msgType"
#define kMSG_TYPE_TEXT @"msgTypeText"
#define kMSG_TYPE_PHOTO @"msgTypePhoto"
#define kMSG_TYPE_VIDEO @"msgTypeVideo"

#define kResourceUrlLocalKey @"resourceUrlLocal"
#define kResourceUrlRemoteKey @"resourceUrlRemote"
//---multimedia chat---//
#define kMsgResourceTypeKey @"resourcetype"
#define kMsgResourceText @"txt"
#define kMsgResourcePhoto @"img"
#define kMsgResourceAudio @"audio"
#define kMsgResourceVideo @"video"

#define kPhotoUrlLocalKey @"photoUrlLocal"
#define kPhotoUrlRemoteKey @"photoUrlRemote"
#define kVideoUrlRemoteKey @"videoUrlRemote"
#define kVideoUrlLocalKey @"videoUrlLocal"
#define kThumbnailWidth 200
#define kThumbnailHeight 200
//---TableCell Height--//
#define kAlertTableCellHeight 80

//Generic Key
#define Kcreated_at @"created_at"
#define kCreatedBy @"CreatedBy"
#define kUpdatedBy @"UpdatedBy"
#define kUpdatedDateTime @"UpdatedDate"
#define kStatusCapital @"Status"

//Settings
#define kSettingsType_switch @"switch"


//---Story Board Key---//
#define MAIN_STORYBOARD_KEY @"Main"
#define LOGIN_VIEW_CONTROLLER_KEY @"LoginViewController"
#define MEMBER_SIGNUP_VIEW_CONTROLLER_KEY @"MemberSignUpViewController"
#define HOME_VIEW_CONTROLLER_KEY @"HomeViewController"
#define MENU_VIEW_CONTROLLER_KEY @"MenuViewController"
#define REGISTRATION_SUCCESSFUL_VIEW_CONTROLLER_KEY @"RegistrationSuccessfulViewController"
#define MEMBER_REGISTRATION_SUCCESSFUL_VC_KEY @"MemberRegistrationSuccessfulVC"
#define MEMBER_CONTROL_TVC_KEY @"MemberControlTableViewController"
#define LOCATION_HISTORY_VC_KEY @"LocationHistoryViewController"
#define FAMILY_MEMBER_VIEW_CONTROLLER_KEY @"FamilyMemberListViewController"
#define UPDATE_PROFILE_VIEW_CONTROLLER_KEY @"UpdateProfileViewController"
#define SURROUND_APPS_VIEW_CONTROLLER_KEY @"SurroundAppsViewController"
#define USER_DETAILS_VIEW_CONTROLLER_KEY @"UserDetailsViewController"
#define EMERGENCY_CONTACT_VIEW_CONTROLLER_KEY @"EmergencyContactViewController"
//---Cell Identifier Key---//
#define GENDER_CELL_IDENTIFIER_KEY @"GenderCellIdentifier"
//#define MENU_CELL_IDENTIFIER_KEY @"MenuCellIdentifier"
#define MENU_CELL_IDENTIFIER_KEY @"MenuTableViewCell"
#define MEMBER_CELL_IDENTIFIER_KEY @"MemberCellIdentifier"
#define MEMBER_CONTROL_CELL_IDENTIFIER_KEY @"MemberControlCell"

//View Controller Title Key in Bangla
#define HOME_PAGE_TITLE_KEY @"Home"//"হোম পেজ"
#define NOTIFICATION_PAGE_TITLE_KEY @"Notification"//"সাইন আপ"
#define SIGN_UP_PAGE_TITLE_KEY @"Signup"//"সাইন আপ"
#define CONTROL_MEMBER_KEY @"Manage Members"//"সদস্য নিয়ন্ত্রণ"
#define CREATE_MEMBER_PAGE_TITLE @"Add New Family Member"//"পারিবারিক সদস্য তৈরী"
#define LOGIN_PAGE_TITLE @"Login"//লগইন
#define EMERGENCY_CONTACT_PAGE_TITLE @"Emergency Contact"//

//LOGIN FAILED MESSAGE

#define CHANGE_PASSWORD_ERROR @"Change password error"
#define CONFIRM_USER_NAME_PASSWORD_KEY @"Please confirm username or password"
#define LOGIN_ERROR @"Login Error! Please try later"
#define SIGNUP_ERROR @"Signup Error! Please try again"//সদস্য সাইন আপ ত্রুটি! অনুগ্রহ করে আবার চেষ্টা করুন
#define INTERNAL_SERVER_ERROR @"Internal Server Error"
#define INTERNET_CONNECTION_ERROR @"Please connect to internet!"

#define SIGNUP_MEMBER_ERROR @"Member Signup Error!Please try again"
#define UPDATE_SETTING_ERROR @"Setting Update Error!Please try again"
#define PROFILE_UPDATE_ERROR @"Profile Update Error! Please try again"
#define kPayloadDictError @{@"userInfo":@"Error in payload"}
#define TRY_AGAIN @"Try again"
//Alert Button Title
#define LOCATION_SERVICE_DISABLE_TITLE @"Location Services Disabled"
//#define LOCATION_DATA_UNAVAILABLE_TITLE @"Location Data Unavailable"
#define LOCATION_SERVICE_DISABLE_TEXT @"You currently have all location services for this device disabled"
#define LOCATION_SERVICE_ENABLE_TITLE @"Enable Location Service"
#define LOCATION_SERVICE_ENABLE_TEXT @"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services"
#define BACKGROUND_APP_REFRESH_DENIED @"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
#define BACKGROUND_APP_REFRESH_DISABLED @"The functions of this app are limited because the Background App Refresh is disable."
#define CHECK_NETWORK_CONNECTION_TITLE @"Network Error"
#define CHECK_NETWORK_CONNECTION_TEXT @"Please check your network connection."
#define OK_BUTTON_TITLE_KEY @"OK"
#define DONE_BUTTON_TITLE_KEY @"Done"
#define CANCEL_BUTTON_TITLE_KEY @"Cancel"
#define DELETE_BUTTON_TITLE_KEY @"Delete"

//---Progress Hud Title---//
#define LOGIN_TEXT @"Login..."
#define FORCE_SIGNOUT_TEXT @"Force logout..."
#define SIGNUP_TEXT @"SignUp..."//সাইনআপ
#define MEMBER_SIGNUP_TEXT @"Add Member..."
#define SETTINGS_TEXT @"Update Settings..."//"সেটিংস হালনাগাদ"
#define UPDATE_TEXT @"Updating..."//হালনাগাদ...
#define LOADING_INFO_TEXT @"Loading..."//হালনাগাদ...
#define CHANGE_PASSWORD_INFO_TEXT @"changePassword..."
#define RESET_PASSWORD_INFO_TEXT @"Reset password..."
#define ADD_BOUNDARY_TEXT @"Add boundary"
#define RESEND_EMALI_INFO_TEXT @"Re-send emali..."
#define RESEND_ACTIVATION_CODE @"Resend activation code"
#define LOGOUT_TEXT @"Logout"
//Navigation
//TableView

//Font
#define FONT_TEXT @"font"
#define AVENIR_FONT_TEXT @"Avenir Next"
#define fontMacro(_name_, _size_) ((UIFont *)[UIFont fontWithName:(NSString *)(_name_) size:(CGFloat)(_size_)])
#define fontRefMacro(_name_, _size_) CTFontCreateWithName((__bridge CFStringRef)(NSString *)(_name_), (CGFloat)(_size_), NULL)
#define rateingcolor [UIColor colorWithRed:0.753 green:0.855 blue:0.929 alpha:1.000]

//Date Format
#define kDateFormate @"YYYY MMM dd "

//System Version
#define SYSTEM_VERSION ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS8_OR_ABOVE                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))

//--Color Code RGB & Hexa Color Code ---//
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define SYSTEM_NAV_COLOR @"#3DB876"//#3CB878
#define WHITE_BACKGROUND_COLOR @"#F0F8F1"
#define MENU_BACKGROUND_COLOR @"#82CA9C"
#define COMMON_BACKGROUND_COLOR @"#F1F8F0"


//---Font Family---//
#define ROBOTOREGULAR(sizet) [UIFont fontWithName:@"Roboto-Regular" size:sizet]
#define ROBOTOBOLD(sizet) [UIFont fontWithName:@"Roboto-Bold" size:sizet]

//signIn
#define IS_ACTIVATION_CODE_NOT_VERIFIED @"isActivateCodeVerified"
#define USER_DATA @"UserData"
#define USER_DICTIONARY @"UserDictionary"
#define BOUNDARY_TOUCH_DATA @"boundaryTouchData"

// autoLogin
#define AUTOLOGIN @"autoLogin"
#define AUTOLOGIN_BODY @"autoLogin_body"
#define AUTOLOGIN_STATUS @"autoLogin_Status"

//--- Bangla String ---//
#define NULL_KEY @"(null)"
#define USER_NAME_PLACEHOLDER_TEXT @"User Name"//"আইডি"
#define ACTIVATION_CODE_PLACEHOLDER_TEXT @"Enter Your Sms Activation Code"//"আইডি"
#define PASSWORD_PLACEHOLDER_TEXT @"Password"//"পাসওয়ার্ড"
#define NAME_PLACEHOLDER_TEXT @"Name"//"নাম"
#define FIRST_NAME_PLACEHOLDER_TEXT @"নামের প্রথম অংশ"
#define LAST_NAME_PLACEHOLDER_TEXT @"নামের শেষ অংশ"
#define ADDRESS_PLACEHOLDER_TEXT @"ঠিকানা"
#define ADDRESS_PLACEHOLDER_TEXT @"ঠিকানা"
#define MOBILE_PLACEHOLDER_TEXT @"Mobile"//"মোবাইল"
#define EMAIL_PLACEHOLDER_TEXT @"Email"//"ইমেইল"
#define PROFILE_TITLE_TEXT @"Profile"//"প্রোফাইল"
#define PROFILE_SUBTITLE_TEXT @"Manage Your Information"//"আপনার তথ্য নিয়ন্ত্রণ করুণ"
#define CONFIGURE_MEMBER_TITLE_TEXT @"Manage Members"//"সদস্য নিয়ন্ত্রণ"
#define CONFIGURE_MEMBER_SUBTITLE_TEXT @"Manage Your Family Member"//"আপনার পারিবারিক সদস্য নিয়ন্ত্রণ করুণ"
#define SURROUND_APPS_TITLE_TEXT @"Surroundapps"//"সারাউন্ড অ্যাপস"
#define SURROUND_APPS_SUBTITLE_TEXT @"Other Surroundapps"//"অন্যান্য সারাউন্ড অ্যাপস"
#define LOGOUT_BUTTON_TITLE_TEXT @"Logout"//"লগ আউট"
#define LOGOUT_BUTTON_SUBTITLE_TEXT @"Exit From App"//"অ্যাপস থেকে প্রস্থান করুণ"
#define PAIR_DEVICE_BUTTON_TITLE_TEXT @"Pair Device"
#define PAIR_BUTTON_SUBTITLE_TEXT @"Pair Your Device"

#define UN_PAIR_DEVICE_BUTTON_TITLE_TEXT @"Unpair Device"
#define UN_PAIR_BUTTON_SUBTITLE_TEXT @"Unpair Your Device"

#define BATTERY_BUTTON_TITLE_TEXT @"Battery"
#define BATTERY_BUTTON_SUBTITLE_TEXT @"Battery Status"

//silentStreamingOption
#define SILENT_STREAMING_BUTTON_TITLE_TEXT @"Silent Remote Streaming"
#define SILENT_STREAMING_BUTTON_SUBTITLE_TEXT @"Silent Remote Streaming Control"

#define OLD_PASSWORD_PLACEHOLDER_TEXT @"Old password"
#define NEW_PASSWORD_PLACEHOLDER_TEXT @"New password"

#define EMERGENCY_CONTACT_BUTTON_TITLE_TEXT @"Emergency Contact"//
#define EMERGENCY_CONTACT_BUTTON_SUBTITLE_TEXT @"Set emergency contacts"
//Setting Menu
#define SETTINGS_BUTTON_TEXT @"Panic Settings"
#define SETTINGS_BUTTON_SUBTITLE_TEXT @"Personalize your app"

//PRICING
#define PRICING_BUTTON_TEXT @"Account Status"
#define PRICING_BUTTON_SUBTITLE_TEXT @"Account details"

//--Member Signup--//
#define BIRTHDAY_PLACEHOLDER_TEXT @"জন্ম তারিখ"
#define GENDER_PLACEHOLDER_TEXT @"Gender"//"লিঙ্গ"
//#define MONTH_PLACEHOLDER_TEXT @"মাস"
//#define YEAR_PLACEHOLDER_TEXT @"সাল"
#define SURROUND_HOME_TITLE_TEXT @"Home"//"হোম"
#define SURROUND_HOME_SUBTITLE_TEXT @"Details"//"বিস্তারিত"
#define GENDER_MALE @"Male"//"পুরুষ"
#define GENDER_FAMEL @"Female"//"স্ত্রী"

#define LANGUAGE_BANGLA @"Bangla"//"পুরুষ"
#define LANGUAGE_ENGLISH @"English"//"স্ত্রী"

#define  SMS @"SMS"
#define MAIL @"Mail"

//---Notification Key---//
#define kSeenMsgNotification @"seenMsgNotification"
#define kSeenGroupMsgNotification @"seenGroupMsgNotification"

//---Address---//
#define kLocationLatitude @"Latitude"
#define kLocationLongitude @"Longitude"
#define kLocationAccuracy @"TheAccuracy"
#define kLocationAltitude @"TheAltitude"
#define kLocationLatitudeSmall @"latitude"
#define kLocationLongitudeSmall @"longitude"

//---Image Name---//
#define USER_PROFILE_PLACEHOLDER @"user_placeholder"
#define MENU_ICON @"MenuIcon"
#define HOME_FOOTER_BACKGROUND_ICON @"HomePageFooter"
#define ALAP_ICON @"Alap-icon"
#define PANIC_ALERT_ICON @"Panic-Icon"
#define USER_CONTROL @"User-Control-Menu-Item"
#define EMERGENCY_MENU_ITEM @"emergency_Menu_Item"
#define SETTTINGS_MENU_ITEM @"Setting_Menu_Item"
#define PAYMENT_MENU_ITEM @"Payment_Menu_item"
#define USER_PROFILE @"User-Profile-Menu-Item"
#define TEXT_FIELD_ACTIVE @"TextField_BG_Active"
#define TEXT_FIELD_INACTIVE @"TextField_BG_Inactive"
#define BACK_ICON @"Back-Icon"
///
#define HomeMeneIcon @"home-icon"
#define LogoutMeneIcon @"logout-icon.png"

//Chat
//#define EJABBER_HOST_NAME @"35.161.244.20"
//#define EJABBER_DOMAIN_NAME @"familytracker.com"

#define kChatKey @"chat"
#define kChatRoomKey @"room"
#define kChatHostKey @"host"
#define kChatIPKey @"ip"

//settings
#define kGuardianPermission @"1000"
#define kLocationHide @"1001"
#define kChatPostPermission @"1002"
#define kPanicAlertPermission @"1003"
#define kPanicCountdown @"1004"
#define kPanicResourceType @"1005"
#define kAlertType_TimeOut @"1013"
///
#define kPanicResource_video @"Video"
#define kPanicResource_audio @"Audio"
#define kPanicResource_sms @"SMS"
#define kPanicResource_snapShot @"SnapShot"
#define kPanicResource_none @"None"

#define kIdentifireFullName @"identifire"

//---Language change Key
#define DEFAULT_LANGUAGE @"defaultLanguage"
#define BANGLA_LANGUAGE @"bn"
#define ENGLISH_LANGUAGE @"en"

#define kAlertResourceTypeOffline @"0"
#define kAlertResourceTypeVideo @"1"
#define kAlertResourceTypeAudio @"2"
#define kAlertResourceTypeSnapShot @"3"
#define kAlertResourceTypeSMS @"4"
#define kAlertResourceTypeBoundary @"5"
// offline tracking
#define IS_OFFLINE_MESSAGE_STORE @"isOffLineMessageStore"
#define IS_UPDATED_CONTACTLIST @"isUpdatedContactList"
#define IS_OFFLINE_CONTACT_STORE @"isOffLineContactStore"
#define IS_OFFLINE_IMAGE_CHANGE @"isImageOfflineChange"
#define OFFLINE_IMAGE_64_STRING @"OFFLINE_IMAGE_64_STRING"
#define OFFLINE_IMAGE_DATA @"OFFLINE_IMAGE_DATA"

// sqlite3 constant
#define k_Db_Name @"FamilyTracker.db"
#define k_Db_MessageTable @"messageTable"
#define k_Db_Id @"Id"
#define k_Db_MessageBody @"message"
#define k_Db_Status @"status"
#define k_Db_List_Order @"list_order"
#define k_Db_CurrentDateAndTime @"currentDateAndTime"
#define k_Db_chatWithUser @"chatWithUser"
// emergency contact
#define k_Db_EmergencyContactTable @"emergencyContactTable"
#define k_Db_ContactName @"contactName"
#define k_Db_ContactNumber @"contactNumber"
#define k_Db_ContactNumberServerId @"contactNumberServerId"
#define k_Db_ContactPic @"contactPic"

#define k_Db_EmergencyRemoveContactTable @"emergencyRemoveContactTable"
// post location
#define k_Db_PostLocationTable @"postLocation"
#define k_Db_Latitude @"latitude"
#define k_Db_Longitude @"longitude"
#define K_Db_timeStamp @"timeStamp"

// post offlineMsg
#define k_Db_PostPanicTable @"postPanicTable"
#define k_Db_PanicResourceType @"PanicResourceType"
#define k_Db_PanicType @"PanicType"
#define k_Db_smsTextMsg @"smsTextMsg"
#define kIsOfflineUserInfoUpdated @"isOfflineUserInfoUpdated"

#define kPhotoAlbum @"Photo Album"
#define kCamera @"Camera"
#define kCancel @"Cancel"

// firebase token
#define kFirebaseToken @"firebaseToken"
#define IsFirebaseTokenRegSuccess @"isFirebaseTokenRegSuccess"

// boundary
#define kMemberIndexOnBoundary -999
#define QR_CODE_PLACEHOLDER_TEXT @"Manually Input QR Id"

#define kDrawBoundaryTutorial @"drawBoundaryTutorail"
@end
