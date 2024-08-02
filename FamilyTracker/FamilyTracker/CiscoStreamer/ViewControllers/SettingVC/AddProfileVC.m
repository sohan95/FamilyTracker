//
//  AddProfileVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "AddProfileVC.h"
#import "Constant.h"

#import "StreamerConfiguration.h"

#import "SettingsTableViewController.h"

#define kResolutionTag  100
#define kFrameRateTag   101
#define kBitRateTag     102

@interface AddProfileVC ()
{
    IBOutlet UITextField *txtProfileName;
    IBOutlet UIButton *btnResolution;
    IBOutlet UIButton *btnFrameRate;
    IBOutlet UIButton *btnBitRate;
    
//    AppDelegate *appDelegate;
}
@end

@implementation AddProfileVC

@synthesize savedProfileDetail, profileDics;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    self.profileDics = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (self.savedProfileDetail != nil) {
        [txtProfileName setText:[savedProfileDetail valueForKey:@"name"]];
        
        [btnResolution setTitle:[NSString stringWithFormat:@"%@x%@",[savedProfileDetail valueForKey:@"width"], [savedProfileDetail valueForKey:@"height"]] forState:UIControlStateNormal];
        [btnFrameRate setTitle:[savedProfileDetail valueForKey:@"framerate"] forState:UIControlStateNormal];
        [btnBitRate setTitle:[savedProfileDetail valueForKey:@"bitrate"] forState:UIControlStateNormal];
        
        [self.profileDics setValue:[savedProfileDetail valueForKey:@"profile_id"] forKey:@"profile_id"];
        [self.profileDics setValue:[savedProfileDetail valueForKey:@"width"] forKey:@"width"];
        [self.profileDics setValue:[savedProfileDetail valueForKey:@"height"] forKey:@"height"];
        [self.profileDics setValue:[savedProfileDetail valueForKey:@"framerate"] forKey:@"framerate"];
        [self.profileDics setValue:[savedProfileDetail valueForKey:@"bitrate"] forKey:@"bitrate"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self.profileDics allKeys] containsObject:@"width"] && [[self.profileDics allKeys] containsObject:@"height"]) {
        [btnResolution setTitle:[NSString stringWithFormat:@"%@x%@",[self.profileDics valueForKey:@"width"], [self.profileDics valueForKey:@"height"]] forState:UIControlStateNormal];
    }
    
    if ([[self.profileDics allKeys] containsObject:@"framerate"]) {
        [btnFrameRate setTitle:[self.profileDics valueForKey:@"framerate"] forState:UIControlStateNormal];
    }
    
    if ([[self.profileDics allKeys] containsObject:@"bitrate"]) {
        [btnBitRate setTitle:[self.profileDics valueForKey:@"bitrate"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)validateFormData {
    NSString *errorMessage = @"";
    
    if (txtProfileName.text.length <= 0) {
        errorMessage = @"Please enter profile name.";
    }
    else if(![[self.profileDics allKeys] containsObject:@"width"] || ![[self.profileDics allKeys] containsObject:@"height"]) {
        errorMessage = @"Please select resolution.";
    }
    else if (![[self.profileDics allKeys] containsObject:@"framerate"]) {
        errorMessage = @"Please select framerate.";
    }
    else if (![[self.profileDics allKeys] containsObject:@"bitrate"]) {
        errorMessage = @"Please select bitrate.";
    }
    
    if (errorMessage.length > 0) {
        // display errormessage
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:errorMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* btnOk = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    NSLog(@"Ok button pressed");
                                    
                                }];
        [alert addAction:btnOk];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - Button Action

- (IBAction)tappedSave:(id)sender
{
    if (![self validateFormData]) {
        return;
    }
    
    [self.profileDics setValue:txtProfileName.text forKey:@"profile_name"];
    
    StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
    [streamerConfig addONVIFMediaProfileDetails:self.profileDics];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tappedSelectionButton:(id)sender {
    
    NSInteger tag = [sender tag];
    
    switch (tag) {
        case kResolutionTag:
        {
            // load Setting screen with Resolution Data
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
            settingsVC.screenTag = kProfileResolutionSettingsScreenTag;
            settingsVC.parentVC = self;
            settingsVC.profileDetail = self.profileDics;
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
            break;
        case kFrameRateTag:
        {
            // load Setting screen with FrameRate Data
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
            settingsVC.screenTag = kProfileFrameRateSettingsScreenTag;
            settingsVC.parentVC = self;
            settingsVC.profileDetail = self.profileDics;
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
            break;
        case kBitRateTag:
        {
            // load Setting screen with BitRate Data
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
            settingsVC.screenTag = kProfileBitRateSettingsScreenTag;
            settingsVC.parentVC = self;
            settingsVC.profileDetail = self.profileDics;
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
