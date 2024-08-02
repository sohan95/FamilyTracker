//
//  MemberBoundary.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
#import "Boundary.h"

@protocol MemberBoundary
@end

@interface MemberBoundary : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * guardianId;
@property (nonatomic, readwrite) NSString<Optional> * identifier;
@property (nonatomic, strong) NSMutableArray<Boundary,Optional> *boundaryArray;
@end
