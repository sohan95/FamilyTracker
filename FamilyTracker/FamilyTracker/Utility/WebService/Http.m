//
//  Http.m
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "FamilyTrackerDefine.h"
#import "HTTPCodes.h"
#import "Http.h"
#import "User.h"
#import "ModelManager.h"


@interface Http() {
    id<Progress> _progress;
    ModelManager *_modelManager;
}

@end
@implementation Http

- (instancetype)initWithProgress:(id<Progress>)progress {

    if (self == [super init]) {
        _progress = progress;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.defaultSession = [NSURLSession sessionWithConfiguration:self.defaultConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        _modelManager = [ModelManager sharedInstance];
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods
- (void)doSignupWithUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kSignUpService];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:userDictionary andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)activeInactiveMember:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",kFamilyTrackerBaseURL,kActiveInactiveMemberService,kUser_id_key,userDictionary[kUser_id_key]];
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kIdentifier] forKey:kIdentifier];
    [requestBody setObject:userDictionary[kIsActive] forKey:kIsActive];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)resetPassword:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kResetPasswordService];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:userDictionary andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)authenticateUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kSignInService];
//    NSString *urlString = [NSString stringWithFormat:@"%@",kSignInService];
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kUserName] forKey:kUserName];
    [requestBody setObject:userDictionary[kPasswordKey] forKey:kPasswordKey];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)signOutUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kSignOutService];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kUser_id_key] forKey:kUser_id_key];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)forceSignOutUser:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kForceSignOutService];
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kUserName] forKey:kUserName];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)postLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kLocationServerBaseURL,SAVE_LOCATION_DATA_SERVICE];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:dataDic andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kLocationServerBaseURL,GET_LOCATION_DATA_SERVICE];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:dataDic andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)receiveLocationData:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kLocationServerBaseURL,kReceiveLocationDataService];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:dataDic andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];

}


- (void)getAllMembersByGuardianId:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *keyValueString = [NSString stringWithFormat:@"%@=%@",kGuardianId,dataDic[kGuardianId]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@",kFamilyTrackerBaseURL,kGetAllMemberService,keyValueString];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString requestbody:dataDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)changePassword:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString * userId = [dataDic valueForKey:kUser_id_key];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",kFamilyTrackerBaseURL,kChangePasswordService,kUser_id_key,userId];
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:dataDic[kOldPassword_key] forKey:kOldPassword_key];
    [requestBody setObject:dataDic[kNewPassword_key] forKey:kNewPassword_key];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:dataDic];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getMemberById:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *keyValueString = [NSString stringWithFormat:@"%@=%@",
                                kUserid_key,dataDic[kUserid_key]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@",kFamilyTrackerBaseURL,kGetMemberByIdService,keyValueString];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString requestbody:nil andQueryDic:dataDic];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getAlertWithPaging:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *keyValueString = @"";
    NSString *nextPage = dataDic[kNextPage_key];
    if (nextPage.length > 0) {
        keyValueString = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",
                          kFamily_id_key,dataDic[kFamily_id_key],
                          kUser_id_key,dataDic[kUser_id_key],
                          kNextPage_key,dataDic[kNextPage_key]];
    }else {
        keyValueString = [NSString stringWithFormat:@"%@=%@&%@=%@",
                          kFamily_id_key,dataDic[kFamily_id_key],
                          kUser_id_key,dataDic[kUser_id_key]];
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@",kFamilyTrackerBaseURL,kGetAlertsWithPagingService,keyValueString];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getSettings:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",
                           kFamilyTrackerBaseURL,kGetSettingsService];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)saveAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@token=%@",kFamilyTrackerBaseURL,kSaveAlertService,dataDic[kTokenKey]];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kFamily_id_key] forKey:kFamily_id_key];
    [requestBodyDic setObject:dataDic[kCreated_user] forKey:kCreated_user];
    if (dataDic[kLink]) {
        [requestBodyDic setObject:dataDic[kLink] forKey:kLink];
    }
    if (dataDic[Kcreated_at]) {
         [requestBodyDic setObject:dataDic[Kcreated_at] forKey:Kcreated_at];
    }
    if(dataDic[kothersKey]) {
        [requestBodyDic setObject:dataDic[kothersKey] forKey:kothersKey];
    }
    
    if(dataDic[kUser_id_key]) {
        [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    }
    
    if(dataDic[kIsSendSMS]) {
        [requestBodyDic setObject:dataDic[kIsSendSMS] forKey:kIsSendSMS];
    }
    
    if(dataDic[kResourceTypeKey]) {
        [requestBodyDic setObject:dataDic[kResourceTypeKey] forKey:kResourceTypeKey];
    }
    
    [requestBodyDic setObject:dataDic[kAlert_type] forKey:kAlert_type];
    [requestBodyDic setObject:dataDic[kLocationKey] forKey:kLocationKey];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)stopStreaming:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@token=%@",kFamilyTrackerBaseURL,kStopStreamingService,dataDic[kTokenKey]];
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kFamily_id_key] forKey:kFamily_id_key];
    [requestBodyDic setObject:dataDic[kCreated_user] forKey:kCreated_user];
    if (dataDic[kLink]) {
        [requestBodyDic setObject:dataDic[kLink] forKey:kLink];
    }
    
    [requestBodyDic setObject:dataDic[kAlert_type] forKey:kAlert_type];
    [requestBodyDic setObject:dataDic[kIdentifier] forKey:kIdentifier];
    [requestBodyDic setObject:dataDic[kResourceTypeKey] forKey:kResourceTypeKey];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)stopListeningAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kStopListeningAlert];
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kFamily_id_key] forKey:kFamily_id_key];
    [requestBodyDic setObject:dataDic[kCreated_user] forKey:kCreated_user];
    [requestBodyDic setObject:dataDic[kIdentifier] forKey:kIdentifier];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)upLoadUserPicture:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",kFamilyTrackerBaseURL,kUploadUserPictureService,kUser_id_key,dataDic[kUser_id_key]];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kImage_data_key] forKey:kImage_data_key];
    [requestBodyDic setObject:dataDic[kFormat_key] forKey:kFormat_key];

    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];

    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)upLoadMultimedia:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kUploadMultimediaBaseURL,kUploadMultimediaService];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kFileTitleKey] forKey:kFileTitleKey];
    [requestBodyDic setObject:dataDic[kFileContentKey] forKey:kFileContentKey];
    [requestBodyDic setObject:dataDic[kFileTypeIdKey] forKey:kFileTypeIdKey];
    [requestBodyDic setObject:dataDic[kUserIdCamelLetterKey] forKey:kUserIdCamelLetterKey];
    [requestBodyDic setObject:dataDic[kUserNameCamelLetterName] forKey:kUserNameCamelLetterName];
    [requestBodyDic setObject:dataDic[kFileExtensionKey] forKey:kFileExtensionKey];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)addEmergencyContact:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // add emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kAddEmergencyService];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kUserContactName] forKey:kUserContactName];
    [requestBodyDic setObject:dataDic[kUserContact] forKey:kUserContact];
    [requestBodyDic setObject:dataDic[kListOrder] forKey:kListOrder];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}
- (void)getEmergency:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",
                           kFamilyTrackerBaseURL,kGetEmergencyService,kUserid_key,dataDic[kUserid_key]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getAllPackages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",
                           kFamilyTrackerBaseURL,kAllUserPackages,kGuardianId,dataDic[kGuardianId]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)removeEmergencyContact:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // remove emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kRemoveEmergencyService];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kcontactid] forKey:kcontactid];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}



- (void)addMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // add emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kAddBoundaryService];
    
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kBoundaryName] forKey:kBoundaryName];
    [requestBodyDic setObject:dataDic[kGuardianId] forKey:kGuardianId];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kLocationKey] forKey:kLocationKey];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)getMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // add emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@",kFamilyTrackerBaseURL,kGetBoundaryService,dataDic[kUser_id_key]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)deleteMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // add emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kDeleteBoundaryService];
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kBoundaryIdKey] forKey:kBoundaryIdKey];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
    
}


- (void)updateMapBoundary:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block { // add emergency
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kUpdateBoundaryService];
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kGuardianId] forKey:kGuardianId];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kBoundaryIdKey] forKey:kBoundaryIdKey];
    [requestBodyDic setObject:dataDic[kBoundaryName] forKey:kBoundaryName];
    [requestBodyDic setObject:dataDic[kLocationKey] forKey:kLocationKey];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
    
}

- (void)acknowledgeNewAlerts:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@",kFamilyTrackerBaseURL,kAcknowledgedNewAlertsService,kUser_id_key,dataDic[kUser_id_key]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString  andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)acknowledgeReadAlert:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {

    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@=%@&%@=%@&%@=%@",kFamilyTrackerBaseURL,kAcknowledgedReadAlertService,
                           kFamily_id_key,dataDic[kFamily_id_key],
                           kUser_id_key,dataDic[kUser_id_key],
                           kAlert_id_key,dataDic[kAlert_id_key]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];

}

- (void)postLocationHideByMember:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kLocationHideByMemberService];
    NSDictionary *requestBody = @{kUser_id_key:dataDic[kUser_id_key],
                                  kIsLocationHide_key:dataDic[kIsLocationHide_key]};
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)smsActivateCodeVerify:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@code=%@",kFamilyTrackerBaseURL,kSMSActivateService,dataDic[kCodeKey]];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)deviceregistration:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kDeviceRegister];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kUser_id_key] forKey:kUser_id_key];
    [requestBody setObject:userDictionary[kDevice_id] forKey:kDevice_id];
    [requestBody setObject:userDictionary[kReg_token] forKey:kReg_token];

    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)addUserWatch:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kAddUserWacth];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kWatch_id] forKey:kWatch_id];
    [requestBody setObject:userDictionary[kGuardianId] forKey:kGuardianId];
    [requestBody setObject:userDictionary[kUser_id_key] forKey:kUser_id_key];
    
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}


- (void)inActiveUserWatch:(NSDictionary *)userDictionary andWithCompletionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kInActiveUserWacth];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:userDictionary[kWatch_id] forKey:kWatch_id];
    [requestBody setObject:userDictionary[kGuardianId] forKey:kGuardianId];
    [requestBody setObject:userDictionary[kUser_id_key] forKey:kUser_id_key];
    
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:userDictionary];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)resendActionCode:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kresendActionCode];
    NSMutableDictionary *requestBody = [NSMutableDictionary new];
    [requestBody setObject:dataDic[kUserName] forKey:kUserName];
    [requestBody setObject:dataDic[kPasswordKey] forKey:kPasswordKey];
    [requestBody setObject:dataDic[kNotifyMeByKey] forKey:kNotifyMeByKey];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBody andQueryDic:dataDic];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)saveDeviceUseages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",kFamilyTrackerBaseURL,kSaveDeviceUsagesService];
    NSMutableDictionary *requestBodyDic = [NSMutableDictionary new];
    [requestBodyDic setObject:dataDic[kGuardianId] forKey:kGuardianId];
    [requestBodyDic setObject:dataDic[kUser_id_key] forKey:kUser_id_key];
    [requestBodyDic setObject:dataDic[kBattery_percent] forKey:kBattery_percent];
    [requestBodyDic setObject:dataDic[kIs_battery_charging] forKey:kIs_battery_charging];
    
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:requestBodyDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)getDeviceUsages:(NSDictionary*)dataDic completionBlock:(FTObjectResultBlock)block {
    if ([FamilyTrackerReachibility isUnreachable]) {
        block(nil,[NSError errorWithDomain:kNetworkErrorDomain code:kNetworkErrorStatusCode userInfo:@{
                                                                                                       kUserInforKey:kUserInforValue,
                                                                                                       }]);
        return;
    }
    NSString *keyValueString = [NSString stringWithFormat:@"%@=%@",kGuardianId,dataDic[kGuardianId]];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@",kFamilyTrackerBaseURL,kGetDeviceUsagesService,keyValueString];
    NSURLRequest *urlRequest = [self requestWithMethod:@"GET" withUrlString:urlString requestbody:dataDic andQuery:dataDic[kTokenKey]];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

#pragma mark -
#pragma mark - Class Merthods
//used
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method withUrlString:(NSString *)urlStr requestbody:(NSDictionary *)requestDictionary andQueryDic:(NSDictionary *)query {
    NSLog(@"SurroundViewer Http method=%@",method);
    NSLog(@"SurroundViewer Http url=%@",urlStr);
    NSLog(@"SurroundViewer Http query=%@",query);
    NSLog(@"SurroundViewer Http rerquest Dictionary=%@",requestDictionary);
    NSMutableURLRequest *urlRequest = nil;
    NSMutableString *spec = [[NSMutableString alloc] initWithString:urlStr];
    
    NSURL *url = [NSURL URLWithString:spec];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.timeoutInterval = kRequestTimeOut;
    urlRequest.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([method isEqualToString:@"POST"]) {
        NSError *error = nil;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:requestData];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        if([query isKindOfClass:[NSDictionary class]]) {
            if (query[kTokenKey]) {
                [urlRequest setValue:query[kTokenKey] forHTTPHeaderField:kTokenKey];
            }
            if (query[kDeviceNoKey]) {
                [urlRequest setValue:query[kDeviceNoKey] forHTTPHeaderField:kDeviceNoKey];
                [urlRequest setValue:query[kDeviceTypeKey] forHTTPHeaderField:kDeviceTypeKey];
            }
        }
    }else if ([method isEqualToString:@"GET"]) {
        if([query isKindOfClass:[NSDictionary class]]) {
            [urlRequest setValue:query[kTokenKey] forHTTPHeaderField:kTokenKey];
            if (query[kDeviceNoKey]) {
                [urlRequest setValue:query[kDeviceNoKey] forHTTPHeaderField:kDeviceNoKey];
                [urlRequest setValue:query[kDeviceTypeKey] forHTTPHeaderField:kDeviceTypeKey];
            }
        }
    }
    return urlRequest;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method withUrlString:(NSString *)urlStr requestbody:(NSDictionary *)requestDictionary andQuery:(NSString *)query {
    NSLog(@"SurroundViewer Http method=%@",method);
    NSLog(@"SurroundViewer Http url=%@",urlStr);
    NSLog(@"SurroundViewer Http query=%@",query);
    NSLog(@"SurroundViewer Http rerquest Dictionary=%@",requestDictionary);
    NSMutableURLRequest *urlRequest = nil;
    
    NSMutableString *spec = [[NSMutableString alloc] initWithString:urlStr];
    
    NSURL *url = [NSURL URLWithString:spec];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.timeoutInterval = kRequestTimeOut;
    urlRequest.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([method isEqualToString:@"POST"]) {
        NSError *error = nil;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:requestData];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        if(query) {
            [urlRequest setValue:query forHTTPHeaderField:kTokenKey];
        }
        
    }else if ([method isEqualToString:@"GET"]) {
        if (query) {
            [urlRequest setValue:query forHTTPHeaderField:kTokenKey];
        }else {
            [urlRequest setValue:query forHTTPHeaderField:@"api-key"];
        }
    }
    return urlRequest;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method withUrlString:(NSString *)urlStr andQuery:(NSString *)query {
    NSLog(@"SurroundViewer Http method=%@",method);
    NSLog(@"SurroundViewer Http url=%@",urlStr);
    NSLog(@"SurroundViewer Http query=%@",query);
    NSMutableURLRequest *urlRequest = nil;
    NSMutableString *spec = [[NSMutableString alloc] initWithString:urlStr];
    NSURL *url = [NSURL URLWithString:spec];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.timeoutInterval = kRequestTimeOut;
    urlRequest.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (query) {
        [urlRequest setValue:query forHTTPHeaderField:kTokenKey];
    }
    return urlRequest;
}

- (NSMutableURLRequest *)createRequestWithUrl:(NSURL *)url andRequestData:(NSData *)requestData {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeOut];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    return urlRequest;
}

- (void)parseResponseForObjectBlock:(NSHTTPURLResponse *)httpResponse withError:(NSError **)error_p completionBlock:(FTObjectResultBlock)block andWithData:(NSData *)data {
    NSError *error;
    NSString *statusDesc = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
    if (httpResponse.statusCode == HTTPCode200OK) {
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        if (responseDictionary[kQueriesKey_GetLocation]) {
            //---For Get Location Service---//
            if (responseDictionary[kQueriesKey_GetLocation] == nil || responseDictionary[kQueriesKey_GetLocation] == (id)[NSNull null]) {
                block(nil,error);
            }else {
                NSArray *resultArray = [[responseDictionary valueForKey:kQueriesKey_GetLocation][0] valueForKey:kResultsKey_GetLocation];
                block(resultArray,nil);
            }
        }else if (responseDictionary[kResultKeySmallStart]) {
            block(responseDictionary[kResultKeySmallStart],nil);
        }else if ([responseDictionary[kStatusKey] isEqualToString:@"ok"]){
            block(responseDictionary,nil);
        }
        else if (responseDictionary[kResultKeyCapitalStart]){
            block(responseDictionary[kResultKeyCapitalStart],nil);
        }else if ([responseDictionary[kLocationPostSuccessKey] integerValue] == 1) {
            block(responseDictionary,nil);
        }else if (responseDictionary[kLink]) {//for Save Alert
            block(responseDictionary,nil);
        }else if (responseDictionary) {//for Save Alert
            block(responseDictionary,nil);
        }else {
            block(nil,error);
        }
    }
    else if (httpResponse.statusCode == HTTPCode555ForceSignOut) {
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Single device SignIn issue" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode400BadRequest) {
        //[_progress toast:BAD_REQUEST];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode404NotFound) {
        //[_progress toast:UNAUTHORIZED];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode401Unauthorised) {
        //[_progress toast:UNAUTHORIZED];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode500InternalServerError) {
        //[_progress toast:UNAUTHORIZED];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode406NotAcceptable) {
        //[_progress toast:UNAUTHORIZED];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        block(responseDictionary,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else {//
        //[_progress toast:UNKNOWN];
        block(nil,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }
}

- (void)initURLSessionWithRequest:(NSURLRequest *)urlRequest andCompltetionHandler:(FTObjectResultBlock)block {
    self.defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sessionWithConfiguration:self.defaultConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [self.defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
        @try {
            if (error) {
                block(nil,error);
            }else {
                NSError *err;
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                [self parseResponseForObjectBlock:httpResponse withError:&err completionBlock:block andWithData:data];
            }
        }
        @catch (NSException *exception) {
            @throw exception;
        }
        @finally {
            
        }
    }];
    [task resume];
}

@end
