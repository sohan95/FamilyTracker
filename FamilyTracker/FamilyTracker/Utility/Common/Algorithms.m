//
//  Algorithms.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "Algorithms.h"
#define INF_X 100000.0

@implementation Algorithms

#pragma - mark Convex Hull Algorithm

+(NSMutableArray *) convexHullAlgorithm:(NSMutableArray *)points andSize:(int)n {
    if(n<3) {
        return points;
    }
    NSMutableArray *hull = [[NSMutableArray alloc] init];
    // Find the leftmost point
    int l = 0;
    for(int i=0; i<n; i++) {
        NSValue *val_i = [points objectAtIndex:i];
        NSValue *val_l = [points objectAtIndex:l];
        if([val_i CGPointValue].x < [val_l CGPointValue].x) {
            l = i;
        }
    }
    int p = l,q;
    
    do {
        [hull addObject:[points objectAtIndex:p]];
        
        q = (p+1)%n;
        
        for(int i = 0; i<n; i++) {
            // if i is more counterClockwise than current q, then
            // update q
            NSValue *val_p = [points objectAtIndex:p];
            NSValue *val_i = [points objectAtIndex:i];
            NSValue *val_q = [points objectAtIndex:q];
            
            if([self orientation:[val_p CGPointValue] andPoint:[val_i CGPointValue] andPoint:[val_q CGPointValue]] == 2) {
                q = i;
            }
        }
        //Now q is the most counterclockwise with respect to p
        //set p as q for next iteration, so that q is added to
        //result hull
        p = q;
        
    } while (p!= l);
    
    // print result
    //    for(int i=0; i<hull.count; i++) {
    //        NSValue *hull_point = [hull objectAtIndex:i];
    //        NSLog(@"x_point = %f  y_point = %f",[hull_point CGPointValue].x,[hull_point CGPointValue].y);
    //    }
    return hull;
}

+ (int)orientation:(CGPoint )p andPoint:(CGPoint)q andPoint:(CGPoint)r {
    
    double val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    
    if(val == 0.0) {
        return 0;
    }
    return (val>0.0)?1:2;
}



#pragma mark - check point inside the polygon -
+ (BOOL) isInsidePolyGon:(NSMutableArray *)polygonPoint andCheckPoint:(CGPoint)p {
    int n = (int)polygonPoint.count;
    if(n < 3) return NO;
    CGPoint extreme = CGPointMake(INF_X,p.y);
    int count = 0,i = 0;
    do {
        int next = (i+1)%n;
        NSValue *val = [polygonPoint objectAtIndex:i];
        NSValue *val1 = [polygonPoint objectAtIndex:next];
        if ([self doIntersect:[val CGPointValue] andPoint:[val1 CGPointValue] andPoint:p andPoint:extreme]) {
            
            if ([self orientation:[val CGPointValue] andPoint:p andPoint:[val1 CGPointValue]] == NO) {
                return [self onSegment:[val CGPointValue] andPoint:p andPoint:[val1 CGPointValue]];
            }
            count++;
        }
        i = next;
    } while (i != 0);
    
    return count&1;
}

+ (BOOL) doIntersect:(CGPoint)p1 andPoint:(CGPoint)q1 andPoint:(CGPoint)p2 andPoint:(CGPoint)q2 {
    
    int o1 = [self orientation:p1 andPoint:q1 andPoint:p2];
    int o2 = [self orientation:p1 andPoint:q1 andPoint:q2];
    int o3 = [self orientation:p2 andPoint:q2 andPoint:p1];
    int o4 = [self orientation:p2 andPoint:q2 andPoint:q1];
    
    if(o1 != o2 && o3 != o4) {
        return YES;
    }
    
    if(o1 == 0 && [self onSegment:p1 andPoint:p2 andPoint:q1]) {
        return YES;
    }
    if(o2 == 0 && [self onSegment:p1 andPoint:q2 andPoint:q1]) {
        return YES;
    }
    if(o3 == 0 && [self onSegment:p2 andPoint:p1 andPoint:q2]) {
        return YES;
    }
    if(o4 == 0 && [self onSegment:p2 andPoint:q1 andPoint:q2]) {
        return YES;
    }
    return NO;
}

+ (BOOL)onSegment:(CGPoint)p andPoint:(CGPoint)q andPoint:(CGPoint)r {
    if (q.x <= fmax(p.x, r.x) && q.x >= fmax(p.x, r.x) &&
        q.y <= fmax(p.y, r.y) && q.y >= fmax(p.y, r.y))
        return true;
    
    return NO;
}

@end
