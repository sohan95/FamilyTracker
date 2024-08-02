//
//  ForgotPasswordViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/7/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "Http.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "FamilyTrackerOperate.h"
#import "ReplyHandler.h"
#import "MBProgressHUD.h"
#import "Common.h"
#import "HexToRGB.h"
#import "libPhoneNumberiOS.h"
#import "NBPhoneNumber.h"


@interface ForgotPasswordViewController ()<SignupUpdater,UITextFieldDelegate> {
    MBProgressHUD *resetPasswordHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *smsButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *emailButtonOutlet;
- (IBAction)smsButtonAction:(id)sender;
- (IBAction)emailButtonAction:(id)sender;
- (IBAction)resetButtonAction:(id)sender;
@property (nonatomic,strong) NSString * resetBy;
@end

@implementation ForgotPasswordViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
     self.title = NSLocalizedString(@"Forgot Password",nil);
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToLoginVc)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    //Gesture Recognizer For Hiding Keyboard
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"ForgotPasswordViewController";
    [self initService];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
    [self setDefaultView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma - mark User Define Method - 
- (void)setDefaultView {
    if ([self.userNameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(USER_NAME_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.phoneTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(MOBILE_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.emailTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(EMAIL_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    _resetBy = @"";
}


- (void)initService {
    //---Initialize Reply Call Back Handler---//
    ReplyHandler * handler = [[ReplyHandler alloc]
                              initWithModelManager:_modelManager
                              operator:nil
                              progress:nil
                              signupUpdate:(id)self
                              addMemberUpdate:nil
                              updateUserUpdate:nil
                              settingsUpdate:nil
                              loginUpdate:nil
                              trackAppDayNightModeUpdate:(id)self
                              saveLocationUpdate:nil
                              getLocationUpdate:nil
                              getLocationHistoryUpdate:nil
                              saveAlertUpdate:nil
                              getAlertUpdate:nil
                              andTarget:self];
    //---Initialize Service Call Back Handler---//
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

- (BOOL)checkInput {
    self.userNameTextField.text = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *alertMessage = nil;
    if ([self.userNameTextField.text isEqualToString:@""] || [self.userNameTextField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"User Name can't be empty!",nil);
    }
    if (alertMessage == nil) {
        return YES;
    }else {
        [self showAlertMessage:nil message:alertMessage];
        return NO;
    }
}

- (BOOL)validEmail:(NSString *)checkString {
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:checkString];
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

#pragma mark - Action Methods -
- (IBAction)backToLoginVc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)smsButtonAction:(id)sender {
    _resetBy = SMS;
    [_smsButtonOutlet setBackgroundImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [_emailButtonOutlet setBackgroundImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}
- (IBAction)emailButtonAction:(id)sender {
    _resetBy = MAIL;
    [_smsButtonOutlet setBackgroundImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [_emailButtonOutlet setBackgroundImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
}

- (IBAction)resetButtonAction:(id)sender {
    if([self checkInput]) {
        [self resetPasswordService];
    }
}

#pragma mark - Gesture Recognizer Delegate -
- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    [self.userNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

#pragma mark Service call - 
-(void)resetPasswordService {
    resetPasswordHud = [[MBProgressHUD alloc] initWithView:self.view];
    [resetPasswordHud setLabelText:NSLocalizedString(RESET_PASSWORD_INFO_TEXT,nil)];
    [self.view addSubview:resetPasswordHud];
    [resetPasswordHud show:YES];
    NSDictionary *newMsg;
    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:RESET_PASSWORD],
               WHEN_KEY:[NSDate date],
               OBJ_KEY:@{
                       kUserName:_userNameTextField.text
                       }
               };
    [_serviceHandler onOperate:newMsg];
}

#pragma mark - Service Callback -
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [resetPasswordHud hide:YES];
        resetPasswordHud = nil;
        if (success) {
            NSString *successMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if(object[[ModelManager sharedInstance].defaultLanguage]) {
                    successMsg = object[[ModelManager sharedInstance].defaultLanguage];
                }
            }
            [self showAlertMessage:successMsg message:nil];
        }else {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(SIGNUP_ERROR,nil);
                }
            } else {
                errorMsg = NSLocalizedString(SIGNUP_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
