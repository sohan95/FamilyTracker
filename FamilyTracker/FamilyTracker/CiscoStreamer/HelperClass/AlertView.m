//
//  AlertView.m
//  Physician
//
//  Created by einfochips on 04/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView

+(void)customAlertView:(NSString *)title message:(NSString *)message button:(int)button delegate:(UIViewController *)delegate
{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        if (button > 1)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            [alert show];
        }
        else
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        if (button > 1)
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            
            [delegate presentViewController:alert animated:YES completion:nil];
            
        }
        else
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOk = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
            
            
            [alert addAction:btnOk];
            
            
            [delegate presentViewController:alert animated:YES completion:nil];
            
        }
    }
}

#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
