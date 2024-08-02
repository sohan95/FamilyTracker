//
//  UIBezierPath+Polygon.h
//  hexagonImage
//
//  Created by einfochips on 9/29/16.
//  Copyright © 2016 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Polygon)
+ (instancetype)roundedPolygonPathWithRect:(CGRect)square lineWidth:(CGFloat)lineWidth sides:(NSInteger)sides cornerRadius:(CGFloat)cornerRadius;
@end
