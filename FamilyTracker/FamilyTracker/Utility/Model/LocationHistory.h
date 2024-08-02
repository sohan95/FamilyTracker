//
//  LocationHistory.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/2/17.
//  Copyright © 2017 SurroundApps. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
@protocol LocationHistory
@end

@interface LocationHistory : JSONModel<Dto>
//@property (nonatomic, readwrite) NSString * id;
//@property (nonatomic, readwrite) NSString<Optional> * name;
@property (nonatomic, readwrite) NSNumber *timestamp;
@property (nonatomic, readwrite) NSNumber *latitude;
@property (nonatomic, readwrite) NSNumber *longitude;

@end
