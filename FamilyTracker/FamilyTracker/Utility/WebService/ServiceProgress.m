//
//  ServiceProgress.m
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ServiceProgress.h"
#import "FamilyTrackerOperate.h"
@implementation ServiceProgress
static id<Operator> operator;

- (instancetype)initWithOperator:(id<Operator>)operatr{
    
    if (self = [super init]) {
        operator = operatr;
    }
    return self;
}

-(BOOL)isShowing {
    return NO;
}

- (void)close {
    
    [operator onOperate:PROGRESS_CLOSE];
}

- (void)message:(const NSString *)msg andTitle:(const NSString *)title{
    
    [operator onOperate:PROGRESS_MSG andObject:msg];
}

- (void)msg:(const NSString *)msg{
    
    [operator onOperate:PROGRESS_MSG andObject:msg];
}

- (void)error:(const NSString *)msg withTitle:(const NSString *)title{
    
    [operator onOperate:PROGRESS_ERROR andObject:msg];
}

- (void)error:(const NSString *)msg{
    
    [operator onOperate:PROGRESS_ERROR andObject:msg];
}

- (void)toast:(const NSString *)msg{
    
    [operator onOperate:PROGRESS_TOAST andObject:msg];
}

- (void)err:(const NSString *)msg{
    
    [operator onOperate:PROGRESS_ERR andObject:msg];
}

- (void)err:(const NSString *)msg withTitle:(const NSString *)title{
    
    [operator onOperate:PROGRESS_ERR andObject:msg];
}
@end
