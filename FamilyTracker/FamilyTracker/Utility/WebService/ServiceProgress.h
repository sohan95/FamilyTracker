//
//  ServiceProgress.h
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Progress.h"
#import "Operator.h"
@interface ServiceProgress : NSObject<Progress>
- (instancetype)initWithOperator:(id<Operator>)operatr;
@end
