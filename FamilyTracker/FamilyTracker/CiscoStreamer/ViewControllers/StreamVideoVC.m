//
//  StreamVideoVC.m
//  VideoStreamer
//
//  Created by AHMLPT0406 on 10/02/15.
//  Copyright (c) 2015 AHMLPT0406. All rights reserved.
//

#import "StreamVideoVC.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UINavigationController+AutorotationFromVisibleView.h"
#import "AlertView.h"
#import "Constant.h"
#import "NSDataAdditions.h"
#import "XMLDictionary.h"
#import "StreamerConfiguration.h"
#import "Base64.h"
#import "HexToRGB.h"
//#import "AppDelegate.h"

//---for service---//
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "Common.h"
#import "GlobalServiceManager.h"

@interface StreamVideoVC () {
    BOOL isStartRecording;
//    AppDelegate *appDelegate;
    LiveStreamController *liveStreamController;
    StreamerConfiguration *streamerConfig;
    
    //service
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    
    UIAlertView *alert;
    UIAlertController *alertVC;
    BOOL isStartSharingServicCall;
    NSArray *wowzaStandradResolutions;
    Notification *postAlert;
}

//@property (nonatomic, retain) MBProgressHUD *mBProgressHUD;
@property (retain, nonatomic) LiveStreamController *liveStreamController;
@property (assign, nonatomic) BOOL isStartRecording;

@end

@implementation StreamVideoVC

//isNetworkAvilable
@synthesize isStartRecording;
@synthesize liveStreamController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Live Video Streaming",nil);
    _startStopRecordingButton.hidden = YES;
    _startStopStreamingButton.hidden = YES;
//    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    streamerConfig = [StreamerConfiguration sharedInstance];
    wowzaStandradResolutions = @[@"720p", @"480p", @"360p", @"240p", @"160p"];
    [streamerConfig setResolutionForManualTrancoder:[wowzaStandradResolutions objectAtIndex:2]];
    isStartSharingServicCall = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopVideoStreamingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopVideoStreamingNotification:)
                                                 name:@"stopVideoStreamingNotification"
                                               object:nil];
    //set connection delegate
    //Start Capturing video
    self.liveStreamController = [[LiveStreamController alloc] init];
    self.liveStreamController.delegate = self;
    
//    //Setting Progressbar
//    self.mBProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:self.mBProgressHUD];
//    self.mBProgressHUD.delegate = self;
    
    [self notifyStatusUpdate:kStartDisplayingProcessing];
    
    [self.startStopRecordingView setHidden:YES];
    self.startStopRecordingView.translatesAutoresizingMaskIntoConstraints = NO;

    //---Initially set NavigationController * startStopStreamingButton hidden---
   
    ///
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
     self.navigationItem.leftBarButtonItem = leftBarBtnItem;
     self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
     self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
     leftBarBtnItem = nil;
    ///
    [self.startStopStreamingButton setEnabled:NO];
    self.navigationController.navigationBar.hidden = YES;
    //---Show Navigation BackButton after 31 second delay---//
    [self performSelector:@selector(showBackButton) withObject:nil afterDelay:31.0];
    [self initService];
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.liveStreamController screenAppear];
    [GlobalData sharedInstance].currentVC = self;
    if ([_alertType isEqualToString:kAlert_type_panic]) {
        [GlobalData sharedInstance].isInPanic = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.liveStreamController startStreaming];
}

- (void)viewWillDisappear:(BOOL)animated   
{
    //remove notification
    [super viewWillDisappear:YES];
    [GlobalData sharedInstance].isInPanic = NO;
//    [self.mBProgressHUD hide:YES];
    //---Set Globaly---//
    
//    NSLog(@"connection state=%@",self.connectionState);
//    if ([self.connectionState isEqualToString:kStartStreaming]) {
//        
//    }
//    else {
//        NSLog(@"streaming");
//        [self.liveStreamController stopStreaming];
//    }
//    [self.liveStreamController stopStreaming];
//    [self stopStreamingService];
//
//    appDelegate.isLiveStreamingView = NO;
    [GlobalData sharedInstance].isLiveStreamingView = NO;
    [self.liveStreamController screenDisapper];
//    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
}

#pragma -mark --Orientation Delegate Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotationToInterfaceOrientation toInterfaceOrientation:%d",toInterfaceOrientation);
    AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
    [self.cameraView.layer addSublayer:preview];
//    [self.liveStreamController updateVideoPreviewWithBound:self.cameraView.bounds];
}

#pragma -mark --Internal Methods

- (void)startVideoDisplay
{
    //Start captureing video and set view layer for user visibility
    AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
    [self.cameraView.layer addSublayer:preview];
}

#pragma -mark --IBAction Methods

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    return AVCaptureVideoOrientationPortrait;
}

#pragma -mark --Orientations Change Methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
   
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
        [self.cameraView.layer addSublayer:preview];
//        [self.liveStreamController updateVideoPreviewWithBound:self.cameraView.bounds];
        
        [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    }];
    
}

- (void)updateLabelWithStatusMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamingStatusLabel setText:message];
        [self.streamingStatusLabel setHidden:NO];
    });
}

#pragma -mark --AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma -mark --Button Actions

- (IBAction)switchCameraTapped:(id)sender {
    [self.liveStreamController switchCamera];
}

- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NotificationCenter Methods -
- (void)stopVideoStreamingNotification:(NSNotification *) notification {
    // [notification name] should always be @"AlertBatchNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"stopVideoStreamingNotification"]) {
        NSLog(@"connection state=%@",self.connectionState);
        if (isStartSharingServicCall) {
            isStartSharingServicCall = NO;
            [ModelManager sharedInstance].liveStreamingAlert = nil;
            [self.liveStreamController stopStreaming];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Service Call Methods -
- (void)initService {
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"StreamVideoVC";
    //Initialize Service CallBack Handler
    
    ReplyHandler *handler = [[ReplyHandler alloc]
                             initWithModelManager:_modelManager
                             operator:nil
                             progress:nil
                             signupUpdate:nil
                             addMemberUpdate:nil
                             updateUserUpdate:nil
                             settingsUpdate:nil
                             loginUpdate:nil
                             trackAppDayNightModeUpdate:(id)self
                             saveLocationUpdate:nil
                             getLocationUpdate:nil
                             getLocationHistoryUpdate:nil
                             saveAlertUpdate:(id)self
                             getAlertUpdate:nil
                             andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

- (void)startStreamingService {
    if (!isStartSharingServicCall) {
        isStartSharingServicCall = YES;
        NSString *guardianId = @"";
        if([_modelManager.user.role integerValue] == 1) {
            guardianId = _modelManager.user.identifier;
            
        }else {
            guardianId = _modelManager.user.guardianId;
        }
        
        NSString *sharedUrlLink = [NSString stringWithFormat:@"rtmp://%@:%@/%@/%@", 
                                   streamerConfig.getWowzaServerIP,
                                   streamerConfig.getWowzaServerPort,
                                   streamerConfig.getWowzaApplication,
                                   streamerConfig.getWowzaStreamName]; 
        
        NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                      kFamily_id_key:guardianId,
                                      kCreated_user:_modelManager.user.identifier,
                                      kLink:sharedUrlLink,
                                      kAlert_type:_alertType,
                                      kResourceTypeKey: kAlertResourceTypeVideo,//Video
                                      kLocationKey:
                                          @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                             kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                              }
                                      };
        
        NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:requestBody
                                         };
        [_serviceHandler onOperate:requestBodyDic];
    }
}

- (void)stopStreamingService {
    if (isStartSharingServicCall) {
        isStartSharingServicCall = NO;
        [[GlobalServiceManager sharedInstance] stopStreamingService];
    }
}

#pragma mark - Service Callback Method -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == SAVE_ALERT_SUCCEEDED) {//---Save Alerts
            NSError *error = nil;
            _modelManager.liveStreamingAlert = [[Notification alloc] initWithDictionary:object error:&error];
            if ([_alertType isEqualToString:kAlert_type_panic]) {
                [Common displayToast:NSLocalizedString(@"Video panic alert has been sent.", nil)  title:nil duration:2.0];
            }else {
                [Common displayToast:NSLocalizedString(@"Video streaming alert has been sent.", nil)  title:nil duration:2.0];
            }
        }else if(sourceType == SAVE_ALERT_FAILED) {
            if ([_alertType isEqualToString:@"1"]) {
                [Common displayToast:NSLocalizedString(@"Video panic alert failed to send!", nil)  title:nil duration:2.0];
            }else {
                [Common displayToast:NSLocalizedString(@"Video streaming alert failed to send!", nil)  title:nil duration:2.0];
            }
        }
    });
}

- (IBAction)tappedStartStopRecording:(id)sender {
    if (!self.isStartRecording) {
        //Start Streaming
        self.isStartRecording = YES;
        [self notifyStatusUpdate:kStartRecording];
    } else {
        self.isStartRecording = NO;
        [self notifyStatusUpdate:kStopRecording];
    }
}

- (IBAction)tappedStopStreaming:(id)sender {
    
    NSLog(@"connection state=%@",self.connectionState);
    
    [self.liveStreamController stopStreaming];
    [self stopStreamingService];
    
    //---Make service call to stop Streaming---//
//    [self.liveStreamController stopStreaming];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)startRecording {
    
    NSLog(@"in startRecording");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //[self.startStopRecordingView setHidden:NO];
        self.sizeLabel.text = @"";
        [_startStopRecordingButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    });
}

- (void)stopRecording {
    
    NSLog(@"in stopRecording");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_startStopRecordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
        
        NSLog(@"In if for hide Recording view");
        [self.startStopRecordingView setHidden:YES];
    });
}

- (void)updateStartStopStreamingButtonTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.startStopStreamingButton setTitle:title forState:UIControlStateNormal];
        [self.startStopStreamingButton setTitle:title forState:UIControlStateSelected];
    });
}

- (void)closeStreamingVCAndLoadInstantClient {
    dispatch_async(dispatch_get_main_queue(), ^{
//        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        [delegate openReturnToInstantConnect];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)showAlertPopup:(NSString *)message {
    
    alertVC =   [UIAlertController
                 alertControllerWithTitle:@"Error Connection Failed"
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOk = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertVC dismissViewControllerAnimated:YES completion:nil];
                                [self.liveStreamController stopStreaming];
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    
    [alertVC addAction:btnOk];
    [self presentViewController:alertVC animated:YES completion:nil];
    
//    [self.mBProgressHUD hide:YES];
}

#pragma mark - LiveStreamControllerDelegate Methods

- (void)updateAvailableSizeLabel:(NSString *)sizeInStr {
    
    self.sizeLabel.text = sizeInStr;
}

- (void)setRTSPURL:(NSString *)rtspURL {
    [self.rtspServerUrlLabel setHidden:NO];
    self.rtspServerUrlLabel.text = rtspURL;
}

- (void)notifyOnError:(NSString *)status {
    NSString *alertMessage = @"";
    
    if ([status isEqualToString:kConnectionErrorMessageRTSPSink]) {
        alertMessage = status;
        
    } else if ([status isEqualToString:kConnectionErrorMessageRequestFail]) {
        alertMessage = @"Wowza server unreachable\nPlease check wowza setting or netwrok connectivity";
        
    } else if ([status isEqualToString:kConnectionErrorMessageStreamPlay]) {
        alertMessage = status;
        
    } else if ([status isEqualToString:kConnectionErrorMessageTimeOut]) {
        alertMessage = status;
    }
    else if ([status isEqualToString:kAuthenticationFailed]) {
        alertMessage = @"Please Enter Valid Ipaddress, Username, Password and Port.";
    }
    else if ([status isEqualToString:kNetworkNotAvailable]) {
        alertMessage = @"Internet Connection Is Not Avilable";
    }
    
    [self showAlertPopup:alertMessage];
    [self.liveStreamController stopVideoRecording];
}

- (void)notifyStatusUpdate:(NSString *)status
{
    NSLog(@"in STREAMER PRJ notifyStatusUpdate:%@",status);
    self.connectionState = status;
    
    if ([status isEqualToString:kStartDisplayingProcessing]) {
        [self notifyStatusUpdate:kConnectionStateConnecting];
    }
    else if ([status isEqualToString:kStartStreaming]) {
        if ([alert isVisible]|| [alertVC isViewLoaded])
        {
            [alert dismissWithClickedButtonIndex:1 animated:YES];
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }

        [self startVideoDisplay];
    }
    else if ([status isEqualToString:kStopStreaming]) {
        
        [self.liveStreamController stopVideoRecording];
        NSLog(@"Stop Video Stream and Encoding");
    }
    else if ([status isEqualToString:kStartRecording]) {
        [self.liveStreamController startVideoRecording];
        
        [self startRecording];
    }
    else if ([status isEqualToString:kStopRecording]) {
        [self.liveStreamController stopVideoRecording];
        
        [self stopRecording];
    }
    else if ([status isEqualToString:kConnectionStateConnecting]) {
        
            if ([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient]){
                [self updateLabelWithStatusMessage:[NSString stringWithFormat:@"%@...",kConnectionStateConnecting]];
            }
            else {
                [self updateLabelWithStatusMessage:[NSString stringWithFormat:@"%@...",kConnectionStateInitiating]];
            }
        
    } else if ([status isEqualToString:kConnectionStateConnected]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.navigationBar.hidden = YES;
            [self.startStopStreamingButton setEnabled:YES];
            [self.startStopStreamingButton setHidden:NO];
        });
        NSLog(@"Streaming Started, So set isSettingChanged ==== NO");
        [self updateLabelWithStatusMessage:NSLocalizedString(kConnectionStateStreaming,nil)];
        [self startStreamingService];
    }
    else if ([status isEqualToString:kConnectionStateDisconnected]) {
        [self updateLabelWithStatusMessage:kConnectionStateDisconnected];
    }
    else if ([status isEqualToString:kFailToStartStreaming]) {
        [self closeStreamingVCAndLoadInstantClient];
    }
}

- (void) showBackButton {
//    NSLog(@"=%@",_connectionState);
    if (![self.connectionState isEqualToString:kConnectionStateConnected]){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.navigationBar.hidden = NO;
        });
    }
}


@end
