//
//  CameraStreamingViewController.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 21/10/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import "StreamingVC.h"
#import "Constant.h"
#import "UINavigationController+AutorotationFromVisibleView.h"

#import "StreamerConfiguration.h"
#import "GlobalData.h"

#define ptzViewWidth    113
#define ptzViewHeight   147

#define ptzViewWidthiPad    155
#define ptzViewHeightiPad   194
#import "HexToRGB.h"
#import "Constant.h"
#import "FamilyTrackerDefine.h"

@interface StreamingVC () {
	NSString *textMessage;
    
    BOOL isPlayerAlreadyStarted;
//    __weak IBOutlet NSLayoutConstraint *heightMovieView;
//    __weak IBOutlet NSLayoutConstraint *widthMovieView;
    
    StreamerConfiguration *streamerConfig;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ptzControlViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movieViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ptzControlTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ptzControlBottomMarginConstraint;

- (void)startPlayback;
- (void)stopPlayback;
- (void)playNewMedia;

@end

@implementation StreamingVC

@synthesize isONVIFPlayer, livePlaybackController, isDispalyInMultiPane, myTagValue;
@synthesize isFullScreenEnabled, movieView, ptzControlsView, stateBeforeFullScreen, isShowPTZView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    cameraPTZSettingView = nil;
    isPlayerAlreadyStarted = NO;
    self.isFullScreenEnabled = NO;
    
    if (self.isDispalyInMultiPane) {
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    }
    [self initializePlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [GlobalData sharedInstance].currentVC = self;
    //	[self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [self startPlaying];
    self.title = NSLocalizedString(@"Streaming", nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
#if !TARGET_IPHONE_SIMULATOR
    if (!self.isDispalyInMultiPane) {
        [self.livePlaybackController manuallyStopPlayback];
        
        [self stopPlayback];
    }
#endif
    
    [self.tabBarController.tabBar setHidden:NO];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [self.livePlaybackController screenDisappear];
    
    [super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // If any memory warning occur then stop streaming to prevent OS to kill application
#if !TARGET_IPHONE_SIMULATOR
    [self stopPlayback];
#endif
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"---------------------- streamer dealloc");
}

- (void)initializePlayer {
    
    btnRetryPlayback.hidden = true;
    textMessage = @"";
    
    mbProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    mbProgressHUD.backgroundColor = [UIColor darkGrayColor];
    [self.movieView addSubview:mbProgressHUD];
    mbProgressHUD.delegate = self;
    [mbProgressHUD hide:YES];
    
    self.livePlaybackController = [[LivePlaybackController alloc] init];
    self.livePlaybackController.delegate = self;
}

- (void)startPlaying {
    isPlayerAlreadyStarted = YES;
    // Start Streaming on When View Appeared
#if !TARGET_IPHONE_SIMULATOR
    [self startPlayback];
#endif
    
    // PTZ View should be visible only when playing for PTZ Camera with ONVIF support
    if (self.isONVIFPlayer && self.isCameraPTZCapable)
    {
        if (self.isDispalyInMultiPane) {
            [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
        }
        
        [self setPTZView];
    }
    else {
        self.ptzControlsView.hidden = YES;
        _ptzControlViewHeightConstraint.constant = 0;
        _ptzControlTopMargin.constant = 0;
        _ptzControlBottomMarginConstraint.constant = 0;
        _movieViewHeightConstraint.constant = self.view.frame.size.height;
    }
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

#pragma mark - Internal

// Set PTZ View for PTZ enabled Camera
- (void)setPTZView
{
    if (cameraPTZSettingView == nil) {
        cameraPTZSettingView = [[CameraPTZSettingView alloc] initWithFrame:CGRectMake(0, 0, self.ptzControlsView.frame.size.width, self.ptzControlsView.frame.size.height)];
        [self.ptzControlsView addSubview:cameraPTZSettingView];
    }
    
    // Start
    [cameraPTZSettingView startPtzWithXaddrs:self.xAddr username:self.username password:self.password mediaProfileToken:self.ptzProfileToken];
    
    [self.ptzControlsView bringSubviewToFront:cameraPTZSettingView];
    
    // Disable all PTZ controls for PTZ Camera that does not have PTZ Profile configured with Media Profile
    if (self.isCameraPTZCapable && self.ptzProfileToken == nil)
    {
        self.ptzControlsView.userInteractionEnabled = NO;
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"PTZ Settings of camera not configured properly"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self stopPlayback];
                                       [self.livePlaybackController closePlayback:nil];
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
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
            [self.livePlaybackController play];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            [self.livePlaybackController pause];
            break;
        default:
            break;
    }
}

#pragma mark - controls

- (void)manuallyStopPlayback {
    BOOL isPlayingWithOthers = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
    
    if (!isPlayingWithOthers) {
        NSLog(@"NOT anyother AUDIO playing.");
        [self.livePlaybackController manuallyStopPlayback];
        
        [self stopPlayback];
    }
    else
        NSLog(@"STILL some AUDIO playing.");
    
}

// Play/Pause Operation
- (BOOL)isVideoPlaying {
    return [self.livePlaybackController isPlaying];
}

- (void)pauseVideo {
    [self.livePlaybackController pause];
}

- (void)playVideo {
    [self.livePlaybackController play];
}

// Audio operations
- (BOOL)isAudioMuted {
    return [self.livePlaybackController isAudioMuted];
}

- (void)muteAudio {
    [self.livePlaybackController muteAudio];
}

- (void)unmuteAudio {
    [self.livePlaybackController unMuteAudio];
}

- (void)stopPlayback
{
    [self.livePlaybackController stopPlayback];
}

#pragma mark - PTZ Control Show/Hide

- (BOOL)isShowPTZControlView {
    return self.isShowPTZView;
}

- (void)showHidePTZControlView:(BOOL)isShow {
    self.ptzControlsView.hidden = !isShow;
    
    if (!isShow) {
        // Hide PTZ Control
        _ptzControlViewHeightConstraint.constant = 0;
        _ptzControlTopMargin.constant = 0;
        _ptzControlBottomMarginConstraint.constant = 0;
    }
    else {
        // Show PTZ Control
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _ptzControlViewHeightConstraint.constant = ptzViewHeightiPad;
        }
        else {
            _ptzControlViewHeightConstraint.constant = ptzViewHeight;
        }
        
        _ptzControlTopMargin.constant = 4;
        _ptzControlBottomMarginConstraint.constant = 6;
    }
    
    self.isShowPTZView = isShow;
    
    NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
    [self willAnimateRotationToInterfaceOrientation:toOrientation duration:0];
}

#pragma mark - Managing the media

- (void)startPlayback
{
    [self.livePlaybackController initializeMediaPlayer:self.movieView withURL:self.url forTag:self.myTagValue ipCameraRTSPURL:self.isONVIFPlayer];
    
    mbProgressHUD.detailsLabelText = textMessage;
    [mbProgressHUD show:YES];
    [self.view bringSubviewToFront:mbProgressHUD];
}

- (void)playNewMedia
{
    [self.livePlaybackController play];
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

- (void)setMediaAndPTZViewPortrait {
    
    if (!self.isShowPTZView) {
        self.movieView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height);
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.movieView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height-ptzViewHeightiPad-5);
        
        CGFloat xPos = self.view.frame.size.width/2 - ptzViewWidthiPad/2;
        self.ptzControlsView.frame = CGRectMake(xPos+10, self.movieView.frame.size.height + 3,ptzViewWidthiPad,ptzViewHeightiPad);
        
        _movieViewHeightConstraint.constant = self.view.frame.size.height-ptzViewHeightiPad-5;
        _ptzControlViewHeightConstraint.constant = ptzViewHeightiPad;
    }
    else {
        self.movieView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height-ptzViewHeight-5);
        
        CGFloat xPos = self.view.frame.size.width/2 - ptzViewWidth/2;
        self.ptzControlsView.frame = CGRectMake(xPos, self.movieView.frame.size.height + 3,ptzViewWidthiPad,ptzViewHeight);
        
        _movieViewHeightConstraint.constant = self.view.frame.size.height-ptzViewHeight-5;
        _ptzControlViewHeightConstraint.constant = ptzViewHeight;
    }
    
    _ptzControlTopMargin.constant = 4;
    _ptzControlBottomMarginConstraint.constant = 6;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSString *multiPaneStyle = [streamerConfig getSelectedLayoutStyle];
    
    if (self.isFullScreenEnabled) {
        multiPaneStyle = kLayoutStyle1x1;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            // handle landscape
            
            if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                
                if (self.isShowPTZView) {
                    self.ptzControlsView.hidden = NO;
                }
                
                if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    _movieViewHeightConstraint.constant = self.view.frame.size.height;
                    _ptzControlViewHeightConstraint.constant = 0;
                    _ptzControlTopMargin.constant = 0;
                    _ptzControlBottomMarginConstraint.constant = 0;
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                    
                    [self setMediaAndPTZViewPortrait];
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                    
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width-ptzViewWidthiPad-5,self.view.frame.size.height);
                    
                    CGFloat yPos = self.view.frame.size.height/2 - ptzViewHeightiPad/2;
                    self.ptzControlsView.frame = CGRectMake(self.movieView.frame.size.width + 3,yPos,ptzViewWidthiPad,ptzViewHeightiPad);
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
            }
            else
            {
                self.ptzControlsView.hidden = YES;
                _ptzControlViewHeightConstraint.constant = 0;
                _ptzControlTopMargin.constant = 0;
                _ptzControlBottomMarginConstraint.constant = 0;
                _movieViewHeightConstraint.constant = self.view.frame.size.height;
                
                self.movieView.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
            }
            
        } else {
            // handle portrait
            
            if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                
                if (self.isShowPTZView) {
                    self.ptzControlsView.hidden = NO;
                }
                
                if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                    [self setMediaAndPTZViewPortrait];
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                    [self setMediaAndPTZViewPortrait];
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                    [self setMediaAndPTZViewPortrait];
                }
            }
            else {
                self.ptzControlsView.hidden = YES;
                _ptzControlViewHeightConstraint.constant = 0;
                _ptzControlTopMargin.constant = 0;
                _ptzControlBottomMarginConstraint.constant = 0;
                
                if (self.isDispalyInMultiPane) {
                    _movieViewHeightConstraint.constant = self.view.frame.size.height;
                    self.movieView.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
                }
                else {
                    _movieViewHeightConstraint.constant = 479;
                    self.movieView.frame = CGRectMake(0,44,768,479);
                }
            }
        }
    }
    else
    {
        if (UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation) && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            // handle landscape
            
            if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                if (self.isShowPTZView) {
                    self.ptzControlsView.hidden = NO;
                }
                
                if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                    
                    if (self.isShowPTZView) {
                        CGFloat xpos = self.view.frame.size.width - ptzViewWidth-50;
                        
                        self.movieView.frame = CGRectMake(0,0, xpos,self.view.frame.size.height);
                        self.ptzControlsView.frame = CGRectMake(self.movieView.frame.origin.x +self.movieView.frame.size.width + 5,self.movieView.frame.origin.y-10,ptzViewWidth,ptzViewHeight);
                    }
                    else {
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
            }
            else
            {
                self.ptzControlsView.hidden = YES;
                _ptzControlViewHeightConstraint.constant = 0;
                _ptzControlTopMargin.constant = 0;
                _ptzControlBottomMarginConstraint.constant = 0;
                _movieViewHeightConstraint.constant = self.view.frame.size.height;
                
                if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
                {
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);//,320);
                }
                else
                {
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);//,320);
                }
            }
            
        } else {
            // handle portrait
            
            if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                
                if (self.isShowPTZView) {
                    self.ptzControlsView.hidden = NO;
                }
                
                if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                    [self setMediaAndPTZViewPortrait];
                    
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                    [self setMediaAndPTZViewPortrait];
                    
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
                else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                    [self setMediaAndPTZViewPortrait];
                }
            }
            else {
                
                self.ptzControlsView.hidden = YES;
                _ptzControlViewHeightConstraint.constant = 0;
                _ptzControlTopMargin.constant = 0;
                _ptzControlBottomMarginConstraint.constant = 0;
                _movieViewHeightConstraint.constant = self.view.frame.size.height;
                
                if (self.isDispalyInMultiPane) {
                    self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                }
                else {
                    self.movieView.frame = CGRectMake(0,44, self.view.frame.size.width,self.view.frame.size.height-44);
                }
            }
        }
    }
}

#pragma mark - LivePlaybackController Delegate Methods

- (void)notifyOnError:(NSString *)status {
    if ([status isEqualToString:kNetworkNotAvailable]) {
        
        [mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
        
        // Network not reachable
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:kNetworkNotAvailable
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([status isEqualToString:kProblenWhileLoadingVideo]) {
        
        btnRetryPlayback.hidden = true;
        //sohan
//        textMessage = @"Problem while loading Video, trying to reconnect";
//        mbProgressHUD.detailsLabelText = textMessage;
//        [mbProgressHUD show:YES];
    }
}

- (void)notifyStatusUpdate:(NSString *)status forPositionView:(NSUInteger)position {
    
    //    NSLog(@"notifyStatusUpdate PRJ  +=+=+=+=+=+=+=+=+=+=+=+=+=+=+= status:%@",status);
    
    if ([status isEqualToString:kStartPlayback] || [status isEqualToString:kAppEnterInForeground]) {
        textMessage = @"loading";
        [self startPlayback];
    }
    else if ([status isEqualToString:kStopPlayback]) {
        [self stopPlayback];
    }
    else if ([status isEqualToString:kClosePlayback]) {
        [mbProgressHUD hide:YES];
        [self.view bringSubviewToFront:self.movieView];
    }
    else if ([status isEqualToString:kAppRunningInBackground]) {
        [self.movieView bringSubviewToFront:btnRetryPlayback];
    }
    else if ([status isEqualToString:kStartPlaying]) {
        //[mbProgressHUD hide:YES];
        [mbProgressHUD hide:YES afterDelay:5.0];
        [self.view sendSubviewToBack:mbProgressHUD];
        [self.movieView setNeedsDisplay];
        [self.movieView setNeedsLayout];
        [self.movieView layoutIfNeeded];
        
        //---forcefuly stopped playback when in livestreaming---//
        //---Set Globaly---//
        if ([GlobalData sharedInstance].isLiveStreamingView) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"stopPlayingNotification"
             object:self userInfo:nil];
        }

        ///
    }
    else if ([status isEqualToString:kStartBuffering]) {
        //[mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
    }
    else if ([status isEqualToString:kPlayerIsReady]) {
        //[mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
        
        [self playNewMedia];
    }
}

- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
