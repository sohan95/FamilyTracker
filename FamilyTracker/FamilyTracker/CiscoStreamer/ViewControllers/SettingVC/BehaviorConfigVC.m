//
//  BehaviorConfigVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "BehaviorConfigVC.h"
#import "SettingsTableViewController.h"
#import "WowzaSettingVC.h"
#import "OnvifServerCedentialVC.h"

#import "ProfileListVC.h"
#import "Constant.h"

#import "StreamerConfiguration.h"

@interface BehaviorConfigVC ()
{
    IBOutlet UIView *serverView;
    IBOutlet UIView *clientView;
    
    NSArray *viewOldConstraints;
    NSArray *clientViewConstraints;
    NSArray *serverViewConstraints;
    
    StreamerConfiguration *stremerConfig;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *behaviorTypeSegmentView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *streamingTypeSegmentView;
@property (nonatomic, retain) IBOutlet UIView *serverView;
@property (nonatomic, retain) IBOutlet UIView *clientView;

@property (nonatomic, retain) IBOutlet UIButton *videoStreamingType;

@end

@implementation BehaviorConfigVC

@synthesize serverView, clientView, behaviorTypeSegmentView, videoStreamingType, streamingTypeSegmentView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    stremerConfig = [StreamerConfiguration sharedInstance];
    
    NSString *behaviorType = [stremerConfig getStreamBehaviorType];
    
    viewOldConstraints = [self.view constraints];
    clientViewConstraints = [clientView constraints];
    serverViewConstraints = [serverView constraints];
    
    if (behaviorType == nil) {
        //Still not set any setting

//        [SettingsData updateSettingString:kStreamBehaviorTypeClient forSettingKey:kBehaviorType inContext:[appDelegate managedObjectContext]];
        behaviorType = kStreamBehaviorTypeClient;
    }
    
    if ([behaviorType isEqualToString:kStreamBehaviorTypeClient]) {
        //Client Selected
        
        [behaviorTypeSegmentView setSelectedSegmentIndex:0];
//        [serverView setHidden:YES];
//        [self.view addConstraints:[clientView constraints]];
        [serverView removeFromSuperview];
    }
    else {
        // server selected
        [behaviorTypeSegmentView setSelectedSegmentIndex:1];
//        [clientView setHidden:YES];
        [clientView removeFromSuperview];
    }
    
    NSNumber *onvifEnabled = [stremerConfig isONVIFEnabled];
    if (onvifEnabled == nil) {
//        [SettingsData updateSettingValue:[NSNumber numberWithBool:NO] forSettingKey:kEnableOnvif  inContext:[appDelegate managedObjectContext]];
        onvifEnabled = [NSNumber numberWithBool:NO];
        [stremerConfig enableOnvif:onvifEnabled];
        [self.streamingTypeSegmentView setSelectedSegmentIndex:1];
    }
    
    if ([onvifEnabled boolValue]) {
        [self.streamingTypeSegmentView setSelectedSegmentIndex:0];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSString *streamType = [[StreamConfig shareManager].streamingTypesArray objectAtIndex:[[settingData valueForKey:kVideoStreamType] intValue]];

    NSString *appBehaviour = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_behavior"];
    if (appBehaviour != nil && [appBehaviour isEqualToString:@"start_streaming"]) {
        [behaviorTypeSegmentView setEnabled:NO];
    }
    
    NSString *streamType = [stremerConfig getStreamType];
    
    if (streamType == nil || streamType.length <= 0) {
        
        [stremerConfig setDefaultSelectedStreamType];
        
        streamType = [stremerConfig getStreamType];
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:1] forSettingKey:kVideoStreamType inContext:[appDelegate managedObjectContext]];
    }
    
    [videoStreamingType setEnabled:YES];
    [videoStreamingType setTitle:streamType forState:UIControlStateNormal];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Actions

- (IBAction)changeEnableOnvif:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    BOOL isONVIFEnable = YES;
    if (selectedSegment == 0) {
        // Enable Onvif
        isONVIFEnable = YES;
//        [SettingsData updateSettingValue:[NSNumber numberWithBool:YES] forSettingKey:kEnableOnvif  inContext:[appDelegate managedObjectContext]];
    }
    else{
        //Disabled Onvif
        isONVIFEnable = NO;
//        [SettingsData updateSettingValue:[NSNumber numberWithBool:NO] forSettingKey:kEnableOnvif  inContext:[appDelegate managedObjectContext]];
    }
    
    [stremerConfig enableOnvif:[NSNumber numberWithBool:isONVIFEnable]];
}

- (IBAction)changeBehavioredType:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    NSString *behaviorType = @"";
    
    if (selectedSegment == 0) {
        //Client Enabled
//        [self updateUserDefaults:kStreamBehaviorTypeClient forKey:kBehaviorType];

//        [serverView setHidden:YES];
//        [clientView setHidden:NO];

        [self.view removeConstraints:viewOldConstraints];
        
        [self.view addSubview:clientView];
        [self.view addConstraints:viewOldConstraints];
        [serverView removeFromSuperview];
        [self.view addConstraints:clientViewConstraints];
        
        behaviorType = @"Client";
        
    }
    else{
        // Server Emabled
//        [self updateUserDefaults:kStreamBehaviorTypeServer forKey:kBehaviorType];
        
//        [serverView setHidden:NO];
//        [clientView setHidden:YES];
        
        [self.view removeConstraints:viewOldConstraints];
        
        [self.view addSubview:serverView];
        [self.view addConstraints:viewOldConstraints];
        [clientView removeFromSuperview];
        [self.view addConstraints:serverViewConstraints];
        
        behaviorType = @"Server";
    }
    
    [stremerConfig setStreamBehaviorType:behaviorType];
//    [SettingsData updateSettingString:behaviorType forSettingKey:kBehaviorType inContext:[appDelegate managedObjectContext]];
}

- (IBAction)tapperStreamType:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    settingsVC.screenTag = kStreamTypeSettingsScreenTag;
    [self.navigationController pushViewController:settingsVC animated:NO];
}

- (IBAction)tappedProfileList:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
    ProfileListVC *profileListVC = [sb instantiateViewControllerWithIdentifier:@"ProfileListVC"];
//    profileListVC.managedObjectContext = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    [self.navigationController pushViewController:profileListVC animated:NO];
}

- (IBAction)tappedWowzaSettings:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
    WowzaSettingVC *wowzaSettingsVC = [sb instantiateViewControllerWithIdentifier:@"WowzaSettingVC"];
    [self.navigationController pushViewController:wowzaSettingsVC animated:NO];
}

- (IBAction)tappedOnvifServerCredential:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
    OnvifServerCedentialVC *onvifServerVC = [sb instantiateViewControllerWithIdentifier:@"OnvifServerCedentialVC"];
    [self.navigationController pushViewController:onvifServerVC animated:NO];
}

//#pragma mark - User Defined Methods
//- (void)updateUserDefaults:(id)settingValue forKey:(NSString *)settingKey {
//    NSMutableDictionary *settingDetail = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kSettingData]];
//    
//    [settingDetail setObject:settingValue forKey:settingKey];
//    [[NSUserDefaults standardUserDefaults] setObject:settingDetail forKey:kSettingData];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

@end
