//
//  MyAnnotation.h
//  dragMapAnnotaion
//
//  Created by Zeeshan Khan on 4/5/17.
//  Copyright © 2017 Zeeshan Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>{
    
    CLLocationCoordinate2D coordinate;
    
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@property (nonatomic,copy) NSString * title;
@property(nonatomic)  int index;
@property(nonatomic) int isTempAnnotation;
@end
