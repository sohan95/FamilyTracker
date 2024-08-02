//
//  RegistrationSuccessfulViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/16/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "RegistrationSuccessfulViewController.h"
#import "LoginViewController.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "Common.h"
#import "GlobalServiceManager.h"
#import "MBProgressHUD.h"
#import "JsonUtil.h"

@interface RegistrationSuccessfulViewController ()<Updater> {
    NSTimer *resendMailTimeCounter;
    BOOL isWaitForResendMail;
    MBProgressHUD *resendEmailHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property (nonatomic,strong) NSTimer *resendMailTimer;
@property (nonatomic, assign) int timeCounter;
@end

@implementation RegistrationSuccessfulViewController
double locationTimerInterval_Registration = 15.0;
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationBar setHidden:YES];
    [self initService];
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
    [self startTimerAndConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
}


-(void)viewWillDisappear:(BOOL)animated {
    if (resendMailTimeCounter) {
        [resendMailTimeCounter invalidate];
        resendMailTimeCounter = nil;
    }
    if (self.resendMailTimer) {
        [self.resendMailTimer invalidate];
        self.resendMailTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Call Method -
- (void)initService {
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

#pragma mark General Methods -
- (void)loadLoginPage {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    LoginViewController *loginViewController = [sb instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER_KEY];
    [self.navigationController pushViewController:loginViewController animated:YES];
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

#pragma mark button action event -
- (IBAction)loadLoginBtnTapped {
    [self loadLoginPage];
}

- (IBAction)reSendEmailBtnTapped {
    if(isWaitForResendMail) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *numberString = [numberFormatter stringFromNumber:@(_timeCounter)];
        NSString *waitText = NSLocalizedString(@"seconds wait",nil);
        NSString * message = [NSString stringWithFormat:@"%@ %@",numberString,waitText];
        [self showAlertTitle:nil withMessage:message];
    } else {
        [self resendEmailService];
        [self startTimerAndConfig];
    }
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
    self.resendMailTimer = [NSTimer scheduledTimerWithTimeInterval:locationTimerInterval_Registration target:self selector:@selector(resendMail) userInfo:nil repeats:NO];
    _timeCounter = locationTimerInterval_Registration;
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

-(void)resendEmailService {
    resendEmailHud = [[MBProgressHUD alloc] initWithView:self.view];
    [resendEmailHud setLabelText:NSLocalizedString(RESEND_EMALI_INFO_TEXT,nil)];
    [self.view addSubview:resendEmailHud];
    [resendEmailHud show:YES];
    NSDictionary *requestBody = @{kUserName:_user_name,
                                  kPassword:_password,
                                  kNotifyMeByKey:@1
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
        [resendEmailHud hide:YES];
        resendEmailHud = nil;
        if (success) {
            [self showAlertMessage:NSLocalizedString(@"Re-sent email successfully. Please check your email",nil) message:nil];
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
                    errorMsg = NSLocalizedString(@"Resend eamil fail",nil);
                }
            } else {
                errorMsg = NSLocalizedString(@"Resend eamil fail",nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
