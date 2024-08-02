//
//  Algorithms.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Algorithms : NSObject

+(NSMutableArray *) convexHullAlgorithm:(NSMutableArray *)points andSize:(int)n;
+(BOOL) isInsidePolyGon:(NSMutableArray *)polygonPoint andCheckPoint:(CGPoint)p;

@end
