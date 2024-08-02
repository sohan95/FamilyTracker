//
//  SmsVerifycationViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/15/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "SmsVerifycationViewController.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "HexToRGB.h"
#import "LoginViewController.h"

@interface SmsVerifycationViewController () <Updater> {
    MBProgressHUD *smsVfHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    NSTimer *resendMailTimeCounter;
    BOOL isWaitForResendMail;
}
@property (weak, nonatomic) IBOutlet UILabel *topTitleLbl;
@property (weak, nonatomic) IBOutlet UITextField *activationCodeField;
- (IBAction)backLoginVcAction:(id)sender;
- (IBAction)submitCodeAction:(id)sender;
@property (nonatomic,strong) NSTimer *resendMailTimer;
@property (nonatomic, assign) int timeCounter;
@end

@implementation SmsVerifycationViewController
double locationTimerInterval_Sms = 15.0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem * leftBarBtn1 = [[UIBarButtonItem alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(SIGN_UP_PAGE_TITLE_KEY,nil);
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel sizeToFit];
    leftBarBtn1.customView = titleLabel;
    UIBarButtonItem * leftBarBtn2 = [[UIBarButtonItem alloc] init];
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Forword-Arrow"]];
    [image sizeToFit];
    leftBarBtn2.customView = image;
    UIBarButtonItem * leftBarBtn3 = [[UIBarButtonItem alloc] init];
    UILabel *titleLabel3 = [[UILabel alloc] init];
    titleLabel3.text = NSLocalizedString(@"Activation",nil);
    [titleLabel3 setTextColor:[UIColor whiteColor]];
    [titleLabel3 sizeToFit];
    leftBarBtn3.customView = titleLabel3;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:leftBarBtn1, leftBarBtn2,leftBarBtn3,nil]];
    
    [self initService];
    UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
   self.activationCodeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(ACTIVATION_CODE_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    [self startTimerAndConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - Service Call Method -
- (void)initService {
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"SmsVerifycationViewController";
    //---Initialize Reply Call Back Handler---//
    ReplyHandler * _handler = [[ReplyHandler alloc]
                               initWithModelManager:_modelManager
                               operator:nil
                               progress:nil
                               signupUpdate:nil
                               addMemberUpdate:nil
                               updateUserUpdate:(id)self
                               settingsUpdate:nil
                               loginUpdate:(id)self
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:nil
                               getLocationUpdate:nil
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:nil
                               getAlertUpdate:nil
                               andTarget:self];
    //---Initialize Service Call Back Handler---//
   _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}

#pragma - mark button action
- (IBAction)backLoginVcAction:(id)sender {
}

- (IBAction)submitCodeAction:(id)sender {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    } else {
        if ([self checkInput]) {
            smsVfHud = [[MBProgressHUD alloc] initWithView:self.view];
            [smsVfHud setLabelText:NSLocalizedString(@"verifying...", nil)];
            [self.view addSubview:smsVfHud];
            [smsVfHud show:YES];
            
            _activationCodeField.text = [self.activationCodeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ACTIVATE_CODE_VERIFY],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:@{kCodeKey:_activationCodeField.text}
                                     };
            [_serviceHandler onOperate:newMsg];
        }
    }
}

- (IBAction)resendActivationAction:(id)sender {
    if(isWaitForResendMail) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *numberString = [numberFormatter stringFromNumber:@(_timeCounter)];
        NSString *waitText = NSLocalizedString(@"seconds wait",nil);
        NSString * message = [NSString stringWithFormat:@"%@ %@",numberString,waitText];
        [self showAlertTitle:nil withMessage:message];
    } else {
        [self resendSmsActivationService];
        [self startTimerAndConfig];
    }
}

#pragma - mark user define methods
- (BOOL)checkInput {
    NSString *alertMessage = nil;
    if ([self.activationCodeField.text isEqualToString:@""] || [self.activationCodeField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"Activation code cannot be empty",nil);
    }
    if (alertMessage == nil) {
        return YES;
    }else {
        [self showAlertMessage:nil message:alertMessage];
        return NO;
    }
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertMessageForLoginVc:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                        actionWithTitle:NSLocalizedString(@"OK",nil)
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction *action)
                        {
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            LoginViewController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
                            [self.navigationController pushViewController:loginViewController animated:YES];
                        }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma - mark service callback
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [smsVfHud hide:YES];
        smsVfHud = nil;
        if(sourceType == ACTIVATE_CODE_VERIFY_SUCCCEEDED) {
            [self showAlertMessageForLoginVc:NSLocalizedString(@"Verification Successful",nil) message:@""];
        } else if(sourceType == ACTIVATE_CODE_VERIFY_FAILED) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][_modelManager.defaultLanguage]) {
                    errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(@"Sms verification error",nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Sms verification error",nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

- (void)resendMail {
    if (resendMailTimeCounter) {
        [resendMailTimeCounter invalidate];
        resendMailTimeCounter = nil;
    }
    _timeCounter = 0;
    isWaitForResendMail = NO;
}

- (void)updateRemainingTime {
    _timeCounter--;
}

-(void)startTimerAndConfig {
    isWaitForResendMail = YES;
    self.resendMailTimer = [NSTimer scheduledTimerWithTimeInterval:locationTimerInterval_Sms target:self selector:@selector(resendMail) userInfo:nil repeats:NO];
    _timeCounter = locationTimerInterval_Sms;
    resendMailTimeCounter = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRemainingTime) userInfo:nil repeats:YES];
}
- (void)showAlertTitle:(NSString *)title
           withMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)resendSmsActivationService {
    smsVfHud = [[MBProgressHUD alloc] initWithView:self.view];
    [smsVfHud setLabelText:NSLocalizedString(RESEND_ACTIVATION_CODE,nil)];
    [self.view addSubview:smsVfHud];
    [smsVfHud show:YES];
    NSDictionary *requestBody = @{kUserName:_user_name,
                                  kPassword:_password,
                                  kNotifyMeByKey:@2
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:RESEND_USER_ACTIVATION_CODE],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma - mark Service call back -
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [smsVfHud hide:YES];
        smsVfHud = nil;
        if (success) {
            [self showAlertMessage:NSLocalizedString(@"Resend activation code successfully",nil) message:nil];
        }else {
            [self resendMail];
            if (self.resendMailTimer) {
                [self.resendMailTimer invalidate];
                self.resendMailTimer = nil;
            }
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(@"Resend activation code fail",nil);
                }
            } else {
                errorMsg = NSLocalizedString(@"Resend activation code fail",nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
