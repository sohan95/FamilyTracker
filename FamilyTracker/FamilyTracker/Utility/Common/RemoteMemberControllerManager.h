//
//  RemoteMemberControllerManager.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/10/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "AudioProcessor.h"


@interface RemoteMemberControllerManager : NSObject {
    ModelManager *_modelManager;
    UIStoryboard *sb;
    NSDictionary *requestBodyDic;
    Reachability* reachability;
    int internetConnectionStatus;
}

@property (retain, nonatomic) AudioProcessor *audioProcessor;

+ (RemoteMemberControllerManager *)sharedInstance;
- (void)remoteAudioStreamingStart;
- (void)remoteAudioStreamingStop;


@end
