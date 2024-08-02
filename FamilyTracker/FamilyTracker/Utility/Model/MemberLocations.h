//
//  MemberLocations.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "MemberLocation.h"

@protocol MemberLocations
@end

@interface MemberLocations : JSONModel
@property (nonatomic, strong) NSMutableArray<MemberLocation,Optional> *rows;

@end
