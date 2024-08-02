//
//  UIBezierPath+Polygon.m
//  hexagonImage
//
//  Created by einfochips on 9/29/16.
//  Copyright © 2016 einfochips. All rights reserved.
//

#import "UIBezierPath+Polygon.h"

@implementation UIBezierPath (Polygon)
+ (instancetype)roundedPolygonPathWithRect:(CGRect)square lineWidth:(CGFloat)lineWidth sides:(NSInteger)sides cornerRadius:(CGFloat)cornerRadius {
	UIBezierPath *path  = [UIBezierPath bezierPath];
	
	CGFloat theta       = 2.0 * M_PI / sides;                           // how much to turn at every corner
	CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
	CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
	
	// calculate the length of the sides of the polygon
	
	CGFloat length      = squareWidth - lineWidth;
	if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
		length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
	}
	CGFloat sideLength = length * tanf(theta / 2.0);
	
	// start drawing at `point` in lower right corner
	
	CGPoint point = CGPointMake(squareWidth / 2.0 + sideLength / 2.0 , squareWidth - (squareWidth - length) / 2.0 -offset);
	CGFloat angle = M_PI / 2 ;
	[path moveToPoint: point];
	
	// draw the sides and rounded corners of the polygon
	
	for (NSInteger side = 0; side < sides; side++) {
		
		angle += theta;
		point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
		[path addLineToPoint:point];
		
		CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
		[path addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
		
		point = path.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
	
	}
	
	[path closePath];
	
	return path;
}
@end
