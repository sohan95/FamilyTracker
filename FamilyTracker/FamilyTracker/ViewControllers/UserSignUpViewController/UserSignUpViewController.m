//
//  UserSignUpViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/16/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "UserSignUpViewController.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "RegistrationSuccessfulViewController.h"
#import "Http.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "FamilyTrackerOperate.h"
#import "ReplyHandler.h"
#import "MBProgressHUD.h"
#import "Common.h"
#import "HexToRGB.h"
#import "SignupUpdater.h"
#import "libPhoneNumberiOS.h"
#import "NBPhoneNumber.h"
#import "SmsVerifycationViewController.h"

@interface UserSignUpViewController ()<SignupUpdater, UITextFieldDelegate>{
    MBProgressHUD *loginHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}

@property (weak,nonatomic) IBOutlet UITextField *userIdField;
@property (weak,nonatomic) IBOutlet UITextField *passwordField;
@property (weak,nonatomic) IBOutlet UITextField *mobileField;
@property (weak,nonatomic) IBOutlet UITextField *emailField;
@property (weak,nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic,strong) NSString * activationType;
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
- (IBAction)smsButtonAction:(id)sender;
- (IBAction)mailButtonAction:(id)sender;

@end

@implementation UserSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(SIGN_UP_PAGE_TITLE_KEY,nil);
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToLogin)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    //Gesture Recognizer For Hiding Keyboard
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    [self initService];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GlobalData sharedInstance].currentVC = self;
    [self setDefaultView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User Defined Methods -
- (void)initService {
    //---SignUp Service setup---//
    _modelManager = [ModelManager sharedInstance];
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

- (void)setDefaultView {
    //---End Border and Hide DropDownView---//
    if ([self.userIdField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.userIdField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(USER_NAME_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.mobileField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.mobileField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(MOBILE_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(EMAIL_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    _activationType = @"";
    //---Set textFieldBgImageView---//
    UIImage *fieldBgImageInactive = [[UIImage imageNamed:TEXT_FIELD_INACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
    UIImage *fieldBgImageActive = [[UIImage imageNamed:TEXT_FIELD_ACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
    [self.userIdField setBackground:fieldBgImageActive];
    [self.passwordField setBackground:fieldBgImageInactive];
    [self.mobileField setBackground:fieldBgImageInactive];
    [self.emailField setBackground:fieldBgImageInactive];
    UIImage *nextStepImage = [[UIImage imageNamed:@"BlueBackgroundWithArrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
    [self.nextBtn setBackgroundImage:nextStepImage forState:UIControlStateNormal];
}

- (BOOL)validEmail:(NSString *)checkString {
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)loadRegistrationSuccessFullPage {
    if([_activationType isEqual:SMS]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_ACTIVATION_CODE_NOT_VERIFIED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        SmsVerifycationViewController *smsVerifycationViewController = [sb instantiateViewControllerWithIdentifier:@"SmsVerifycationViewController"];
        smsVerifycationViewController.activationType = _activationType;
        smsVerifycationViewController.user_name = _userIdField.text;
        smsVerifycationViewController.password = _passwordField.text;
        [self.navigationController pushViewController:smsVerifycationViewController animated:YES];
    } else if([_activationType isEqual:MAIL]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        RegistrationSuccessfulViewController *registrationSuccessfulViewController = [sb instantiateViewControllerWithIdentifier:REGISTRATION_SUCCESSFUL_VIEW_CONTROLLER_KEY];
        registrationSuccessfulViewController.activationType = _activationType;
        registrationSuccessfulViewController.user_name = _userIdField.text;
        registrationSuccessfulViewController.password = _passwordField.text;
        [self.navigationController pushViewController:registrationSuccessfulViewController animated:YES];
    }
}

- (BOOL)checkInput {
     self.userIdField.text = [self.userIdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.passwordField.text = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.mobileField.text = [self.mobileField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.emailField.text = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *alertMessage = nil;
    if ([self.userIdField.text isEqualToString:@""] || [self.userIdField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"User Name can't be empty!",nil);
    }else if ([self.passwordField.text isEqualToString:@""] || [self.passwordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"Password can't be empty!",nil);
    }else if([_activationType isEqual:@""]){
        alertMessage = NSLocalizedString(@"Please Select activation type",nil);
    }else if([_activationType isEqual:SMS]){
        if([self.mobileField.text isEqualToString:@""] || [self.mobileField.text isEqual:nil]) {
            alertMessage = NSLocalizedString(@"Contact can't be empty!",nil);
        }
        //check number Validation
        NSString *mobileNumber = _mobileField.text;
        NSError *anError = nil;
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NBPhoneNumber *myNumber = [phoneUtil parse:mobileNumber defaultRegion:@"BD" error:&anError];
        if (anError == nil) {
            if ([phoneUtil isValidNumber:myNumber]) {
               mobileNumber = [phoneUtil format:myNumber
                                                  numberFormat:NBEPhoneNumberFormatE164
                                                         error:&anError];
                NSString *nationalNumber = nil;
                NSNumber *countryCode = [phoneUtil extractCountryCode:mobileNumber nationalNumber:&nationalNumber];
                if ([countryCode stringValue].length == 3 && [[countryCode stringValue] isEqualToString:@"880"]) {
                    _mobileField.text = mobileNumber;//[NSString stringWithFormat:@"%@%@",[countryCode stringValue], nationalNumber];
                }else {
                    alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
                }
            }else {
                alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
            }
        }else {
            alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
        }
    }
    else if([_activationType isEqual:MAIL] &&([self.emailField.text isEqualToString:@""] || [self.emailField.text isEqual:nil])){
         alertMessage = NSLocalizedString(@"Email can't be empty!",nil);
    }else if ([_activationType isEqual:MAIL] &&![self validEmail:self.emailField.text] ) {
        alertMessage = NSLocalizedString(@"Incorrect email formate!",nil);
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

#pragma mark - Action Methods -
- (IBAction)backToLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)smsButtonAction:(id)sender {
    _activationType = SMS;
    [_smsButton setBackgroundImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [_mailButton setBackgroundImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)mailButtonAction:(id)sender {
    _activationType = MAIL;
    [_smsButton setBackgroundImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [_mailButton setBackgroundImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
}

- (IBAction)signUpBtnTapped {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        //---Dismiss the keyboard.---//
        [self.userIdField resignFirstResponder];
        if ([self checkInput]) {
            loginHud = [[MBProgressHUD alloc] initWithView:self.view];
            [loginHud setLabelText:NSLocalizedString(SIGNUP_TEXT,nil)];
            [self.view addSubview:loginHud];
            [loginHud show:YES];
            NSString *userIdTrimed = [self.userIdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *passwordTrimed = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSDictionary *newMsg;
            if(![self.emailField.text isEqual:nil] && self.emailField.text.length>0 && ![self.mobileField.text isEqual:nil] && self.mobileField.text.length>0) {
                if([_activationType isEqual:MAIL]) {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{kUserContact:_mobileField.text,
                                         kUserEmail:_emailField.text,
                                         kUserName:userIdTrimed,
                                         kPasswordKey:passwordTrimed,
                                         kNotifyMeByKey:@1,
                                         kUserRole:@1}
                               };
                }else {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{kUserContact:_mobileField.text,
                                         kUserEmail:_emailField.text,
                                         kUserName:userIdTrimed,
                                         kPasswordKey:passwordTrimed,
                                         kNotifyMeByKey:@2,
                                         kUserRole:@1}
                               };
                }
            }else {
                if([_activationType isEqual:MAIL]) {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{kUserEmail:_emailField.text,
                                         kUserName:userIdTrimed,
                                         kPasswordKey:passwordTrimed,
                                         kNotifyMeByKey:@1,
                                         kUserRole:@1}
                               };
                }else {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:SIGNUP],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{kUserContact:_mobileField.text,
                                         kUserName:userIdTrimed,
                                         kPasswordKey:passwordTrimed,
                                         kNotifyMeByKey:@2,
                                         kUserRole:@1}
                               };
                }
            }
            [_serviceHandler onOperate:newMsg];
        }
    }
}

#pragma mark - UITextField Delegates -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //---Set textFieldBgImageView---//
    if ([textField isFirstResponder]) {
        UIImage *fieldBgImageActive = [[UIImage imageNamed:TEXT_FIELD_ACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
        [textField setBackground:fieldBgImageActive];
        fieldBgImageActive = nil;
    } else {
        UIImage *fieldBgImageInactive = [[UIImage imageNamed:TEXT_FIELD_INACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
        [textField setBackground:fieldBgImageInactive];
        fieldBgImageInactive = nil;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // verify the text field you wanna validate
    if (textField == _userIdField || textField == _passwordField) {
        // do not allow the first character to be space | do not allow more than one space
        if ([string isEqualToString:@" "]) {
            if (!textField.text.length)
                return NO;
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@" "].length)
                return NO;
        }
        // allow backspace
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length < textField.text.length) {
            return YES;
        }
        // in case you need to limit the max number of characters
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length > 30) {
            return NO;
        }
        return YES;
    }
    return YES;
}

#pragma mark Gesture Recognizer Delegate
- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    [self.userIdField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.mobileField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

#pragma mark - Service Callback -
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [loginHud hide:YES];
        loginHud = nil;
        if (success) {
            [self loadRegistrationSuccessFullPage];
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
