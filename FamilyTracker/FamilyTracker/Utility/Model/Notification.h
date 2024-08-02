//
//  Notification.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/19/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
#import "LocationModel.h"

@protocol Notification
@end

@interface Notification : JSONModel<Dto>

@property (nonatomic, readwrite) NSString * identifier;
@property (nonatomic, readwrite) NSString<Optional> *familyId;
@property (nonatomic, readwrite) NSString<Optional> *userId;
@property (nonatomic, readwrite) NSNumber<Optional> * isSeen;
@property (nonatomic, readwrite) NSString<Optional> * createdUser;
@property (nonatomic, readwrite) NSMutableDictionary<Optional> *messageTitle;
@property (nonatomic, readwrite) NSDictionary<Optional> * messageBody;
@property (nonatomic, readwrite) NSString<Optional> * link;
@property (nonatomic, readwrite) NSString<Optional> * alertType;
@property (nonatomic, readwrite) NSString<Optional> * resourceType;
@property (nonatomic, readwrite) NSString<Optional> * createdTime;
@property (nonatomic, readwrite) LocationModel<Optional> *location;
@property (nonatomic, readwrite) NSString<Optional> *referenceId;

@end
