//
//  WowzaSettingVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "WowzaSettingVC.h"
#import "Constant.h"

//#import "AppDelegate.h"
//#import "SettingsData+Additional.h"

#import "StreamerConfiguration.h"
//#import "StreamerConfigurationBase+WowzaSettingsConfiguration.h"

@interface WowzaSettingVC ()
{
    IBOutlet UITextField *serverTextField;
    IBOutlet UITextField *portTextField;
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *applicationTextField;
    IBOutlet UITextField *streamTextField;
    
//    AppDelegate *appDelegate;
//    SettingsData *settingData;
    StreamerConfiguration *streamerConfig;
}
@end

@implementation WowzaSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
//    appDelegate = [UIApplication sharedApplication].delegate;
//    settingData = [SettingsData fetchSettingDataFromContext:[appDelegate managedObjectContext]];
    
    serverTextField.delegate = self;
    portTextField.delegate = self;
    usernameTextField.delegate = self;
    passwordTextField.delegate = self;
    applicationTextField.delegate = self;
    streamTextField.delegate = self;
    
//    serverTextField.text = @"10.100.23.70";
//    portTextField.text = @"1935";
//    usernameTextField.text = @"punita";
//    passwordTextField.text = @"test123";
//    applicationTextField.text = @"live";
//    streamTextField.text = @"myStream";
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    NSString *wowzaServerIP = [streamerConfig getWowzaServerIP];
    if (wowzaServerIP != nil) {
        [serverTextField setText:wowzaServerIP];
    }
    
    NSString *wowzaServerPort = [streamerConfig getWowzaServerPort];
    if (wowzaServerPort != nil) {
        [portTextField setText:wowzaServerPort];
    }
    
    NSString *wowzaUsername = [streamerConfig getWowzaUsername];
    if (wowzaUsername != nil) {
        [usernameTextField setText:wowzaUsername];
    }
    
    NSString *wowzaPassword = [streamerConfig getWowzaPassword];
    if (wowzaPassword != nil) {
        [passwordTextField setText:wowzaPassword];
    }
    
    NSString *wowzaApplication = [streamerConfig getWowzaApplication];
    if (wowzaApplication != nil) {
        [applicationTextField setText:wowzaApplication];
    }
    
    NSString *wowzaStream = [streamerConfig getWowzaStreamName];
    if (wowzaStream != nil) {
        [streamTextField setText:wowzaStream];
    }
    
//    NSString *applicationStreamName = [StreamConfig shareManager].applicationStreamName;
//    
//    if (applicationStreamName != nil) {
//        
//        NSRange newRange = [applicationStreamName rangeOfString:@"/"];
//        NSString *appName = [applicationStreamName substringWithRange:NSMakeRange(0, newRange.location-1)];
//        NSString *streamName = [applicationStreamName substringWithRange:NSMakeRange(newRange.location, applicationStreamName.length - newRange.location - 1)];
//        
//        [applicationTextField setText:appName];
//        [streamTextField setText:streamName];
//    }
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

#pragma mark - UITextFieldField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (serverTextField == textField) {
        [portTextField becomeFirstResponder];
    }
    else if (portTextField == textField) {
        [usernameTextField becomeFirstResponder];
    }
    else if (usernameTextField == textField) {
        [passwordTextField becomeFirstResponder];
    }
    else if (passwordTextField == textField) {
        [applicationTextField becomeFirstResponder];
    }
    else if (applicationTextField == textField) {
        [streamTextField becomeFirstResponder];
    }
    else if (streamTextField == textField) {
        [streamTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)validateForm {
    
    NSString *errorMessage = @"";
    if (serverTextField.text.length <=0) {
        errorMessage = @"Please enter server IP.";
    }
    else if (portTextField.text.length <= 0) {
        errorMessage = @"Please enter port";
    }
    else if (usernameTextField.text.length <= 0) {
        errorMessage = @"Please enter user name.";
    }
    else if (passwordTextField.text.length <= 0) {
        errorMessage = @"Please enter password.";
    }
    else if (applicationTextField.text.length <= 0) {
        errorMessage = @"Please enter application name.";
    }
    else if (streamTextField.text.length <= 0) {
        errorMessage = @"Please enter stream name.";
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

- (IBAction)tappedSave:(id)sender {
    
    if (![self validateForm]) {
        return;
    }
    
    if (![serverTextField.text isEqualToString:[streamerConfig getWowzaServerIP]] ||
        ![portTextField.text isEqualToString:[streamerConfig getWowzaServerPort]] ||
        ![usernameTextField.text isEqualToString:[streamerConfig getWowzaUsername]] ||
        ![passwordTextField.text isEqualToString:[streamerConfig getWowzaPassword]] ||
        ![applicationTextField.text isEqualToString:[streamerConfig getWowzaApplication]] ||
        ![streamTextField.text isEqualToString:[streamerConfig getWowzaStreamName]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kChangedWowzaSettings];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kChangedWowzaSettings];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [streamerConfig setWowzaServerIP:serverTextField.text];
    [streamerConfig setWowzaServerPort:portTextField.text];
    
    [streamerConfig setWowzaUsername:usernameTextField.text];
    [streamerConfig setWowzaPassword:passwordTextField.text];
    
    [streamerConfig setWowzaApplication:applicationTextField.text];
    [streamerConfig setWowzaStreamName:streamTextField.text];

//    NSDictionary *wowzaServerData = @{@"serverIP": serverTextField.text, @"serverPort":portTextField.text, @"username":usernameTextField.text, @"password": passwordTextField.text, @"application":applicationTextField.text, @"stream":streamTextField.text};
//    
//    [SettingsData updateWowzaDetail:wowzaServerData inContext:[appDelegate managedObjectContext]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
