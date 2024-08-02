//
//  SignupUpdater.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/29/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SignupUpdater <NSObject>
- (void)signupSuccess:(id)object isSuccess:(BOOL)success;

@end
