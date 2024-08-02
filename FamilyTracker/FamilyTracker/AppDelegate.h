//
//  AppDelegate.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/4/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationTracker.h"
#import "SWRevealViewController.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,SWRevealViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
//@property (nonatomic) NSTimer* trialTimer;
@property (nonatomic,retain) NSString *activeGroupName;
@property (nonatomic,readwrite) int isConference;
@property (nonatomic,readwrite) int isActiveChatView;
@property (assign, nonatomic) BOOL isDay;
@property (assign, nonatomic) BOOL isPopUpAtHomeView;
@property (nonatomic) NSTimer* trialExpiredTimer;
@property(nonatomic) BOOL previousAlertMessagePanding;
//for livestreaming
@property (assign, nonatomic) BOOL restrictRotation;
@property (assign, nonatomic) UIDeviceOrientation deviceOrientation;
@property(nonatomic, readwrite) NSString* resourcePath;
@property (nonatomic, retain) AVAudioPlayer *player;
// Chat
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) AVQueuePlayer *player2;
@property (nonatomic, strong) id timeObserver;
- (void)playPanicInBackground;
- (void)setVolumeUp;
- (void)setVolumeZero;
- (void)showHideIQKeyboard:(BOOL)status;
- (void)startTrialExpiredTimer:(NSString *)message;
- (void)playPanicAlert;
- (void)stopPanicAlert;
@property(nonatomic, strong) NSMutableArray *listnerLists;

@end



