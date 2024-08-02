//
//  MemberData.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/24/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol MemberData
@end

@interface MemberData : JSONModel<Dto>
@property (nonatomic, readwrite) NSString * guardianId;
@property (nonatomic, readwrite) NSString * identifier;
@property (nonatomic, readwrite) NSString * userName;
@property (nonatomic, readwrite) NSString<Optional> * contact;
@property (nonatomic, readwrite) NSString<Optional> * email;
@property (nonatomic, readwrite) NSString<Optional> * firstName;
@property (nonatomic, readwrite) NSString<Optional> * gender;
@property (nonatomic, readwrite) NSNumber<Optional> * isLocationHide;//
@property (nonatomic, readwrite) NSString<Optional> * lastName;
@property (nonatomic, readwrite) NSString<Optional> * paymentStatus;
@property (nonatomic, readwrite) NSString<Optional> * role;
@property (nonatomic, readwrite) NSDictionary<Optional> * settings;//NSArray
@property (nonatomic, readwrite) NSString<Optional> * trialPeriodStart;
@property (nonatomic, readwrite) NSDictionary<Optional> * userSettings;//NSArray
@property (nonatomic, readwrite) NSDictionary<Optional> * guardianSettings;//NSArray
@property (nonatomic, readwrite) NSNumber <Optional> * isActive;
@property (nonatomic, readwrite) NSString <Optional> * profile_pic;

@end
