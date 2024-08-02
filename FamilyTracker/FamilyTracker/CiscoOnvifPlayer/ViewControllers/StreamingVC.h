//
//  CameraStreamingViewController.h
//  CiscoOnvifPlayer
//
//  Created by einfochips on 9/24/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
//#import <MediaLibraryKit/MediaLibraryKit.h>

#import "LivePlaybackController.h"
#import "VLCConstants.h"
#import "MBProgressHUD.h"
#import "CameraPTZSettingView.h"

@interface StreamingVC : UIViewController<LivePlaybackControllerDelegate, MBProgressHUDDelegate> {
	IBOutlet UIButton *btnRetryPlayback;
    IBOutlet UIView *ptzControlsView;
    
#if !TARGET_IPHONE_SIMULATOR
    LivePlaybackController *livePlaybackController;
#endif
    
    CameraPTZSettingView *cameraPTZSettingView;
    MBProgressHUD *mbProgressHUD;
    
    BOOL isONVIFPlayer;
    
    NSString *stateBeforeFullScreen;
}

@property (nonatomic, retain) LivePlaybackController *livePlaybackController;

@property (nonatomic, retain) IBOutlet UIView *movieView;
@property (nonatomic, retain) IBOutlet UIView *ptzControlsView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, retain) NSString *xAddr;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *ptzProfileToken;
@property (nonatomic) BOOL isCameraPTZCapable;
@property (nonatomic) BOOL isShowPTZView;

@property (nonatomic, assign) BOOL isDispalyInMultiPane;
@property (nonatomic, assign) NSUInteger myTagValue;

@property (nonatomic, retain) NSString *stateBeforeFullScreen;
@property (nonatomic, assign) BOOL isFullScreenEnabled;

// When User come from ONVIF Player this isONVIFPlayer will be TRUE
@property (nonatomic, assign) BOOL isONVIFPlayer;

- (void)manuallyStopPlayback;

- (void)startPlaying;
- (BOOL)isVideoPlaying;
- (void)pauseVideo;
- (void)playVideo;

//- (BOOL)playOrResumePlaying;
//- (BOOL)muteUnMuteAudio;

- (BOOL)isAudioMuted;
- (void)muteAudio;
- (void)unmuteAudio;

- (BOOL)isShowPTZControlView;
- (void)showHidePTZControlView:(BOOL)isShow;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;

@end
