//
//  CameraPTZSettingView.m
//  CiscoUtility
//
//  Created by einfochips on 23/01/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import "CameraPTZSettingView.h"
#import "IPCameraController.h"
#import "Constant.h"

#define X @"_x"
#define Y @"_y"

@interface CameraPTZSettingView() <IPCameraControllerDelegate>
{
    IPCameraController *ipCameraController;
}

@property (nonatomic, retain) IPCameraController *ipCameraController;
@end

@implementation CameraPTZSettingView

@synthesize ipCameraController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.ipCameraController = [[IPCameraController alloc] init];
        self.ipCameraController.delegate = self;
        
        // load PTZ view on host viewcontroller
        UIView *controlView = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            controlView = [[[NSBundle mainBundle] loadNibNamed:@"CameraPTZSettingView_ipad" owner:self options:nil] objectAtIndex:0];
        }
        else {
            controlView = [[[NSBundle mainBundle] loadNibNamed:@"CameraPTZSettingView_iphone" owner:self options:nil] objectAtIndex:0];
        }
		 
        [self addSubview:controlView];
		[self bringSubviewToFront:controlView];
		
		cameraRequestArray = [[NSMutableArray alloc] init];
		
		self.mbProgressHUD = [[MBProgressHUD alloc] initWithView:self];
		[self addSubview:self.mbProgressHUD];
		
		[self addButtonTargets];
    }
    return self;
}

#pragma -mark Actions for PTZ controls


- (IBAction)btnHomeTouched:(id)sender
{
	[self gotoHomePosition];
}

- (IBAction)btnPTZTouched:(id)sender
{
	[self setPTZSettings:0 tiltSpeed:0 zoomSpeed:0];
}

//Touch Down

- (IBAction)btnTopTouchDown:(id)sender
{
	[self setPTZSettings:0 tiltSpeed:tiltSpeed zoomSpeed:0];
}

- (IBAction)btnBottomTouchDown:(id)sender
{
	[self setPTZSettings:0 tiltSpeed:-tiltSpeed zoomSpeed:0];
}

- (IBAction)btnLeftTouchDown:(id)sender
{
	[self setPTZSettings:-panSpeed tiltSpeed:0 zoomSpeed:0];
}

- (IBAction)btnRightTouchDown:(id)sender
{
	[self setPTZSettings:panSpeed tiltSpeed:0 zoomSpeed:0];
}

- (IBAction)btnTopLeftTouchDown:(id)sender
{
	[self setPTZSettings:-panSpeed tiltSpeed:tiltSpeed zoomSpeed:0];
}

- (IBAction)btnTopRightTouchDown:(id)sender
{
	[self setPTZSettings:panSpeed tiltSpeed:tiltSpeed zoomSpeed:0];
}

- (IBAction)btnBottomRightTouchDown:(id)sender
{
	[self setPTZSettings:panSpeed tiltSpeed:-tiltSpeed zoomSpeed:0];
}

- (IBAction)btnBottomLeftTouchDown:(id)sender
{
	[self setPTZSettings:-panSpeed tiltSpeed:-tiltSpeed zoomSpeed:0];
}

- (IBAction)btnZoomInTouchDown:(id)sender
{
    [self setPTZSettings:0 tiltSpeed:0 zoomSpeed:zoomSpeed];
}

- (IBAction)btnZoomOutTouchDown:(id)sender
{
    [self setPTZSettings:0 tiltSpeed:0 zoomSpeed:-zoomSpeed];
}

#pragma -mark Public Methods

- (void)startPtzWithXaddrs:(NSString *)pXAddrs
                  username:(NSString *)pUsername
                  password:(NSString *)pPassword
         mediaProfileToken:(NSString *)pMediaProfileToken
{
    xAddr = pXAddrs;
    username = pUsername;
    password = pPassword;
    mediaProfileToken = pMediaProfileToken;
    
    if (self.ipCameraController == nil) {
        self.ipCameraController = [[IPCameraController alloc] init];
        self.ipCameraController.delegate = self;
    }
    
    [self getPTZConfigurations];
}

#pragma -mark Camera Calls

//Get PTZ Configuration
- (void)getPTZConfigurations
{
    
    
    
    [self.ipCameraController setIPAddress:xAddr withUsername:username withPassword:password withMediaProfile:mediaProfileToken];
    
    [self.ipCameraController getPTZConfiguration];
}

//Continuos move
- (void)setPTZSettings:(int)pPanSpeed
			 tiltSpeed:(int)pTiltSpeed
             zoomSpeed:(int)pZoomSpeed
{
	[self.mbProgressHUD show:YES];
    
    if (self.ipCameraController == nil) {
        self.ipCameraController = [[IPCameraController alloc] init];
        self.ipCameraController.delegate = self;
    }
    [self.ipCameraController setPTZSetting:pPanSpeed tiltSpeed:pTiltSpeed zoomSpeed:pZoomSpeed];
}

//Go to Home Position
- (void)gotoHomePosition
{
	[self.mbProgressHUD show:YES];
    
    if (self.ipCameraController == nil) {
        self.ipCameraController = [[IPCameraController alloc] init];
        self.ipCameraController.delegate = self;
    }
    [self.ipCameraController gotoHomePosition];
}

#pragma -mark Internal Methods

//Show alert message for given title and message
- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {}];
    [alertController addAction:okAction];
    [(UIViewController *)[self superclass] presentViewController:alertController animated:YES completion:nil];
}

//Set PTZ controls Enable/Disable
- (void)setPTZControlEnable:(BOOL)isEnable
{
	btnTopLeft.enabled = isEnable;
	btnTop.enabled = isEnable;
	btnTopRight.enabled = isEnable;
	btnLeft.enabled = isEnable;
	btnHome.enabled = isEnable;
	btnRight.enabled = isEnable;
	btnBottomLeft.enabled = isEnable;
	btnBottom.enabled = isEnable;
	btnBottomRight.enabled = isEnable;
}

//Button Events to stop continuous move
- (void)addButtonTargets
{
    //UIControlEventTouchDragOutside
	[btnTopLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnTop addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnTopRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnBottomLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnBottom addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
	[btnBottomRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchDragOutside];
    
    //UIControlEventTouchUpInside
	[btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
	[btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnTopLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnTop addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnTopRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnBottomLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnBottom addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnBottomRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    //UIControlEventTouchUpOutside
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    
    [btnTopLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnTop addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnTopRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnBottomLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnBottom addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnBottomRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchUpOutside];
    
    //UIControlEventTouchCancel
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    
    [btnTopLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnTop addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnTopRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnBottomLeft addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnBottom addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnBottomRight addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    
    [btnZoomIn addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
    [btnZoomOut addTarget:self action:@selector(btnPTZTouched:) forControlEvents:UIControlEventTouchCancel];
}

#pragma mark - IPCameraControllerDelegate 

- (void)notifyOnError:(NSString *)status error:(NSString *)message; {
    [self.mbProgressHUD hide:YES];
    
    [self showAlertMessage:@"Error" message:message];
}

- (void)notifyStatusUpdate:(NSString *)status withResponse:(NSDictionary *)responseDic {
    
    [self.mbProgressHUD hide:YES];
    
    if ([status isEqualToString:kPTZConfigurationAPIResponse]) {
        NSDictionary *ptzConfigurationDic =   [[[responseDic valueForKey:KEY_BODY] valueForKey:GET_CONFIGURATION_RESPONSE] valueForKey:PTZ_CONFIGURATION];
        
        panSpeed = [[[[ptzConfigurationDic valueForKey:DEFAULT_PTZ_SPEED] valueForKey:PAN_TILT] valueForKey:X] floatValue];
        tiltSpeed = [[[[ptzConfigurationDic valueForKey:DEFAULT_PTZ_SPEED] valueForKey:PAN_TILT] valueForKey:Y] floatValue];
        zoomSpeed = [[[[ptzConfigurationDic valueForKey:DEFAULT_PTZ_SPEED] valueForKey:ZOOM] valueForKey:X] floatValue];
    }
    else if ([status isEqualToString:kPTZSettingsAPIResponse]) {
        //
    }
    else if ([status isEqualToString:kHomePositionAPIResponse]) {
        //
    }
}

@end
