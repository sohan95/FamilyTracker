//
//  Boundary.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
#import "SubBoundary.h"

@protocol Boundary
@end

@interface Boundary : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * boundary_id;
@property (nonatomic, readwrite) NSString<Optional> * boundary_name;
@property (nonatomic, strong) NSMutableArray<SubBoundary,Optional> *subBoundaryArray;

@end
