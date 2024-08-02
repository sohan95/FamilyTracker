//
//  DXAnnotation.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/22/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXAnnotation : NSObject <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, readwrite) NSString *memberUserName;
@property(nonatomic, readwrite) NSString *memberName;
@property (nonatomic, assign) int annotationIndex;

@end
