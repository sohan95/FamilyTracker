//
//  LocationModel.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/27/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol LocationModel
@end

@interface LocationModel : JSONModel<Dto>

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

- (instancetype)initWithLatitude:(double)lat longitude:(double)lng;

@end
