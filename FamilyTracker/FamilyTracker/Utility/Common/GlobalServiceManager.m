 //
//  GlobalServiceManager.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/27/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "GlobalServiceManager.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "FamilyTrackerOperate.h"
#import "ChatViewController.h"
#import "AudioViewController.h"
#import "StreamingVC.h"
#import "AudioPlayerVC.h"
#import "HomeViewController.h"
#import "DbHelper.h"
#import "NSString+Utils.h"
#import "ChatManager.h"
#import "CacheSlide.h"
#import "JsonUtil.h"
#import "Reachability.h"

@implementation GlobalServiceManager

static GlobalServiceManager *instance = nil;
- (instancetype)init {
    if (self = [super init]) {
        _modelManager = [ModelManager sharedInstance];
        internetConnectionStatus = 0;
        sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [self initService];
    }
    return self;
}

+ (GlobalServiceManager *)sharedInstance {
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}

#pragma mark - Global Methods

- (void)gotoChatViewController {
    if (![[GlobalData sharedInstance].currentVC isKindOfClass:[ChatViewController class]]) {
        ChatViewController *chatViewController = [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
        chatViewController.chatWithUser = [GlobalData sharedInstance].roomName;
        [[GlobalData sharedInstance].currentVC.navigationController pushViewController:chatViewController animated:YES];
    }else if([[GlobalData sharedInstance].currentVC isKindOfClass:[ChatViewController class]]) {
        ChatViewController *chatViewController = (ChatViewController*)[GlobalData sharedInstance].currentVC;
        [chatViewController reloadTableData];
    }
}

- (void)gotoPlayAudioStream:(NSString *)urlStr andId:(NSString *)alertId{
    if (![[GlobalData sharedInstance].currentVC isKindOfClass:[AudioPlayerVC class]]) {
        AudioPlayerVC *audioStreamingVC = [sb instantiateViewControllerWithIdentifier:@"AudioPlayerVC"];
        audioStreamingVC.url = [NSURL URLWithString:urlStr];
        audioStreamingVC.alertId = alertId;
        [[GlobalData sharedInstance].currentVC.navigationController pushViewController:audioStreamingVC animated:YES];
    }
}

- (void)gotoPlayVideoStream:(NSString *)urlStr {
    if (![[GlobalData sharedInstance].currentVC isKindOfClass:[StreamingVC class]]) {
        UIStoryboard *sbPlayer = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
        StreamingVC *streamingVC = [sbPlayer instantiateViewControllerWithIdentifier:@"StreamingVC"];
        streamingVC.myTagValue = 0;
        streamingVC.url = [NSURL URLWithString:urlStr];
        streamingVC.isONVIFPlayer = NO;
        streamingVC.xAddr = @"";
        streamingVC.username = @"";
        streamingVC.password = @"";
        streamingVC.ptzProfileToken = @"";
        streamingVC.isCameraPTZCapable = NO;
        streamingVC.isShowPTZView = NO;
        [[GlobalData sharedInstance].currentVC.navigationController pushViewController:streamingVC animated:YES];
    }
}

- (NSDictionary *)getMemberSettingsById:(NSString *)memberId {
    for (MemberData *member in [ModelManager sharedInstance].members.rows) {
        if ([member.identifier isEqualToString:memberId]) {
            return member.settings;
        }
    }
    return nil;
}

#pragma mark - User Defined Methods -
- (void)initService {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    //Initialize Service CallBack Handler
    ReplyHandler * _handler = [[ReplyHandler alloc]
                               initWithModelManager:_modelManager
                               operator:nil
                               progress:nil
                               signupUpdate:nil
                               addMemberUpdate:nil
                               updateUserUpdate:(id)self
                               settingsUpdate:nil
                               loginUpdate:nil
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:(id)self
                               getLocationUpdate:nil
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:(id)self
                               getAlertUpdate:(id)self
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}

- (void)acknowledgeNewAlertService {
    if ([_modelManager.totalNewAlerts integerValue] > 0) {
        _modelManager.totalNewAlerts = [NSNumber numberWithInt:0];
        //---Stop Panic Alert---//
        //        [_audioController tryStopMusic];
        NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                      kUser_id_key:_modelManager.user.identifier
                                      };
        requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:ACKNOWLEDGE_NEW_ALERTS],
                           WHEN_KEY:[NSDate date],
                           OBJ_KEY:requestBody
                           };
        [_serviceHandler onOperate:requestBodyDic];
    }
}

- (void)acknowledgedReadAlertService:(NSString *)notificationId {
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kUser_id_key:_modelManager.user.identifier,
                                  kAlert_id_key:notificationId
                                  };
    requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:ACKNOWLEDGE_READ_ALERT],
                       WHEN_KEY:[NSDate date],
                       OBJ_KEY:requestBody
                       };
    [_serviceHandler onOperate:requestBodyDic];
}

- (void)stopStreamingService {
    if (_modelManager.liveStreamingAlert.identifier == nil ||
        [_modelManager.liveStreamingAlert.identifier isEqual:(id)[NSNull null]]) {
        //
    }else {
        NSDictionary *requestDataDic = @{kTokenKey:_modelManager.user.sessionToken,
                                         kFamily_id_key:_modelManager.liveStreamingAlert.familyId,
                                         kCreated_user:_modelManager.liveStreamingAlert.createdUser,
                                         //kLink:_modelManager.liveStreamingAlert.link,
                                         kAlert_type:_modelManager.liveStreamingAlert.alertType,
                                         kResourceTypeKey: _modelManager.liveStreamingAlert.resourceType,
                                         kIdentifier:_modelManager.liveStreamingAlert.identifier};
        
        requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:STOP_STREAMING],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:requestDataDic
                                         };
        [_serviceHandler onOperate:requestBodyDic];
    }
}


- (void)stopListeningalertService:(NSString *)notificationId{
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:STOP_LISTENING_ALERT],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kCreated_user:_modelManager.user.identifier,
                                           kFamily_id_key:_modelManager.user.guardianId,
                                           kIdentifier:notificationId,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)getEmergencyContactService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_modelManager.user.identifier,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

//- (void)logOutService {
//    NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSDictionary *requestDataDic = @{WHAT_KEY:[NSNumber numberWithInteger:SIGN_OUT],
//                         WHEN_KEY:[NSDate date],
//                         OBJ_KEY:@{kTokenKey:_modelManager.user.sessionToken,
//                                   kUser_id_key:_modelManager.user.identifier,
//                                   kDeviceTypeKey:@"ios",
//                                   kDeviceNoKey:deviceUUID}
//                         };
//    [_serviceHandler onOperate:requestDataDic];
//}

#pragma - mark sendOffLine Message
- (void)sendOffLineMessage {
    NSMutableArray * allMessageArray = [[NSMutableArray alloc] init];
    allMessageArray = [[DbHelper sharedInstance] getAllOffLineMessage];
    NSLog(@"%lu",(unsigned long)[allMessageArray count]);

    for(NSMutableArray * arrayElement in allMessageArray) {
    //        NSLog(@"%@",[arrayElement valueForKey:@"Id"]);
            NSString * ID = [arrayElement valueForKey:k_Db_Id];
            NSString * messageBody = [arrayElement valueForKey:k_Db_MessageBody];
            NSString * dateAndTime = [arrayElement valueForKey:k_Db_CurrentDateAndTime];
            NSString * chatWithUser = [arrayElement valueForKey:k_Db_chatWithUser];
        //---Message Element-1---//
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageBody];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        ///<---Message Element-1---//
        //        [message addAttributeWithName:kMsgResourceTypeKey stringValue:kMsgResourceText];
        [message addAttributeWithName:kMsgTypeKey stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        //set date
        NSString *currentDateStr = dateAndTime;
        //[message addAttributeWithName:kTimeStampKey stringValue:currentDateStr];
        //        [message addAttributeWithName:kPhotoUrlLocalKey stringValue:@""];
        //        [message addAttributeWithName:kPhotoUrlRemoteKey stringValue:@""];
        //        [message addAttributeWithName:kVideoUrlLocalKey stringValue:@""];
        //        [message addAttributeWithName:kVideoUrlRemoteKey stringValue:@""];
        
        [message addChild:body];
        //[self.xmppStream sendElement:message];
        
        NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        
        NSXMLElement *time = [NSXMLElement elementWithName:@"name"];
        [time setStringValue:kTimeStampKey];
        [property addChild:time];
        
        NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
        [value addAttributeWithName:kMsgTypeKey stringValue:@"long"];
        [value setStringValue:currentDateStr];
        [property addChild:value];
        [properties addChild:property];
        [message addChild:properties];
        //--->Message Element-2---//
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        //        [m setObject:kMsgResourceText forKey:kMsgResourceTypeKey];
        [m setObject:[messageBody substituteEmoticons] forKey:kMsgKey];
        //        [m setObject:@"" forKey:kPhotoUrlLocalKey];
        //        [m setObject:@"" forKey:kPhotoUrlRemoteKey];
        //        [m setObject:@"" forKey:kVideoUrlLocalKey];
        //        [m setObject:@"" forKey:kVideoUrlRemoteKey];
        [m setObject:@"you" forKey:kSenderKey];
        [m setObject:@"you" forKey:kSenderNameKey];
        [m setObject:currentDateStr forKey:kTimeStampKey];
        //[messages addObject:m];
        [[GlobalData sharedInstance].messages addObject:m];
        ///<---Message Element-2---//
        [[ChatManager instance] sendMessage:message];
        // update table status in db
       [[DbHelper sharedInstance] updateStatus:ID andTableName:k_Db_MessageTable];
    }
    //reset Kmessage Table
    allMessageArray = [[NSMutableArray alloc] init];
    allMessageArray = [[DbHelper sharedInstance] getAllOffLineMessage];
    if([allMessageArray count] == 0) {
       BOOL isSuccess = [[DbHelper sharedInstance] resetSingleTable:k_Db_MessageTable];
        if(isSuccess) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_OFFLINE_MESSAGE_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma - mark removeEmergency contact 
- (void) removeEmergencyContactToOffLine {
   NSMutableArray * removeArray = [[NSMutableArray alloc] init];
    removeArray = [[DbHelper sharedInstance] getAllRemoveEmergencyContactFromSqlit:@" where status = 0"];
    for(int i= 0; i<removeArray.count; i++) {
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:REMOVE_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                           kcontactid:removeArray[i],
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
        [[DbHelper sharedInstance] updateStatusWithCondition:k_Db_EmergencyRemoveContactTable andcondition:[NSString stringWithFormat:@" %@ = %@",k_Db_ContactNumberServerId,removeArray[i]]];
    }
}

#pragma - mark syn emergency contact
- (void)synEmergencyContact {
    NSMutableArray * getNeedToSynContacts = [[NSMutableArray alloc] init];
    getNeedToSynContacts = [[DbHelper sharedInstance] getAllEmergencyContactFromSqlit:@" WHERE status = 0"];
    if (getNeedToSynContacts.count > 0) {
        for (NSMutableDictionary *row in getNeedToSynContacts) {
            NSNumber *contactOrderIndex = [NSNumber numberWithInt:[[row valueForKey:@"list_order"] intValue]];
//            NSArray * contactArray = [NSArray arrayWithObjects:[row valueForKey:@"contact"], nil];
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_EMERGENCY],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                               kUserContactName: [row valueForKey:@"contact_name"],
                                               kUserContact: [row valueForKey:@"contact"],
                                               kListOrder: contactOrderIndex,
                                               kTokenKey : _modelManager.user.sessionToken
                                               }
                                     };
            [_serviceHandler onOperate:newMsg];
        }
    }
}

#pragma - mark autoLogin
- (void)autoLoginPreLoading {
    [self lazyImageLoderForProfileImage];
    //read emergency contact list from  sqlite db start
    if(![[NSUserDefaults standardUserDefaults] boolForKey:IS_UPDATED_CONTACTLIST]) {
        [[DbHelper sharedInstance] resetSingleTable:k_Db_EmergencyContactTable];
        [self getEmergencyContactService];
    }else {
        NSError *error = nil;
        NSMutableArray * allContactFromSqlite = [[NSMutableArray alloc] init];
        allContactFromSqlite = [[DbHelper sharedInstance] getAllEmergencyContactFromSqlit:@""];
        _modelManager.emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
        NSArray *resultSetDic = allContactFromSqlite;
        for(NSDictionary * dic in resultSetDic) {
            EmergencyContactModel * emergencyContactModel = (EmergencyContactModel*)[[EmergencyContactModel alloc] initWithDictionary:dic error:&error];
            [_modelManager.emergencyContacts addObject:emergencyContactModel];
        }
    }
}

- (void)lazyImageLoderForProfileImage {
    NSString *imageUrl;
    if([[NSUserDefaults standardUserDefaults] boolForKey:IS_OFFLINE_IMAGE_CHANGE]) {
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:OFFLINE_IMAGE_DATA];
        UIImage* image = [UIImage imageWithData:imageData];
        [GlobalData sharedInstance].profilePicture = image;
        return;
        
    } else {
        imageUrl = _modelManager.user.profilePicture;
    }
    
    if (imageUrl == nil ||
        [imageUrl isEqual:(id)[NSNull null]] ||
        imageUrl.length < 1) {
    } else {
        CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
        NSURL *imageURL = [NSURL URLWithString:imageUrl];
        [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
            if ([type isEqualToString:@"image"]) {
                UIImage *image = (UIImage *)cachedSlide;
                if(image) {
                    [GlobalData sharedInstance].profilePicture = image;
                }
            } else {
                
            }
        } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
            NSLog(@"Image cache fail");
        }];
    }
}

#pragma - mark synchronized OffLine to OnLine
- (void)syncOfflineData {
    _modelManager.members = [JsonUtil loadObject:NSStringFromClass([Members class]) withFile:NSStringFromClass([Members class])];
    _modelManager.memberLocations = [JsonUtil loadObject:NSStringFromClass([MemberLocations class]) withFile:NSStringFromClass([MemberLocations class])];
    _modelManager.settings = [JsonUtil loadObject:NSStringFromClass([Settings class]) withFile:NSStringFromClass([Settings class])];
    _modelManager.notifications = [JsonUtil loadObject:NSStringFromClass([Notifications class]) withFile:NSStringFromClass([Notifications class])];
    _modelManager.members = [JsonUtil loadObject:NSStringFromClass([Members class]) withFile:NSStringFromClass([Members class])];
}

- (void)synchronizedOffLineToOnLine {
    if ([FamilyTrackerReachibility isUnreachable]) {
        return;
    }
    User *offLineUser = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:NSStringFromClass([User class])];
    if (offLineUser.sessionToken == nil ||
        [offLineUser.sessionToken isEqual:(id)[NSNull null]] ||
        offLineUser.sessionToken.length < 1) {
        return;
    }
    
    //---update service call for user info update in offline---//
    [self userInfoUpdatedFromOffline];
    //---check offline image change and posting to server---//
    BOOL isImageChange = [[NSUserDefaults standardUserDefaults] boolForKey:IS_OFFLINE_IMAGE_CHANGE];
    if (isImageChange) {
        NSString * imageDataIn64Bit = [[NSUserDefaults standardUserDefaults] valueForKey:OFFLINE_IMAGE_64_STRING];
        if(imageDataIn64Bit) {
            [self uploadProfilePictureService:imageDataIn64Bit];
        }
    }
    //---check and syncEmergencyContact that change in offline---//
    [self removeEmergencyContactToOffLine];
    [self synEmergencyContact];
    //---Check and call offline Panic service---//
    [self syncOfflinePanicService];
    //---Testing offline message send---//
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LoginToJabberServerNoti"
     object:nil];
    //---check offline save location and posting to server---//
    NSArray *locationsDic = [[DbHelper sharedInstance] getLocations:[NSString stringWithFormat:@"WHERE %@ = 0",k_Db_Status]];
    for (NSDictionary * row in locationsDic) {
        NSDictionary *locationDict = @{@"name":@"user", @"type":@"geolocation",@"datapoints":@[@[[row valueForKey:K_Db_timeStamp], @{@"latitude":[row valueForKey:k_Db_Latitude],@"longitude":[row valueForKey:k_Db_Longitude]}]], @"tags":@{@"id":_modelManager.user.identifier, @"name":_modelManager.user.userName}};
        
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInt:POST_LOCATION_DATA],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:locationDict
                                 };
        [_serviceHandler onOperate:newMsg];
        // update table status
        [[DbHelper sharedInstance] updateStatus:[row valueForKey:k_Db_Id] andTableName:k_Db_PostLocationTable];
        locationsDic = [[DbHelper sharedInstance] getLocations:[NSString stringWithFormat:@"WHERE %@ = 0",k_Db_Status]];
        if(locationDict.count == 0) {
            [[DbHelper sharedInstance] resetSingleTable:k_Db_PostLocationTable];
        }
    }
}

- (void)syncOfflinePanicService {
    //---Panic alert posing that made in offline---//
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSMutableArray * allPanicArray = [[NSMutableArray alloc] init];
    allPanicArray = [[DbHelper sharedInstance] getPanicService];
    for(NSDictionary * row in allPanicArray) {
        NSNumber *latitude = [NSNumber numberWithDouble:[[row valueForKey:klatitudeKey] doubleValue]];
        NSNumber *longitude = [NSNumber numberWithDouble:[[row valueForKey:klatitudeKey] doubleValue]];
        NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                      kFamily_id_key:guardianId,
                                      kCreated_user:_modelManager.user.identifier,
                                      kAlert_type:kAlert_type_OfflinePanic,
                                      kResourceTypeKey:kAlertResourceTypeOffline,
                                      Kcreated_at:[row valueForKey:Kcreated_at],
                                      kLocationKey:
                                          @{ klatitudeKey:latitude,
                                             kLongitudeKey:longitude
                                             }
                                      };
        requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                           WHEN_KEY:[NSDate date],
                           OBJ_KEY:requestBody
                           };
        [_serviceHandler onOperate:requestBodyDic];
        
        //---Update Table Status---//
        [[DbHelper sharedInstance] updateStatus:[row valueForKey:k_Db_Id] andTableName:k_Db_PostPanicTable];
        NSMutableArray *getPanicArray = [[DbHelper sharedInstance] getPanicService];
        if(getPanicArray.count == 0) {
            [[DbHelper sharedInstance] resetSingleTable:k_Db_PostPanicTable];
        }
    }
}

#pragma - mark ImageUpload service
- (void)uploadProfilePictureService:(NSString *)imageData64Bit {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    }else {
        //---Progress HUD---//
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_USER_PICTURE],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                           kTokenKey:_modelManager.user.sessionToken,
                                           kFormat_key:@"png",
                                           kImage_data_key:imageData64Bit,
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)userInfoUpdatedFromOffline {
    BOOL isOffline = [[NSUserDefaults standardUserDefaults] boolForKey:kIsOfflineUserInfoUpdated];
    if (isOffline) {
        User *user = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:@"OfflineUser"];
        NSMutableDictionary *bodyDic = [NSMutableDictionary new];
        NSString *guardianId = @"";
        if ([_modelManager.user.role integerValue] == 1) {
            guardianId = _modelManager.user.identifier;
        } else if (_modelManager.user.guardianId)  {
            guardianId = _modelManager.user.guardianId;
        }
        [bodyDic setObject:user.identifier forKey:kIdentifier];
        [bodyDic setObject:guardianId forKey:kGuardianId];
        [bodyDic setObject:user.userName forKey:kUserName];
        [bodyDic setObject:user.firstName forKey:kUserFirstName];
        [bodyDic setObject:user.lastName forKey:kUserLastName];
        if(user.gender == nil) {
            [bodyDic setObject:@"" forKey:kUserGender];
        } else {
            [bodyDic setObject:user.gender forKey:kUserGender];
        }
        [bodyDic setObject:user.contact forKey:kUserContact];
        [bodyDic setObject:user.email forKey:kUserEmail];
        [bodyDic setObject:user.dob forKey:kDateOfBirth];
        [bodyDic setObject:user.address forKey:kUserAddrress];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:bodyDic};
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Device Registration For Push Notification -
- (void)deviceRegistrationForPushNotification {
    NSString * token = [[NSUserDefaults standardUserDefaults] valueForKey:kFirebaseToken];
    if(token == nil || token.length == 0) {
        return;
    }
    NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:DEVICE_REGISTRATION],
                             WHEN_KEY:[NSDate date],
                             OBJ_KEY:@{
                                     kUser_id_key : _modelManager.user.identifier,
                                     kDevice_id : deviceUUID,
                                     kReg_token : token,
                                     kTokenKey : _modelManager.user.sessionToken
                                     }
                             };
    [_serviceHandler onOperate:newMsg];
}

#pragma mark - Service Response -
- (void)refreshUI:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sourceType == ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AlertBatchNotification"
             object:nil];
        }else if (sourceType == ACKNOWLEDGE_NEW_ALERTS_FAILED) {
            //            NSLog(@"ACKNOWLEDGE_NEW_ALERTS_FAILED");
        }
        else if (sourceType == ACKNOWLEDGE_READ_ALERT_SUCCCEEDED) {
            NSLog(@"ACKNOWLEDGE_READ_ALERT_SUCCCEEDED");
            
        }else if (sourceType == ACKNOWLEDGE_READ_ALERT_FAILED) {
            NSLog(@"ACKNOWLEDGE_READ_ALERT_FAILED");
        }if (sourceType == POST_LOCATION_DATA_FAILED) {
            //[Common displayToast:@"Location posting failed" title:nil duration:1.0];
        }else if (sourceType == POST_LOCATION_DATA_SUCCEEDED) {
            
        }
    });
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == STOP_STREAMING_SUCCEEDED) {// stop streaming
            [ModelManager sharedInstance].liveStreamingAlert = nil;
            //NSLog(@"STOP_STREAMING_SUCCEEDED");
        }else if(sourceType == STOP_STREAMING_FAILED) {
            //NSLog(@"STOP_STREAMING_FAILED");
        }else if(sourceType == GET_EMERGENCY_SUCCCEEDED) { // get emergency number
            NSError *error = nil;
            if (_modelManager.emergencyContacts == nil) {
                _modelManager.emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
            }else {
                [_modelManager.emergencyContacts removeAllObjects];
            }
            NSArray *resultSetDic = [object valueForKey:kResultsetKey];
            int count = 0;
            for(NSDictionary * dic in resultSetDic) {
                EmergencyContactModel * emergencyContactModel = (EmergencyContactModel*)[[EmergencyContactModel alloc] initWithDictionary:dic error:&error];
                // insert locally data
                [[DbHelper sharedInstance] insertEmergencyContact1:emergencyContactModel];
                [_modelManager.emergencyContacts addObject:emergencyContactModel];
                count++;
                if(count >= 3) {
                    break;
                }
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_UPDATED_CONTACTLIST];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if(sourceType == UPLOAD_USER_PICTURE_SUCCCEEDED ) { // profile updated success
            if (object[@"profile_pic"]) {
                //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_OFFLINE_IMAGE_CHANGE];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_OFFLINE_IMAGE_CHANGE];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_OFFLINE_IMAGE_CHANGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _modelManager.user.profilePicture = object[@"profile_pic"];
                [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
                [self lazyImageLoderForProfileImage];
            }
        }else if(sourceType == SAVE_ALERT_SUCCEEDED) {//---Save Alerts
            [Common displayToast:NSLocalizedString(@"Panic alert has been sent.", nil)  title:nil duration:1];
        }
        else if(sourceType == SAVE_ALERT_FAILED) {
            [Common displayToast:NSLocalizedString(@"Panic alert failed to send!", nil)  title:nil duration:1];
        } else if(sourceType == ADD_EMERGENCY_SUCCCEEDED) {
//            NSArray * contactArray = object[@"contact"];
//            NSLog(@"%@",contactArray[0]);
//            NSString * contact = [NSString stringWithFormat:@"%@",contactArray[0]];
            NSString * listOder = object[@"list_order"];
//            NSString * condition = [NSString stringWithFormat:@"%@ = %@ and %@ = %@",k_Db_List_Order,listOder,k_Db_ContactNumber,contact];
            NSString * condition = [NSString stringWithFormat:@"%@ = %@ ",k_Db_List_Order,listOder];
            EmergencyContactModel * model = [[EmergencyContactModel alloc] init];
            model.contactName = object[@"contact_name"];
            model.contactId = object[@"id"];
            model.contactArray = object[@"contact"];
            model.listOrder = listOder;
            for(int i = 0; i<_modelManager.emergencyContacts.count; i++) {
                EmergencyContactModel * contact = _modelManager.emergencyContacts[i];
                if([contact.listOrder isEqualToString:[NSString stringWithFormat:@"%@",listOder]]) {
                    contact.contactId = model.contactId;
                    _modelManager.emergencyContacts[i] = contact;
                    break;
                }
            }
            [[DbHelper sharedInstance] updateEmergencyContact:model];
            [[DbHelper sharedInstance] updateStatusWithCondition:k_Db_EmergencyContactTable andcondition:condition];
            
            NSMutableArray * getNeedToSynContacts = [[NSMutableArray alloc] init];
            getNeedToSynContacts = [[DbHelper sharedInstance] getAllEmergencyContactFromSqlit:@" WHERE status = 0"];
            if(getNeedToSynContacts.count == 0) {
                [[DbHelper sharedInstance] resetSingleTable:k_Db_EmergencyContactTable];
                [self getEmergencyContactService];
            }
            
        } else if (sourceType == UPDATE_MEMBER_SUCCEEDED) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsOfflineUserInfoUpdated];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else if(REMOVE_EMERGENCY_SUCCESS == sourceType) {
            NSMutableArray * array = [[DbHelper sharedInstance] getAllRemoveEmergencyContactFromSqlit:@" where status = 0"];
            if(array.count == 0) {
                [self getEmergencyContactService];
            }
            
        } else if(REMOVE_EMERGENCY_FAILED == sourceType) {
        }
        else if(sourceType == DEVICE_REGISTRATION_SUCCCEEDED) {
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IsFirebaseTokenRegSuccess];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"deviceRegistrationSucceded");
        } else if(sourceType == DEVICE_REGISTRATION_FAILED) {
            NSLog(@"DEVICE_REGISTRATION_FAILED");
            [[NSUserDefaults standardUserDefaults] setValue:@"-1" forKey:IsFirebaseTokenRegSuccess];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else if(sourceType == STOP_LISTENING_ALERT_SUCCCEEDED) {
            NSLog(@"STOP_LISTENING_ALERT_SUCCCEEDED");
        } else if(sourceType == STOP_LISTENING_ALERT_FAILED) {
            NSLog(@"STOP_LISTENING_ALERT_FAILED");
        } else if(sourceType == SAVE_DEVICE_USEAGES_SUCCESSED) {
            NSLog(@"save device usages sucessed");
        } else if(sourceType == SAVE_DEVICE_USEAGES_FAILED) {
            NSLog(@"save device usages failed");
        } else if(sourceType == GET_DEVICE_USEAGES_SUCCESSED) {
            NSLog(@"get device useages successed");
        } else if(sourceType == GET_DEVICE_USEAGES_FAILED) {
            NSLog(@"get device useages failed");
        }
    });
}

- (void) handleNetworkChange:(NSNotification *)notice {
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {
        if (internetConnectionStatus > 0) {
            [self syncOfflineData];
        }
        internetConnectionStatus = 0;
        NSLog(@"GlobalServiceMangager==NotReachable");
    } else if (remoteHostStatus == ReachableViaWiFi) {
        if (internetConnectionStatus == 0) {
//            if (![_modelManager.currentVCName isEqualToString:@"LoginViewController"] ||
//                ![_modelManager.currentVCName isEqualToString:@"ForgotPasswordViewController"] ||
//                ![_modelManager.currentVCName isEqualToString:@"LoginViewController"] ||
//                ![_modelManager.currentVCName isEqualToString:@"LoginViewController"] ||
//                ) {
//                //            }
            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(synchronizedOffLineToOnLine) userInfo:nil repeats:NO];
        }
        internetConnectionStatus = 1;
        NSLog(@"GlobalServiceMangager==wifi");
    } else if (remoteHostStatus == ReachableViaWWAN) {
        if (internetConnectionStatus == 0) {
            sleep(5);
            [self synchronizedOffLineToOnLine];
        }
        internetConnectionStatus = 1;
        NSLog(@"GlobalServiceMangager==cell");
    }
}

- (void)startNonePanicAlert {
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:_modelManager.user.guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kUser_id_key:_modelManager.user.guardianId,
                                  kLink:@"",
                                  kAlert_type:kAlert_type_panic,
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic1 = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                      WHEN_KEY:[NSDate date],
                                      OBJ_KEY:requestBody
                                      };
    [_serviceHandler onOperate:requestBodyDic1];
}


@end
