//
//  SubBoundary.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
#import "BoundaryLocation.h"

@protocol SubBoundary
@end

@interface SubBoundary : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> * location_order;
@property (nonatomic, readwrite) BoundaryLocation<Optional> *location;

@end
