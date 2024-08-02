//
//  BoundaryLocation.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol BoundaryLocation
@end

@interface BoundaryLocation : JSONModel<Dto>
@property (nonatomic) double lat;
@property (nonatomic) double log;

@end
