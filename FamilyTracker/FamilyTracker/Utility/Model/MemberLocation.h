//
//  MemberLocation.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/27/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
@protocol MemberLocation
@end

@interface MemberLocation : JSONModel<Dto>
@property (nonatomic, readwrite) NSString * userName;
@property (nonatomic, readwrite) NSString<Optional> * name;
@property (nonatomic, readwrite) NSNumber<Optional> * timestamp;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;

@end
