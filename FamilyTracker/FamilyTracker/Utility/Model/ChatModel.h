//
//  ChatModel.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol ChatModel
@end

@interface ChatModel : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * roomName;
@property (nonatomic, readwrite) NSString<Optional> * hostName;
@property (nonatomic, readwrite) NSString<Optional> * ipAddress;

@end
