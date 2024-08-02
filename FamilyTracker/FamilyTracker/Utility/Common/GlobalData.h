//
//  GlobalData.h
//  InstantConnect
//  Copyright © 2016 Cisco Systems Confidential - SPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationModel.h"
#import "Notifications.h"

@interface GlobalData : NSObject

+ (GlobalData *)sharedInstance;

@property (nonatomic,retain) Notifications *_allAlertFullList;
//@property (nonatomic,retain) NSMutableArray *_allAlertFullList;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, assign) BOOL	isJabberLogedIn;
@property (nonatomic, assign) BOOL isLiveStreamingView;
@property (nonatomic, assign) BOOL isInPanic;
@property (strong,nonatomic) NSString *roomName;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic, strong) LocationModel *userLocation;
@property (nonatomic, strong) NSCache *_videoThumbnailCache;
@property (nonatomic, strong) NSString *runningSilentStreamingMemberId;

- (void)reset;
- (NSString*)stringFromEpochTime:(NSTimeInterval)epochTime;
@end
