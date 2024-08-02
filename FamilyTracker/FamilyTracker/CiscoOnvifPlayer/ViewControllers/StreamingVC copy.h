//
//  CameraStreamingViewController.h
//  CiscoOnvifPlayer
//
//  Created by einfochips on 9/24/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaLibraryKit/MediaLibraryKit.h>
#import "VLCConstants.h"
#import "MBProgressHUD.h"
#import "CameraPTZSettingView.h"

//#if TARGET_IPHONE_SIMULATOR
//    @interface StreamingVC : UIViewController
//#else
    #import <MediaPlayer/MediaPlayer.h>
    #import <DynamicMobileVLCKit/DynamicMobileVLCKit.h>
    @interface StreamingVC : UIViewController<VLCMediaPlayerDelegate,AVAudioSessionDelegate, MBProgressHUDDelegate>
//#endif

{
	IBOutlet UIButton *btnRetryPlayback;
    IBOutlet UIButton *btnRetryPlayback1;
    IBOutlet UIView *ptzControlsView;
    
#if !TARGET_IPHONE_SIMULATOR
	VLCMediaPlayer *mediaPlayer;
#endif
	
	BOOL isAppRunninginBackground;
    BOOL shouldResumePlaying;
    BOOL playerIsSetup;
	BOOL isDidEnterIntoBackground;
	
    CameraPTZSettingView *cameraPTZSettingView;
	MBProgressHUD *mbProgressHUD;
	
	BOOL isONVIFPlayer;
	
	NSInteger relaodAttempt;
}

@property (nonatomic, retain) IBOutlet UIView *movieView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, retain) NSString *xAddr;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *ptzProfileToken;
@property (nonatomic) BOOL isCameraPTZCapable;

// When User come from ONVIF Player this isONVIFPlayer will be TRUE
@property (nonatomic, assign) BOOL isONVIFPlayer;

@end

