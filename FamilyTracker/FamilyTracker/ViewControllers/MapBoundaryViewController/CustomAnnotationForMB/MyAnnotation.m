//
//  MyAnnotation.m
//  dragMapAnnotaion
//
//  Created by Zeeshan Khan on 4/5/17.
//  Copyright © 2017 Zeeshan Khan. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return nil;
}

- (NSString *)title{
    return _title;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord{
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}


@end
