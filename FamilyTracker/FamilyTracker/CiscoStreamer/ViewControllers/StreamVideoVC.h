//
//  StreamVideoVC.h
//  VideoStreamer
//
//  Created by AHMLPT0406 on 10/02/15.
//  Copyright (c) 2015 AHMLPT0406. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamerConfiguration.h"
#import "LiveStreamController.h"
#import "Operator.h"
#import "MBProgressHUD.h"

@interface StreamVideoVC : UIViewController<MBProgressHUDDelegate,UIAlertViewDelegate, LiveStreamControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *rtspServerUrlLabel;
@property (strong, nonatomic) IBOutlet UILabel *streamingStatusLabel;

//Start Stop Recording
@property (strong, nonatomic) IBOutlet UIView *startStopRecordingView;
@property (strong, nonatomic) IBOutlet UIButton *startStopRecordingButton;
@property (strong, nonatomic) IBOutlet UIButton *startStopStreamingButton;
@property (strong, nonatomic) IBOutlet UILabel *remainingSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@property (strong, nonatomic) NSArray *selectedContactArray;
@property (strong, nonatomic) NSString *connectionState;
@property (readwrite, nonatomic) NSString *alertType;

@end
