//
//  HomeVC.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 2/10/15.
//  Copyright (c) 2015 eInfochips. All rights reserved.
//

#import "HomeVC.h"
#import "IPCameraViewerVC.h"
#import "URLViewerVC.h"

@interface HomeVC ()
{
	IPCameraViewerVC *ipCameraViewerObj;
}
@end

@implementation HomeVC

- (void)viewDidLoad {
	
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
	ipCameraViewerObj = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	ipCameraViewerObj = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

#pragma -mark User Actions

- (IBAction)btnChooseViewerTouched:(id)sender {
	
	// User Button Tag, We will identify user want which feature, and accordingly screen will open
    UIButton *btn = (UIButton *)sender;
	NSInteger buttonTag = [btn tag];
	
	if (buttonTag == 100) {
		// Open URL Viewer screen
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
        URLViewerVC *urlViewerVC = [sb instantiateViewControllerWithIdentifier:@"URLViewerVC"];
        [self.navigationController pushViewController:urlViewerVC animated:YES];
	}
	else
	{
		// Open IP Camera Viewer screen
		if (ipCameraViewerObj == nil) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
            ipCameraViewerObj = [sb instantiateViewControllerWithIdentifier:@"IPCameraViewerVC"];
            ipCameraViewerObj.isFirstTimeLoadScreen = YES;
		}
		[self.navigationController pushViewController:ipCameraViewerObj animated:YES];
	}
}


@end
