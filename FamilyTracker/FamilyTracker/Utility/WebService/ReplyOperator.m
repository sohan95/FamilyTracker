//
//  ReplyOperator.m
//  CallCoreRnD
//
//  Created by makboney Islam on 2/3/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ReplyOperator.h"
#import "FamilyTrackerOperate.h"
#import "FamilyTrackerDefine.h"
@implementation ReplyOperator

- (BOOL)onOperate:(id)msg andObject:(id)object {
    return [self onOperateMessage:[FamilyTrackerOperate messageForOperationCode:[msg[@"what"] intValue] andObject:object]];
}

#pragma mark - Operator Delegates

- (BOOL)onOperateMessage:(id)msg {
    @synchronized(self) {
        NSLog(@"ReplyOperator onOperate: msg= %@",msg);
        NSNotificationCenter *notficationCenter = [NSNotificationCenter defaultCenter];
        [notficationCenter postNotificationName:HANDLE_REPLY_OPERATOR object:msg];
        return YES;
    }
}

- (BOOL)onOperate:(int)ope {
    return [self onOperateMessage:[FamilyTrackerOperate messageForOperationCode:ope]];
}

- (BOOL)onOperate:(int)ope andobject:(id)obj {
    return [self onOperateMessage:[FamilyTrackerOperate messageForOperationCode:ope andObject:obj]];
}
@end
