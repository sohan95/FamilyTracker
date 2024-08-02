//
//  ReplyOperator.h
//  CallCoreRnD
//
//  Created by makboney Islam on 2/3/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operator.h"

@interface ReplyOperator: NSObject<Operator>
- (BOOL)onOperate:(id)msg andObject:(id)object;
@end
