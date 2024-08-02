//
//  CameraPTZSettingView.h
//  CiscoUtility
//
//  Created by einfochips on 23/01/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CameraRequestInterface.h"
//#import "CameraCalls.h"

#import "MBProgressHUD.h"

#define View @"view"

@interface CameraPTZSettingView : UIView
{
    NSMutableArray *cameraRequestArray;
    
    IBOutlet UIButton *btnTop;
    IBOutlet UIButton *btnBottom;
    IBOutlet UIButton *btnLeft;
    IBOutlet UIButton *btnRight;
    IBOutlet UIButton *btnHome;
    IBOutlet UIButton *btnTopLeft;
    IBOutlet UIButton *btnTopRight;
    IBOutlet UIButton *btnBottomLeft;
    IBOutlet UIButton *btnBottomRight;
    
    IBOutlet UIButton *btnZoomIn;
    IBOutlet UIButton *btnZoomOut;
	
//    CameraCalls *cameraCalls;
    
    NSString *xAddr;
    NSString *username;
    NSString *password;
    NSString *mediaProfileToken;
    
    float panSpeed;
    float tiltSpeed;
    float zoomSpeed;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet MBProgressHUD *mbProgressHUD;

- (void)startPtzWithXaddrs:(NSString *)pXAddrs
                  username:(NSString *)pUsername
                  password:(NSString *)pPassword
         mediaProfileToken:(NSString *)mediaProfileToken;

- (IBAction)btnHomeTouched:(id)sender;

- (IBAction)btnTopTouchDown:(id)sender;
- (IBAction)btnBottomTouchDown:(id)sender;
- (IBAction)btnLeftTouchDown:(id)sender;
- (IBAction)btnRightTouchDown:(id)sender;
- (IBAction)btnTopLeftTouchDown:(id)sender;
- (IBAction)btnTopRightTouchDown:(id)sender;
- (IBAction)btnBottomRightTouchDown:(id)sender;
- (IBAction)btnBottomLeftTouchDown:(id)sender;

- (IBAction)btnZoomInTouchDown:(id)sender;
- (IBAction)btnZoomOutTouchDown:(id)sender;

@end
