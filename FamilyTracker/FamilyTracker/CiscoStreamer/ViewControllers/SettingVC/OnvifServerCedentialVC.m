//
//  OnvifServerCedentialVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "OnvifServerCedentialVC.h"
#import "Constant.h"
#import "StreamerConfiguration.h"



@interface OnvifServerCedentialVC ()
{
    IBOutlet UITextField *oldPasswordTextField;
    IBOutlet UITextField *newPasswordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    
    StreamerConfiguration *streamerConfig;
}
@end

@implementation OnvifServerCedentialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    oldPasswordTextField.delegate = self;
    newPasswordTextField.delegate = self;
    confirmPasswordTextField.delegate = self;
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
    
    if (oldPasswordTextField == textField) {
        [newPasswordTextField becomeFirstResponder];
    }
    else if (newPasswordTextField == textField) {
        [confirmPasswordTextField becomeFirstResponder];
    }
    else if (confirmPasswordTextField == textField) {
        [confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)validateForm {
    
    NSString *oldPassword = [streamerConfig getONVIFServerPassword];
    
    NSString *errorMessage = @"";
    
    if (oldPassword == nil && ![oldPasswordTextField.text isEqualToString:kStandardONVIFPassword]) {
        errorMessage = @"Old password does not match.";
    }
    else if (oldPassword != nil && ![oldPassword isEqualToString:oldPasswordTextField.text]) {
        errorMessage = @"Old password should match.";
    }
    else if (![newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        errorMessage = @"Confirm passowrd does not match.";
    }
    else if ([newPasswordTextField.text isEqualToString:oldPasswordTextField.text]) {
        errorMessage = @"Old password and new passwords cannot be same.";
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
    
    [streamerConfig setNewONVIFServerPassword:newPasswordTextField.text];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Password successfully reset."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* btnOk = [UIAlertAction actionWithTitle:@"OK"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                NSLog(@"Ok button pressed");
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    [alert addAction:btnOk];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end
