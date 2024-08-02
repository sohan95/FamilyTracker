//
//  DataUpdater.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/29/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataUpdater <NSObject>
- (void)updateUI:(id)object withStatus:(int)sourceType;

@end
