//
//  User.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"
#import "ChatModel.h"
#import "Boundary.h"
#import "SubBoundary.h"
#import "MemberBoundary.h"
//#import "LanguageModel.h"

@interface User : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * guardianId;
@property (nonatomic, readwrite) NSString<Optional> * firstName;
@property (nonatomic, readwrite) NSString<Optional> * lastName;
@property (nonatomic, readwrite) NSNumber<Optional> * age;
@property (nonatomic, readwrite) NSString<Optional> * gender;
@property (nonatomic, readwrite) NSString<Optional> * address;
@property (nonatomic, readwrite) NSString<Optional> * contact;
@property (nonatomic, readwrite) NSString<Optional> * email;
@property (nonatomic, readwrite) NSString<Optional> * userName;
@property (nonatomic, readwrite) NSString<Optional> * password;
@property (nonatomic, readwrite) NSString<Optional> * identifier;
@property (nonatomic, readwrite) NSNumber<Optional> * role;
@property (nonatomic, readwrite) NSString<Optional> * isActive;
@property (nonatomic, readwrite) NSString<Optional> * dob;
@property (nonatomic, readwrite) NSNumber<Optional> * isLocationHide;
@property (nonatomic, readwrite) NSString<Optional> * paymentStatus;
@property (nonatomic, readwrite) NSString<Optional> * sessionToken;
@property (nonatomic, readwrite) NSString<Optional> * profilePicture;
@property (nonatomic, readwrite) ChatModel<Optional> * chatSetting;
@property (nonatomic, readwrite) NSNumber<Optional> * isTrialperiod;
@property (nonatomic, readwrite) NSString<Optional> * trialPeriodStart;
@property (nonatomic, readwrite) NSNumber<Optional> * remainingTrialPerid;
@property (nonatomic, readwrite) NSDictionary<Optional> * settings;
@property (nonatomic, readwrite) NSDictionary<Optional> * guarduianSettings;
@property (nonatomic, readwrite) NSMutableDictionary<Optional> * userSettings;
@property (nonatomic, readwrite) NSDictionary<Optional> * trialPeriodMsg;
@property (nonatomic, strong) NSMutableArray<Boundary,Optional> *boundaryArray;
@end
