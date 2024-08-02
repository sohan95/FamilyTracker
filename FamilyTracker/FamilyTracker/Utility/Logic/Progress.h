//
//  Progress.h
//  CallCoreRnD
//
//  Created by makboney Ltd on 2/2/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Progress <NSObject>
-(BOOL)isShowing;
-(void)close;
-(void)message:(NSString*)msg andTitle:(const NSString *) title;
-(void)msg:(NSString*) msg;
-(void)error:(NSString *)msg withTitle:(NSString *)title;
-(void)error:(NSString*)msg;
-(void)toast:(NSString *)msg;
-(void)err:(NSString *)msg withTitle:(NSString *)title;
-(void)err:(NSString *)msg;
@end
