//
//  EmergencyContactModel.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/14/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol EmergencyContactModel
@end

@interface EmergencyContactModel : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * identifier;
@property (nonatomic, readwrite) NSString<Optional> * contactId;
@property (nonatomic, readwrite) NSArray<Optional> * contactArray;
@property (nonatomic, readwrite) NSString<Optional> * contactName;
@property (nonatomic, readwrite) NSString<Optional> * contactImage;
@property (nonatomic, readwrite) NSString<Optional> * listOrder;

@end
