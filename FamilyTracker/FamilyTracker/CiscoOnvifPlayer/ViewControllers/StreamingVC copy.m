//
//  CameraStreamingViewController.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 21/10/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import "StreamingVC.h"
#import "UINavigationController+AutorotationFromVisibleView.h"
#import <CiscoIPICSPlayerStreamerLib/Reachability.h>

#define MAX_RELOAD_ATTEMPT	3
#define kCantPlayVideoAlertViewTag 101

@interface StreamingVC ()
{
//	UIActivityIndicatorView *activityIndicator;
	Reachability *hostReachability;
	
	NSString *textMessage;
    
    BOOL isManualStopped;
    __weak IBOutlet NSLayoutConstraint *heightMovieView;
    __weak IBOutlet NSLayoutConstraint *widthMovieView;
}
//@property(nonatomic)Reachability *hostReachability;
@end

@implementation StreamingVC
//@synthesize hostReachability;
@synthesize isONVIFPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self)
	{
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
	btnRetryPlayback.hidden = true;
    isManualStopped = NO;
	
	textMessage = @"";
	relaodAttempt = 0;
	isAppRunninginBackground = NO;
	
	hostReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
	[hostReachability startNotifier];
	
	mbProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    mbProgressHUD.tag = 1000;
	mbProgressHUD.backgroundColor = [UIColor darkGrayColor];
//	mbProgressHUD.detailsLabelFont = [UIFont boldSystemFontOfSize:14.0f];
	[self.movieView addSubview:mbProgressHUD];
	mbProgressHUD.delegate = self;
	
//	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//	activityIndicator.color = [UIColor whiteColor];
//	activityIndicator.center = _movieView.center;
//	activityIndicator.hidesWhenStopped = YES;
//	[activityIndicator startAnimating];
//	
//	[_movieView addSubview:activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	[self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    
//    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
	// Start Streaming on When View Appeared
	#if !TARGET_IPHONE_SIMULATOR
	[self startPlayback];
	#endif
    
    // PTZ View should be visible only when playing for PTZ Camera with ONVIF support
    if (self.isONVIFPlayer && self.isCameraPTZCapable)
    {
        [self setPTZView];
    }
	
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
#if !TARGET_IPHONE_SIMULATOR
    isManualStopped = YES;
	[self stopPlayback];
#endif
	
    [self.tabBarController.tabBar setHidden:NO];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
	[super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	// If any memory warning occur then stop streaming to prevent OS to kill application
	#if !TARGET_IPHONE_SIMULATOR
	[self stopPlayback];
	mediaPlayer = nil;
	#endif
	
    [super didReceiveMemoryWarning];
}

// on Back button Touched
- (IBAction)btnBackTouched:(id)sender
{
    isManualStopped = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

// on Retry button Touched
// If Player fails to stream video, user can try again using retry button
- (IBAction)btnRetryTochued:(id)sender
{
	btnRetryPlayback.hidden = true;
	
#if !TARGET_IPHONE_SIMULATOR
	[self startPlayback];
#endif
}

// Close playback
- (void)closePlayback:(id)sender
{
	[self.view bringSubviewToFront:self.movieView];
	
//	[mbProgressHUD show:YES];
//	[self.view bringSubviewToFront:mbProgressHUD];
	
//	[activityIndicator startAnimating];
//	[self.movieView bringSubviewToFront:activityIndicator];
	
	if (!isAppRunninginBackground) {
//		btnRetryPlayback.hidden = false;
		[self.movieView bringSubviewToFront:btnRetryPlayback];
	}
}

#pragma mark - Internal

// Set PTZ View for PTZ enabled Camera
- (void)setPTZView
{
    cameraPTZSettingView = [[CameraPTZSettingView alloc] initWithFrame:CGRectMake(0, 0, ptzControlsView.frame.size.width, ptzControlsView.frame.size.height)];
    // Start
    [cameraPTZSettingView startPtzWithXaddrs:self.xAddr username:self.username password:self.password mediaProfileToken:self.ptzProfileToken];
    [ptzControlsView addSubview:cameraPTZSettingView];
    [ptzControlsView bringSubviewToFront:cameraPTZSettingView];
    
    // Disable all PTZ controls for PTZ Camera that does not have PTZ Profile configured with Media Profile
    if (self.isCameraPTZCapable && self.ptzProfileToken == nil)
    {
        ptzControlsView.userInteractionEnabled = NO;

        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"PTZ Settings of camera not configured properly"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
//                                       if (buttonIndex == 1)
//                                       {
//                                           [self playNewMedia];
//                                       }
//                                       else
//                                       {
                                           [self stopPlayback];
                                           [self closePlayback:nil];
//                                       }
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"PTZ Settings of camera not configured properly" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
    }
}

#pragma -mark VLC Methods

// Remove Space and Escape Characters
-(NSString *) UrlEncodeString:(NSString *) str
{
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
	
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Remote events

#if !TARGET_IPHONE_SIMULATOR

// Handle Remote events
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [mediaPlayer play];
            break;
			
        case UIEventSubtypeRemoteControlPause:
            [mediaPlayer pause];
            break;
        default:
            break;
    }
}

#pragma mark - controls

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{

    VLCMediaPlayer *mediaPlayerSender = [aNotification object];
    VLCMediaPlayerState currentState = mediaPlayerSender.state;
    
//    NSLog(@"mediaPlayerStateChanged sender status::%d",currentState);
    switch (currentState) {
        case VLCMediaPlayerStatePlaying:
        {
            relaodAttempt = 0;
        }
            break;
        case VLCMediaPlayerStateBuffering:
        {
            //		[mbProgressHUD hide:YES];
        }
            break;
        case VLCMediaPlayerStateError:
        {
            [self checkNetworkConnectionAndRetryStreaming];
        }
            break;
        case VLCMediaPlayerStateEnded:
        {
            [mbProgressHUD hide:YES];
            [self performSelector:@selector(closePlayback:) withObject:nil afterDelay:2.];
        }
            break;
        case VLCMediaPlayerStateStopped:
        {
            if (!isManualStopped) {
                [self checkNetworkConnectionAndRetryStreaming];
            }
            
        }
            break;
        default:
            break;
    }
}

- (void)checkNetworkConnectionAndRetryStreaming
{
	// check if Network reachable or not
	if (![self isNetworkReachable]) {
		
		[mbProgressHUD hide:YES];
		[self.view sendSubviewToBack:mbProgressHUD];
		
		// Network not reachable
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"Network not available"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
//                                       [self.navigationController popViewControllerAnimated:YES];
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		alert.tag = kCantPlayVideoAlertViewTag;
//		[alert show];
		[self performSelector:@selector(closePlayback:) withObject:nil afterDelay:2.];
	}
	else
	{
		btnRetryPlayback.hidden = true;
		textMessage = @"Problem while loading Video, trying to reconnect";
		mbProgressHUD.detailsLabelText = textMessage;
		[mbProgressHUD show:YES];
		
		// Network is reachable, 3 attapt for play video
		if (relaodAttempt < MAX_RELOAD_ATTEMPT) {
			// Increase reAttemp count and Retry for play video
			relaodAttempt ++;
			
			// First Stop current play-back object and start again
			[self stopPlayback];
			
			
#if !TARGET_IPHONE_SIMULATOR
			[self startPlayback];
#endif
		}
		else
		{
			[mbProgressHUD hide:YES];
			// Reached max attempt
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error"
                                                  message:@"Network not available"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.navigationController popViewControllerAnimated:YES];
                                           NSLog(@"OK action");
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to play streaming" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//			alert.tag = kCantPlayVideoAlertViewTag;
//			[alert show];
			[self performSelector:@selector(closePlayback:) withObject:nil afterDelay:2.];
		}
	}
}

- (void)stopPlayback
{
    if (mediaPlayer)
	{
        if (mediaPlayer.media)
		{
            [mediaPlayer pause];
            [mediaPlayer stop];
        }
		
        if (mediaPlayer)
		{
			mediaPlayer = nil;
		}
    }
    
    playerIsSetup = NO;
}

#pragma mark - Reachability

- (BOOL)isNetworkReachable{
	NetworkStatus netStatus = [hostReachability currentReachabilityStatus];

	switch (netStatus)
	{
		case NotReachable:        {
			return NO;
			break;
		}
			
		case ReachableViaWWAN:        {
			return YES;
			break;
		}
		case ReachableViaWiFi:        {
			return YES;
			break;
		}
	}
}

#pragma mark - Notification

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	isAppRunninginBackground = NO;
#if !TARGET_IPHONE_SIMULATOR
	if (shouldResumePlaying) {
//		[activityIndicator startAnimating];
		textMessage = @"";
		[self startPlayback];
	}
#endif
}


- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	isAppRunninginBackground = YES;
	shouldResumePlaying = YES;
	[self stopPlayback];
	[self closePlayback:nil];
	
	// Wait for VLC to stops proccesing Video
	sleep(3);
}

#pragma mark - AVSession delegate
- (void)beginInterruption
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinueAudioInBackgroundKey] boolValue])
        shouldResumePlaying = YES;
	
    [mediaPlayer pause];
}

- (void)endInterruption
{
    if (shouldResumePlaying) {
        [mediaPlayer play];
        shouldResumePlaying = NO;
    }
}

#pragma mark - Managing the media

- (void)startPlayback
{
	NSLog(@"startPlayback start ==========>");
    if (playerIsSetup)
        return;
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // For IP witour PTZ work

    mediaPlayer = [[VLCMediaPlayer alloc] init];
//    mediaPlayer.tag = 1000;
    [mediaPlayer setDelegate:self];
    [mediaPlayer setDrawable:self.movieView];
    
    VLCMedia *media;
    media = [VLCMedia mediaWithURL:self.url];
    
    NSDictionary *options = @{kVLCSettingSubtitlesFont: [defaults objectForKey:kVLCSettingSubtitlesFont],  kVLCSettingSubtitlesFontColor:  [defaults objectForKey:kVLCSettingSubtitlesFontColor], kVLCSettingDeinterlace: [defaults objectForKey:kVLCSettingDeinterlace], kVLCSettingSubtitlesFontSize : [defaults objectForKey:kVLCSettingSubtitlesFontSize]};
    
    [media addOptions:options];
    [mediaPlayer setMedia:media];
    
	mbProgressHUD.detailsLabelText = textMessage;
	[mbProgressHUD show:YES];
	[self.view bringSubviewToFront:mbProgressHUD];
	[self playNewMedia];
	NSLog(@"startPlayback end ==========>");
}

/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kCantPlayVideoAlertViewTag) {
		//Can't play Video button pressed.
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		if (buttonIndex == 1)
		{
			[self playNewMedia];
		}
		else
		{
			[self stopPlayback];
			[self closePlayback:nil];
		}
	}
}*/

- (void)playNewMedia
{
    [mediaPlayer play];
    playerIsSetup = YES;
}

#endif

#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

//
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation   = [[UIDevice currentDevice] orientation];
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;
    
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self willRotateToInterfaceOrientation:toOrientation duration:0.0];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self willAnimateRotationToInterfaceOrientation:toOrientation duration:[context transitionDuration]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self didRotateFromInterfaceOrientation:fromOrientation];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
			case UIDeviceOrientationPortraitUpsideDown:
                ptzControlsView.hidden = NO;
                self.movieView.frame = CGRectMake(0,44,768/2-3,479);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
				ptzControlsView.hidden = YES;
                self.movieView.frame = CGRectMake(0, 0,1024/2-3,768);
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
			case UIInterfaceOrientationPortraitUpsideDown:
                ptzControlsView.hidden = NO;
                self.movieView.frame = CGRectMake(0,44, self.view.frame.size.width/2-3,245);
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
			case UIInterfaceOrientationLandscapeRight:
				ptzControlsView.hidden = YES;
                if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
                {
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width/2-3,self.view.frame.size.height);//,320);
                }
                else
                {
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width/2-3,self.view.frame.size.height);//,320);
                }
                break;
                
            default:
                break;
        }
    }
}

//- (void)deviceOrientationDidChange:(NSNotification *)notification {
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
////    [self willRotateToInterfaceOrientation:orientation duration:1.0];
//    [self willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:1.0];
//}

@end
