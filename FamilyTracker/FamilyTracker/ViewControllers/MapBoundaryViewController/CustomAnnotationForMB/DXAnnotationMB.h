//
//  DXAnnotationMB.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/28/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXAnnotationMB : NSObject <MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic) int index;
@property(nonatomic) int intArrayIndex;
@property(nonatomic,copy) NSString * title;

@end
