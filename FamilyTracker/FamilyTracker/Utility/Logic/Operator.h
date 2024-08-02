//
//  Operator.h
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Operator <NSObject>
- (BOOL)onOperate:(int)ope;
- (BOOL)onOperate:(int)ope andObject:(id)obj;
- (BOOL)onOperateMessage:(id)msg;
@end
