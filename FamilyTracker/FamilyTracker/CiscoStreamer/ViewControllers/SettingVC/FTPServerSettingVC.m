//
//  FTPServerSettingVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "FTPServerSettingVC.h"
#import "Constant.h"

#import "StreamerConfiguration.h"

@interface FTPServerSettingVC ()
{
//    AppDelegate *appDelegate;
//    SettingsData *settingData;
    
    StreamerConfiguration *streamerConfig;
}

@property (nonatomic, retain) IBOutlet UITextField *hostTextFeild;
@property (nonatomic, retain) IBOutlet UITextField *serverPathTextFeild;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextFeild;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextFeild;

@end

@implementation FTPServerSettingVC

@synthesize hostTextFeild, serverPathTextFeild, usernameTextFeild, passwordTextFeild;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
//    appDelegate = [UIApplication sharedApplication].delegate;
//    settingData = [SettingsData fetchSettingDataFromContext:[appDelegate managedObjectContext]];
    
    hostTextFeild.delegate = self;
    serverPathTextFeild.delegate = self;
    usernameTextFeild.delegate = self;
    passwordTextFeild.delegate = self;
    
    NSString *ftpHost = [streamerConfig getFTPHost];
    if (ftpHost != nil) {
        [hostTextFeild setText:ftpHost];
    }
    
    NSString *ftpServerPath = [streamerConfig getFTPServerPath];
    if (ftpServerPath != nil) {
        [serverPathTextFeild setText:ftpServerPath];
    }
    
    NSString *ftpUsername = [streamerConfig getFTPUsername];
    if (ftpUsername != nil) {
        [usernameTextFeild setText:ftpUsername];
    }
    
    NSString *ftpPassword = [streamerConfig getFTPPassword];
    if (ftpPassword != nil) {
        [passwordTextFeild setText:ftpPassword];
    }
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

- (BOOL)validateForm {
    
    NSString *errorMessage = @"";
    if (hostTextFeild.text.length <= 0) {
        errorMessage = @"Please enter valid host.";
    }
//    else if (serverPathTextFeild.text.length <= 0) {
//        errorMessage = @"Please enter server path.";
//    }
    else if (usernameTextFeild.text.length <= 0) {
        errorMessage = @"Please enter username.";
    }
    else if (passwordTextFeild.text.length <= 0) {
        errorMessage = @"Please enter password.";
    }
    
    if (errorMessage.length > 0) {
        // display errormessage
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:errorMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* btnOk = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                { }];
        [alert addAction:btnOk];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (hostTextFeild == textField) {
        [serverPathTextFeild becomeFirstResponder];
    }
    else if (serverPathTextFeild == textField) {
        [usernameTextFeild becomeFirstResponder];
    }
    else if (usernameTextFeild == textField) {
        [passwordTextFeild becomeFirstResponder];
    }
    else if (passwordTextFeild == textField) {
        [passwordTextFeild resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Button Actions
- (IBAction)tappedSave:(id)sender {
    
    if (![self validateForm]) {
        return;
    }
    
    [streamerConfig setFTPServerHost:hostTextFeild.text];
    [streamerConfig setFTPServerPath:serverPathTextFeild.text];
    [streamerConfig setFTPUsername:usernameTextFeild.text];
    [streamerConfig setFTPPassword:passwordTextFeild.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
