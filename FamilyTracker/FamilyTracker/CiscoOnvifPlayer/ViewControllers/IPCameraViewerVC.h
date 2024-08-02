//
//  IPCameraViewerVC.h
//  CiscoOnvifPlayer
//
//  Created by einfochips on 9/24/14.
//  Copyright (c) 2014 eInfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamingVC.h"
#import "MBProgressHUD.h"

#import "IPCameraController.h"
#import "MultiPaneViewController.h"
#import "Camera.h"//sohan

@interface IPCameraViewerVC : UIViewController<MBProgressHUDDelegate, IPCameraControllerDelegate>
{
    NSString *selectxAddrs;
	NSString *ptzProfileToken;
	NSArray *xAddrs;
	
	NSMutableArray *arrProfileList;
	NSMutableArray *arrProfileListPTZ;
	NSString *selectedAddress;
	
	BOOL isFirstTimeLoadScreen;
}

@property(nonatomic) MBProgressHUD *mbProgressHUD;
@property (nonatomic, assign) BOOL isFirstTimeLoadScreen;
@property (nonatomic, assign) BOOL isDispalyInMultiPane;
@property (nonatomic, weak) MultiPaneViewController *multiViewPaneVC;

@property (nonatomic, weak) Camera *ipCamera;//---sohan---//

- (StreamingVC *)getStreamerVCObject;
- (void)setIPControllerObject:(IPCameraController *)localIPCameraObject;

@end
