//
//  BackgroundTaskManager.h
//
//  Created by Qaium Hossain on 4/27/15.
//  Copyright (c) 2015 Cisco Systems Confidential - SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTaskManager : NSObject

+(instancetype)sharedBackgroundTaskManager;

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
