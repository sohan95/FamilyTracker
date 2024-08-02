//
//  SmsVerifycationViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/15/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmsVerifycationViewController : UIViewController

@property (nonatomic,strong) NSString * activationType;
- (IBAction)resendActivationAction:(id)sender;
@property (nonatomic,strong) NSString * user_name;
@property (nonatomic,strong) NSString * password;

@end
