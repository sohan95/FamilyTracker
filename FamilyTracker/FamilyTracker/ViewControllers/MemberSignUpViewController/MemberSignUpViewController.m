//
//  MemberSignUpViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/22/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "MemberSignUpViewController.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "MemberRegistrationSuccessfulVC.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "ModelManager.h"

@interface MemberSignUpViewController ()<SignupUpdater,UITextFieldDelegate>{
    MBProgressHUD *loginHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    UIDatePicker *datePicker;
}
@property (weak,nonatomic) IBOutlet UITextField *userIdField;
@property (weak,nonatomic) IBOutlet UITextField *passwordField;
@property (weak,nonatomic) IBOutlet UITextField *mobileField;
@property (weak,nonatomic) IBOutlet UITextField *emailField;
@property (weak,nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic,strong) NSString * defaultLanguage;
- (IBAction)smsButtonAction:(id)sender;
@property (nonatomic,strong) NSString * activationType;
@property (weak, nonatomic) IBOutlet UIButton *smsButton;
- (IBAction)mailButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;

@end

@implementation MemberSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = NSLocalizedString(CREATE_MEMBER_PAGE_TITLE,nil);
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToMemberList)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    [self initService];
    //---Gesture Recognizer For Hiding Keyboard---//
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [GlobalData sharedInstance].currentVC = self;
    [self setDefaultView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self resetTextField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User Defined Methods -
- (void)initService {
    //---Service Initialization--//
    _modelManager = [ModelManager sharedInstance];
    //---Initialize Reply Call Back Handler---//    
    ReplyHandler * handler = [[ReplyHandler alloc]
                              initWithModelManager:_modelManager
                              operator:nil
                              progress:nil
                              signupUpdate:nil
                              addMemberUpdate:(id)self
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

- (void)getAllMemberDataSevice {
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestBody = @{kGuardianId:guardianId,
                                  kTokenKey:_modelManager.user.sessionToken};
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_All_MEMBERS_AFTER_NEW_MEMBER],
                       WHEN_KEY:[NSDate date],
                       OBJ_KEY:requestBody
                       };
    [_serviceHandler onOperate:requestBodyDic];
}

-(void)setDefaultView {
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

- (void)resetTextField {
    [self.userIdField setText:@""];
    [self.passwordField setText:@""];
    [self.mobileField setText:@""];
    [self.emailField setText:@""];
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
    }else if([_activationType isEqual:SMS] &&([self.mobileField.text isEqualToString:@""] || [self.mobileField.text isEqual:nil])){
        alertMessage = NSLocalizedString(@"Contact can't be empty!",nil);
    }else if([_activationType isEqual:MAIL] &&([self.emailField.text isEqualToString:@""] || [self.emailField.text isEqual:nil])){
        alertMessage = NSLocalizedString(@"Email can't be empty!",nil);
    }else if ([_activationType isEqual:MAIL] &&![self validEmail:self.emailField.text] ) {
        alertMessage = NSLocalizedString(@"Incorrect email formate!",nil);
    }
    //---check again---//
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
                               actionWithTitle:NSLocalizedString(OK_BUTTON_TITLE_KEY, nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadRegistrationSuccessFullPage {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    MemberRegistrationSuccessfulVC *memberRegistrationSuccessfulVC = [sb instantiateViewControllerWithIdentifier:MEMBER_REGISTRATION_SUCCESSFUL_VC_KEY];
    [self.navigationController pushViewController:memberRegistrationSuccessfulVC animated:YES];
}

#pragma mark - Action Methods -
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
- (void)backToMemberList {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpBtnTapped {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        //---Dismiss the keyboard.---//
        [self.userIdField resignFirstResponder];
        if ([self checkInput]) {
            loginHud = [[MBProgressHUD alloc] initWithView:self.view];
            [loginHud setLabelText:NSLocalizedString(MEMBER_SIGNUP_TEXT,nil)];
            [self.view addSubview:loginHud];
            [loginHud show:YES];
            NSString *userIdTrimed = [self.userIdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *passwordTrimed = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSDictionary *newMsg;
            if(![self.emailField.text isEqual:nil] && self.emailField.text.length>0 && ![self.mobileField.text isEqual:nil] && self.mobileField.text.length>0) {
                newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER],
                             WHEN_KEY:[NSDate date],
                             OBJ_KEY:@{
                                     kUserContact:_mobileField.text,
                                     kUserEmail:_emailField.text,
                                     kUserName:userIdTrimed,
                                     kPassword:passwordTrimed,
                                     kUserRole:@2,
                                     kGuardianId:_modelManager.user.identifier
                                     //kSettings:[[NSArray alloc] init]
                                     }
                             };
            }else {
                if([_activationType isEqual:MAIL]) {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{
                                       kUserEmail:_emailField.text,
                                       kUserName:userIdTrimed,
                                       kPassword:passwordTrimed,
                                       kUserRole:@2,
                                       kGuardianId:_modelManager.user.identifier
                                       //kSettings:[[NSArray alloc] init]
                                       }
                               };
                } else {
                    newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_MEMBER],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:@{
                                       kUserContact:_mobileField.text,
                                       kUserName:userIdTrimed,
                                       kPassword:passwordTrimed,
                                       kUserRole:@2,
                                       kGuardianId:_modelManager.user.identifier
                                       //kSettings:[[NSArray alloc] init]
                                       }
                               };
                }
            }
            [_serviceHandler onOperate:newMsg];
        }
    }
}

#pragma mark - UITextField Delegates -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        UIImage *fieldBgImageActive = [[UIImage imageNamed:TEXT_FIELD_ACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
        [textField setBackground:fieldBgImageActive];
        fieldBgImageActive = nil;
    }else {
        UIImage *fieldBgImageInactive = [[UIImage imageNamed:TEXT_FIELD_INACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
        [textField setBackground:fieldBgImageInactive];
        fieldBgImageInactive = nil;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
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

#pragma mark -Gesture Recognizer Delegate-
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
        if([ModelManager sharedInstance].defaultLanguage != nil) {
            _defaultLanguage = [ModelManager sharedInstance].defaultLanguage;
        }else {
            _defaultLanguage = ENGLISH_LANGUAGE;
        }
        if (success) {
            [self getAllMemberDataSevice];
            [self loadRegistrationSuccessFullPage];
        }else {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey][_defaultLanguage]) {
                    errorMsg = object[kMessageKey][_defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(SIGNUP_ERROR,nil);
                }
            }else {
                errorMsg = NSLocalizedString(SIGNUP_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

- (void)refreshUI:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sourceType == GET_All_MEMBERS_SUCCEEDED) {
        }else if (sourceType == GET_All_MEMBERS_FAILED) {
        }
    });
}

@end
