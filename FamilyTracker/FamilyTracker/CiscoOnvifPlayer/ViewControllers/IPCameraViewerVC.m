//
//  IPCameraViewerVC.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 9/24/14.
//  Copyright (c) 2014 eInfochips. All rights reserved.
//

#import "IPCameraViewerVC.h"
#import "XMLGenerator.h"
#import "XMLDictionary.h"
#import "Constant.h"

#import "UINavigationController+AutorotationFromVisibleView.h"

#define UDP_REQUEST_PORT 3702
#define MAXIMUM_CAMERADATETIME_DEVICEDATETIME_DIFFERENCE 100.0	//Seconds

@interface IPCameraViewerVC ()
{
	NSInteger selectedRow;
    
    IPCameraController *ipCameraController;
    StreamingVC *streamingVC;
}

@property (nonatomic, retain) IPCameraController *ipCameraController;

@end

@implementation IPCameraViewerVC

@synthesize isFirstTimeLoadScreen, ipCameraController;
@synthesize isDispalyInMultiPane, multiViewPaneVC, ipCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if (self.isDispalyInMultiPane) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.preferredContentSize = CGSizeMake(570, 450);
        }
        else {
            self.preferredContentSize = CGSizeMake(100, 150);
        }
    }

    if (self.ipCameraController == nil) {
        self.ipCameraController = [[IPCameraController alloc] init];
    }
    
    self.ipCameraController.delegate = self;
    
    //---Initialized MBProgressHUD---//
//	self.mbProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
//	[self.view addSubview:self.mbProgressHUD];
//	self.mbProgressHUD.delegate = self;
    
	// Only first time we will Create GCDAsyncUdpSocket object, after that we will re-use that initialiazed object
	if (self.isFirstTimeLoadScreen) {
		// Create GCDAsyncUdpSocket object
		[self.ipCameraController createGcdAsyncUdpSocketObject];
		self.isFirstTimeLoadScreen = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.mbProgressHUD.labelText = @"Loading Camera...";
//    [self.mbProgressHUD show:YES];
    [self btnProbeTouched];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait]                             forKey:@"orientation"];
    }
    
    [self.tabBarController.tabBar setHidden:YES];
    selectxAddrs = [NSString stringWithFormat:@"%@",SELECT];
    
	arrProfileListPTZ = [[NSMutableArray alloc] init];
	arrProfileList = [[NSMutableArray alloc] init];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)setIPControllerObject:(IPCameraController *)localIPCameraObject {
    self.ipCameraController = localIPCameraObject;
}

//---sohan---//
- (void)setCamera:(Camera *)ipCamera1 {
    self.ipCamera = ipCamera1;
}
//---sohan---//
#pragma mark - sohan updated
- (void) btnProbeTouched {
    [self.ipCameraController setIPAddress:ipCamera.ipAddress withUsername:ipCamera.userName withPassword:ipCamera.password withMediaProfile:@""];
    
    [arrProfileList removeAllObjects];
    
    // Check camera IP format
    if (![self isValidateIp:ipCamera.ipAddress])
    {
        [self showAlertMessage:@"Error" message:@"Please Enter valid IP Address"];
        return;
    }
    else if([ipCamera.userName length]<=0 || [ipCamera.password length]<=0 )
    {
        [self showAlertMessage:@"Error" message:@"Please enter username and password"];
        return;
    }
    
    xAddrs = nil;
    
    // Send Probe message on camera for getting XAddr
    [self.ipCameraController sendProbRequest];
}

- (void) btnConnectTouched {
    // Check for empty xAddr
    if (!([selectxAddrs isEqualToString:@""] || [selectxAddrs isEqualToString:@"Select"]))
    {
        // conditional check to verify DateTime difference between camera and device
#if VALIDATE_CAMER_DEVICE_TIME_DIFFERENCE
        [self getCameraDateTime:selectxAddrs];
#else
        [self getCameraMediaProfiles:selectxAddrs];
#endif
    }
    else
    {
//        [self.mbProgressHUD hide:YES];
        [self showAlertMessage:@"Error" message:@"Please select Device Service Address"];
    }
}

- (void) btnPlayTouched {
    __weak __typeof__(self) weakSelf = self;
    NSString *profileToken = [[arrProfileList objectAtIndex:selectedRow] valueForKey:@"Token"];
    if (profileToken)
    {
        [weakSelf getCameraStreamURI:selectedAddress profileToken:profileToken];
        
    }
    else
    {
        [weakSelf showAlertMessage:@"Error" message:@"Unable to get profile token"];
    }
}

#pragma -mark Inrternal Methods

-(NSString *)convertBitrate :(int)bitRate {
    
	NSString *str;
	if (bitRate > 1000)
	{
		str =[NSString stringWithFormat:@"%d Mbps",bitRate/1000];
	}
	else
	{
		str =[NSString stringWithFormat:@"%d Kbps",bitRate];
	}
	return str;
}

// For ONVIF communication, Camera DateTime and Device DateTime should be same
// Compare Camera & Device DateTime
- (BOOL)checkCameraDateTimeWithDeviceDateTime:(NSDictionary *)cameraDateTimeDic
{
	NSDictionary *dateDic = [[cameraDateTimeDic valueForKey:UTC_DATE_TIME] valueForKey:DATE];
	NSDictionary *timeDic = [[cameraDateTimeDic valueForKey:UTC_DATE_TIME] valueForKey:TIME];
	
	NSString *strCameraDate = [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",[dateDic valueForKey:DAY],[dateDic valueForKey:MONTH],[dateDic valueForKey:YEAR],[timeDic valueForKey:HOUR],[timeDic valueForKey:MINUTE],[timeDic valueForKey:SECOND]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
	NSDate *cameraDateTime = [dateFormatter dateFromString:strCameraDate];
	
	// TODO : Improve logic for getting date in UTC only
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	NSString *strDeviceDate = [dateFormatter stringFromDate:[NSDate date]];
	
	NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
	[dateFormatter1 setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
	NSDate *deviceDateTime = [dateFormatter1 dateFromString:strDeviceDate];
	
	// Check difference between two dates in seconds
	NSTimeInterval differenceBetweenDates = [deviceDateTime timeIntervalSinceDate:cameraDateTime];
	if (fabs(differenceBetweenDates) < MAXIMUM_CAMERADATETIME_DEVICEDATETIME_DIFFERENCE)
	{
		return true;
	}
	return false;
}

// Move to Streaming View Controller
- (void)pushToStreamingViewController:(NSString *)videoUri
							 xAddress:(NSString *)xAddress
				   isCameraPTZCapable:(BOOL)isCameraPTZCapable
{
    videoUri = [videoUri stringByReplacingOccurrencesOfString:@"rtsp://" withString:[NSString stringWithFormat:@"rtsp://%@:%@@",ipCamera.userName,ipCamera.password]];
    
    if (isDispalyInMultiPane) {
    
        [self.multiViewPaneVC loadStreamerForVideoURI:videoUri xAddress:xAddress username:ipCamera.userName password:ipCamera.password isCameraPTZCapable:isCameraPTZCapable isONVIFPlayer:YES ptzProfileToken:ptzProfileToken forPanel:[ipCamera.panelTag integerValue]];
    }
}

- (StreamingVC *)getStreamerVCObject {
    return streamingVC;
}

- (NSMutableArray *)getMediaProfile:(NSDictionary *)profilesDic
{
	NSMutableArray *arrProfiles = [[NSMutableArray alloc] init];
	
	// If response contains multiple profiles then get the token for profile which has VideoEncoderConfiguration
	NSArray *profilesArray = (NSArray *)profilesDic;
	for (NSDictionary *profile in profilesArray)
	{
		// Get the token for profile which has VideoEncoderConfiguration
		if ([profile valueForKey:VIDEO_ENCODER_CONFIGURATION] != nil)
		{
			NSMutableDictionary *profileDic = [[NSMutableDictionary alloc] init];
			[profileDic setValue:[profile valueForKey:TOKEN] forKey:@"Token"];
			
			NSString *bitRateKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RATE_CONTROL, BITRATE_LIMIT];
			[profileDic setValue:[profile valueForKeyPath:bitRateKeyPath] forKey:@"BitRate"];
			
			
			NSString *fpsKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RATE_CONTROL, FRAME_RATE_LIMIT];
			[profileDic setValue:[profile valueForKeyPath:fpsKeyPath] forKey:@"Fps"];
			
			NSString *heightKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RESOLUTION, HEIGHT];
			[profileDic setValue:[profile valueForKeyPath:heightKeyPath] forKey:@"Height"];
			
			NSString *widthKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RESOLUTION, WIDTH];
			[profileDic setValue:[profile valueForKeyPath:widthKeyPath] forKey:@"Width"];

			[arrProfiles addObject:profileDic];
		}
	}
	return arrProfiles;
}

//Get Appropriate PTZ Media Profile token for PTZ Operations
- (NSString *)getPtzProfileToken:(NSDictionary *)profilesDic
{
	NSDictionary *profileDic;
	
	// If response contains multiple profiles then get the token for profile which has VideoEncoderConfiguration
	NSArray *profilesArray = (NSArray *)profilesDic;
	for (NSDictionary *profile in profilesArray)
	{
		// Get the token for profile which has VideoEncoderConfiguration
		if ([profile valueForKey:PTZ_CONFIGURATION] != nil)
		{
			profileDic = profile;
			break;
		}
	}
	
	return [profileDic valueForKey:TOKEN];;
}

// Show alert message for given title and message
- (void)showAlertMessage:(NSString *)title
				 message:(NSString *)message
{
//    [self.mbProgressHUD hide:YES];
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@ \nTry again",message] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.multiViewPaneVC removeIPCameraViewer];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


#pragma -mark --Validation

// Check camera Ip format
- (BOOL)isValidateIp:(NSString*)string
{
	// Check if valid IP Address
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
								  options:0
								  error:nil];
	// return true for valid IP Address
	return ([regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])]==1 ? TRUE : FALSE);
}

#pragma -mark Camera Calls

// Get camera DateTime and Validate it with Device DateTime
- (void)getCameraDateTime:(NSString *)xAddress
{
    [self.ipCameraController getCameraDateTime:xAddress];
}

// Get Available Media Profiles from camera
- (void)getCameraMediaProfiles:(NSString *)xAddress
{
    selectedAddress = xAddress;
    [self.ipCameraController getCameraMediaProfiles:xAddress];
}

// Get RTSP Uri for Media Profile
- (void)getCameraStreamURI:(NSString *)xAddress
			  profileToken:(NSString *)profileToken
{
    [self.ipCameraController getCameraStreamURI:xAddress withProfileToken:profileToken];
}

// Get PTZ Capabilities
- (void)getPtzCapabilities:(NSString *)xAddress
				  mediaUri:(NSString *)mediaUri
			  profileToken:(NSString *)profileToken
{
    [self.ipCameraController getPtzCapabilities:xAddress mediaURI:mediaUri profileToken:profileToken];
}

// Get Media Capabilities
- (void)getMediaCapabilities:(NSString *)xAddress
{
    [self.ipCameraController getMediaCapabilities:xAddress];
}

#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - IPCameraControllerDelegate

- (void)notifyOnError:(NSString *)status error:(NSString *)message; {
//    [self.mbProgressHUD hide:YES];
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@ \nTry again or Cancel",message] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Retry"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                   [self btnProbeTouched];
//                                   self.mbProgressHUD.labelText = @"Loading Camera...";
//                                   [self.mbProgressHUD show:YES];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                       [self.multiViewPaneVC removeIPCameraViewer];
                                   }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)notifyStatusUpdate:(NSString *)status withResponse:(NSDictionary *)responseDic {
    
    if ([status isEqualToString:kCameraDatetimeAPIResponse]) {
        // Get media profiles
        [self getCameraMediaProfiles:[responseDic valueForKey:@"xAddress"]];
    }
    else if ([status isEqualToString:kStreamURIAPIResponse]) {
        
        [self getPtzCapabilities:[responseDic valueForKey:@"xAddress"] mediaUri:[responseDic valueForKey:@"mediaUri"] profileToken:[responseDic valueForKey:@"profileToken"]];
        //sohan
    }
    else if ([status isEqualToString:kMediaProfileAPIResponse]) {
        
        NSDictionary *profilesDic = [[[responseDic valueForKey:KEY_BODY] valueForKey:GET_PROFILES_RESPONSE] valueForKey:PROFILES];
        
        arrProfileList = [self getMediaProfile:profilesDic];
        ptzProfileToken = [self getPtzProfileToken:profilesDic];
        
        // Check if any profile token is available or not
        if (arrProfileList.count > 0)
        {
            selectedRow = 0;
            // Show Profile controls if any valid profile found
            //sohan for play method
            [self btnPlayTouched];
            
        } else {
            [self showAlertMessage:@"Error" message:@"Unable to get profile token"];
            
            // Hide profile selection and Play button if there is not any valid profile found
        }
    }
    else if ([status isEqualToString:kPTZCapabilitiesAPIResponse]) {
        NSDictionary *ptzDic = [[[[responseDic valueForKey:KEY_BODY] valueForKey:GET_CAPABILITIES_RESPONSE] valueForKey:CAPABILITIES] valueForKey:PTZ];
        if(ptzDic != nil)
        {
            NSString *xAddr = [ptzDic valueForKey:XADDR];
            [self pushToStreamingViewController:[responseDic valueForKey:@"mediaUri"] xAddress:xAddr isCameraPTZCapable:YES];
        }
        else
        {
            [self pushToStreamingViewController:[responseDic valueForKey:@"mediaUri"] xAddress:[responseDic valueForKey:@"xAddress"] isCameraPTZCapable:NO];
        
//            [self.mbProgressHUD hide:YES];
            //---sohan final done---|
        }
    }
    else if ([status isEqualToString:kMediaCapabilitiesAPIResponse]) {
        // Set MediaUri here
        NSString *xAddress = [[[[[responseDic valueForKey:KEY_BODY] valueForKey:GET_CAPABILITIES_RESPONSE] valueForKey:CAPABILITIES] valueForKey:MEDIA] valueForKey:XADDR];
        
        if (xAddress) {
            
            xAddrs = [xAddress componentsSeparatedByString:@" "];
            
            // check if any xAddrs in list
            if (xAddrs && [xAddrs count] != 0)
            {
                selectxAddrs = [xAddrs objectAtIndex:0];
                //sohan for call connect method
                [self btnConnectTouched];
            }
        }
    }
    else if ([status isEqualToString:kSendProbeRequest]) {
        //
    }
}

@end
