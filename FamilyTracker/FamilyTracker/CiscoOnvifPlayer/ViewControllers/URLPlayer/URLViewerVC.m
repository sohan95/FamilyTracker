//
//  URLViewerVC.m
//  CameraStreamming
//
//  Created by einfochips on 12/09/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import "URLViewerVC.h"
#import "StreamingVC.h"

@interface URLViewerVC ()

@end

@implementation URLViewerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBarHidden = YES;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    rtspUrlTextField.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    // Setting RTSP URL for streamming
	rtspUrlTextField.text= @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma -mark UITextView Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma  -mark IBAction Methdos

// Push to streamming View
-(IBAction)loginButtonClicked:(id)sender
{
	// Open StreamingVC for player to play RTSP URL
//	StreamingVC *streamingVC = [[StreamingVC alloc]initWithNibName:@"StreamingVC" bundle:nil];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
    
	streamingVC.url = [NSURL URLWithString:rtspUrlTextField.text];
	streamingVC.isONVIFPlayer = NO;
	streamingVC.xAddr = @"";
	streamingVC.username = @"";
	streamingVC.password = @"";
	streamingVC.ptzProfileToken = @"";
	streamingVC.isCameraPTZCapable = NO;
	
	[self.navigationController pushViewController:streamingVC animated:YES];
}

- (IBAction)btnBackNavigation:(id)sender {
	
	// Back to Home screen
	[self.navigationController popViewControllerAnimated:YES];
}

@end
