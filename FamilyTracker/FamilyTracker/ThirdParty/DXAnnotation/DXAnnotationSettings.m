//
//  DXAnnotationSettings.m
//  CustomCallout
//
//  Created by Selvin on 12/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import "DXAnnotationSettings.h"
#import "HexToRGB.h"

@implementation DXAnnotationSettings

+ (instancetype)defaultSettings {
    DXAnnotationSettings *newSettings = [[super alloc] init];
    if (newSettings) {
        newSettings.calloutOffset = 10.0f;
        
        newSettings.shouldRoundifyCallout = YES;
        newSettings.calloutCornerRadius = 12.0f;
        
        newSettings.shouldAddCalloutBorder = YES;
        newSettings.calloutBorderColor = [UIColor lightGrayColor];// [HexToRGB colorForHex:@"535252"];//[UIColor colorWithRed:60.0/255 green:184.0/255 blue:120.0/255 alpha:1.000];
        newSettings.calloutBorderWidth = 1.0;
        
        newSettings.animationType = DXCalloutAnimationFadeIn;
        newSettings.animationDuration = 0.10;
        
    }
    return newSettings;

}

+ (instancetype)customSettings {
    DXAnnotationSettings *newSettings = [[super alloc] init];
    if (newSettings) {
        newSettings.calloutOffset = 10.0f;
        
        newSettings.shouldRoundifyCallout = YES;
        newSettings.calloutCornerRadius = 15.0f;
        
        newSettings.shouldAddCalloutBorder = YES;
        newSettings.calloutBorderColor = [UIColor colorWithRed:60.0/255 green:184.0/255 blue:120.0/255 alpha:1.000];
        newSettings.calloutBorderWidth = 1.0;
        
        newSettings.animationType = DXCalloutAnimationZoomIn;
        newSettings.animationDuration = 0.15;
    }
    return newSettings;
}

@end
