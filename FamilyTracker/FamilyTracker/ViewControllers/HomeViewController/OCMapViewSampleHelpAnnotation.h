//
//  OCMapViewSampleHelpAnnotation.h
//  openClusterMapView
//
//  Created by Botond Kis on 17.07.11.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"

@interface OCMapViewSampleHelpAnnotation : NSObject <MKAnnotation, OCGrouping>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *groupTag;
///
@property(nonatomic, readwrite) NSString *memberUserName;
@property(nonatomic, readwrite) NSString *memberName;
@property (nonatomic, assign) int annotationIndex;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
