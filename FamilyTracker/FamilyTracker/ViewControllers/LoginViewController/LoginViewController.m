//
//  LoginViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/14/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "LoginViewController.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "LoginUpdater.h"
#import "FamilyTrackerOperate.h"
#import "ReplyHandler.h"
#import "MBProgressHUD.h"
#import "Common.h"
#import "HexToRGB.h"
#import "AudioViewController.h"
#import "JsonUtil.h"
#import "ChatManager.h"
#import "User.h"
#import "CacheSlide.h"
#import "SmsVerifycationViewController.h"
#import "DbHelper.h"
#import "ForgotPasswordViewController.h"
#import "GlobalServiceManager.h"

@interface LoginViewController ()<Updater,SWRevealViewControllerDelegate, UITextFieldDelegate> {
    MBProgressHUD *loginHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property (weak,nonatomic) IBOutlet UILabel *informationLabel;
@property (weak,nonatomic) IBOutlet UITextField *userIdField;
@property (weak,nonatomic) IBOutlet UITextField *passwordField;
@property (weak,nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property (nonatomic,strong) NSString * defaultLanguage;
@property (strong, nonatomic) IBOutlet UIView *dropDownView;
@property (strong, nonatomic) IBOutlet UIButton *languageBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginButtonOutlet;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //--viewSettings---//
    [self.navigationController.navigationBar setHidden:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.title = NSLocalizedString(@"Login",nil);    
    self.informationLabel.numberOfLines = 0;
    self.informationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    //---Gesture Recognizer For Hiding Keyboard---//
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    _modelManager = [ModelManager sharedInstance];
    [self setDefaultView];
    [self initService];
    //--- go out from room and disconnect---//
    [[ChatManager instance] leaveRoom];
    //---check signup varification by sms/email---//
        if([[NSUserDefaults standardUserDefaults] boolForKey:IS_ACTIVATION_CODE_NOT_VERIFIED]) {
            if(![_modelManager.currentVCName isEqualToString:@"SmsVerifycationViewController"]) {
                [self gotoSmsVerifycationVC];
            }
        }
    _modelManager.currentVCName = @"LoginViewController";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //--- Get Device current language setting---//
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language isEqual:@"bn-US"] || [language isEqual:@"bn-BD"]) {
        language = BANGLA_LANGUAGE;
    } else if([language isEqual:@"en"]) {
        language = ENGLISH_LANGUAGE;
    } else {
        language = ENGLISH_LANGUAGE;
    }
    [ModelManager sharedInstance].defaultLanguage = language;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User Defined Methods -
- (void)setDefaultView {
    self.loginButtonOutlet.layer.cornerRadius = 20;
    self.loginButtonOutlet.layer.masksToBounds = YES;
    self.userIdField.layer.cornerRadius = 20;
    self.userIdField.layer.masksToBounds = YES;
    self.passwordField.layer.cornerRadius = 20;
    self.passwordField.layer.masksToBounds = YES;
    if ([_modelManager.defaultLanguage isEqualToString:BANGLA_LANGUAGE]) {
        [self.languageBtn setTitle:NSLocalizedString(LANGUAGE_BANGLA, nil) forState: UIControlStateNormal];
    } else if ([_modelManager.defaultLanguage isEqualToString:ENGLISH_LANGUAGE]) {
        [self.languageBtn setTitle:NSLocalizedString(LANGUAGE_ENGLISH, nil) forState: UIControlStateNormal];
    }
    [self.dropDownView setHidden:YES];
    if ([self.userIdField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.userIdField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(USER_NAME_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    [self.userIdField setBackground:[UIImage imageNamed:TEXT_FIELD_ACTIVE]];
    [self.passwordField setBackground:[UIImage imageNamed:TEXT_FIELD_INACTIVE]];
}

- (BOOL)checkInput {
    NSString *alertMessage = nil;
    if ([self.userIdField.text isEqualToString:@""] || [self.userIdField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"User Id cannot be empty",nil);
    } else if ([self.passwordField.text isEqualToString:@""] || [self.passwordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"Password cannot be empty",nil);
    }
    if (alertMessage == nil) {
        return YES;
    } else {
        [self showAlertMessage:nil message:alertMessage];
        return NO;
    }
}

- (void)lazyImageLoderForProfileImage {
    NSString *imageUrl = _modelManager.user.profilePicture;
    if ([Common isNullObject:imageUrl] ||
        imageUrl.length < 1) {
    }else {
        CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
        NSURL *imageURL = [NSURL URLWithString:imageUrl];
        [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
            if ([type isEqualToString:@"image"]) {
                UIImage *image = (UIImage *)cachedSlide;
                if(image) {
                   [GlobalData sharedInstance].profilePicture = image;
                }
                
            } else {
                
            }
        } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
            NSLog(@"Image cache fail");
        }];
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

- (void)gotoSmsVerifycationVC {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SmsVerifycationViewController *smsVerifycationViewController = [sb instantiateViewControllerWithIdentifier:@"SmsVerifycationViewController"];
    [self.navigationController pushViewController:smsVerifycationViewController animated:YES];
}

- (void)loadHomeView {
    [loginHud hide:YES];
    loginHud = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:IsFirebaseTokenRegSuccess];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[GlobalServiceManager sharedInstance] deviceRegistrationForPushNotification];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_ACTIVATION_CODE_NOT_VERIFIED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    HomeViewController *homeViewController = [sb instantiateViewControllerWithIdentifier:HOME_VIEW_CONTROLLER_KEY];
    MenuViewController *menuViewController = [sb instantiateViewControllerWithIdentifier:MENU_VIEW_CONTROLLER_KEY];
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:nil frontViewController:frontNavigationController];
    revealController.delegate = self;
    revealController.rightViewController = menuViewController;
    [self.navigationController pushViewController:revealController animated:YES];
}

#pragma mark - Button Action Methods -
- (IBAction)doLogin {
    if([FamilyTrackerReachibility isUnreachable]) {
        //If Internect Connectivity is OFF,Then load data from cache
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    }else {
        [self.userIdField resignFirstResponder];
        if ([self checkInput]) {
            loginHud = [[MBProgressHUD alloc] initWithView:self.view];
            [loginHud setLabelText:NSLocalizedString(LOGIN_TEXT,nil)];
            [self.view addSubview:loginHud];
            [loginHud show:YES];
            self.userIdField.text = [self.userIdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.passwordField.text = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:LOGIN],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:@{kUserName:_userIdField.text,
                                           kPasswordKey:_passwordField.text,
                                               kDeviceTypeKey:@"1",
                                               kDeviceNoKey:deviceUUID}
                                     };
            [_serviceHandler onOperate:newMsg];
        }
    }
}

- (IBAction)forgotPasswordBtnTapped {

}

#pragma mark - Set
- (IBAction)languageToggleBtn:(UIButton *)sender {
    if ([_dropDownView isHidden]) {
        [self.dropDownView setHidden:NO];
    } else {
        [self.dropDownView setHidden:YES];
    }
}

- (void)setLanguageValue:(NSString *)language {
//    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Info", nil)
                                          message:NSLocalizedString(@"App need to restart to change app language", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Ok", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   if([language isEqualToString:@"bn"]) {
                                       [[NSUserDefaults standardUserDefaults]  setObject:[NSArray arrayWithObjects:@"bn-BD", @"bn-US", nil] forKey:@"AppleLanguages"];
                                   } else if([language isEqualToString:@"en"]) {
                                       [[NSUserDefaults standardUserDefaults]  setObject:[NSArray arrayWithObjects:@"en-BD", @"en-US", nil] forKey:@"AppleLanguages"];
                                   }
                                   
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   //[[NSThread mainThread] exit];
                                   exit(0);
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {}];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)selectBanglaBtn:(id)sender {
    [self.dropDownView setHidden:YES];
    [self.languageBtn setTitle:NSLocalizedString(LANGUAGE_BANGLA, nil) forState: UIControlStateNormal];
    [self setLanguageValue:@"bn"];
}

- (IBAction)selectEnglishBtn:(id)sender {
    [self.dropDownView setHidden:YES];
    [self.languageBtn setTitle:NSLocalizedString(LANGUAGE_ENGLISH, nil) forState: UIControlStateNormal];
    [self setLanguageValue:@"en"];
}

#pragma mark - Gesture Recognizer Delegate -
- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    [self.userIdField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [_userIdField setBackground:[UIImage imageNamed:TEXT_FIELD_INACTIVE]];
    [_passwordField setBackground:[UIImage imageNamed:TEXT_FIELD_INACTIVE]];
    _dropDownView.hidden = YES;

}

#pragma mark - UITextField Delegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //---Set textFieldBgImageView---//
    if ([textField isFirstResponder]) {
        [textField setBackground:[UIImage imageNamed:TEXT_FIELD_ACTIVE]];
    } else {
        [textField setBackground:[UIImage imageNamed:TEXT_FIELD_INACTIVE]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //---verify the text field you wanna validate---//
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

- (void)getEmergencyContactService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    }else {
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_modelManager.user.identifier,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)forceSignOutService {
    //---Progress HUD---//
    if (loginHud) {
        [loginHud setLabelText:NSLocalizedString(FORCE_SIGNOUT_TEXT,nil)];
    }
    [self.view addSubview:loginHud];
    NSDictionary *requestDataDic = @{WHAT_KEY:[NSNumber numberWithInteger:FORCE_SIGNOUT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:@{kUserName:_userIdField.text}
                                     };
    [_serviceHandler onOperate:requestDataDic];
}

#pragma mark - Service Callback Method
- (void)signupSuccess:(id)object isSuccess:(BOOL)success { 
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            //---Save user data to do auto login
            NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
            [userDic setObject:self.userIdField.text forKey:kUserName];
            [userDic setObject:self.passwordField.text forKey:kPasswordKey];
            [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:USER_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //---Read emergency contact list from  sqlite db end---
            [NSTimer scheduledTimerWithTimeInterval:0.2
                                             target:self
                                           selector:@selector(loadHomeView)
                                           userInfo:nil
                                            repeats:NO];
        }//---end success if---//
        else {
            NSString *errorMsg = @"";
            NSString * errorMsgForNotActive = @"";
            if ([object isKindOfClass:[NSDictionary class]] && [object[kCodeKey] integerValue] == 555) {
                errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:nil message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"OK",nil)
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self forceSignOutService];
                                           }];
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [loginHud hide:YES];
                                                   loginHud = nil;
                                               }];
                [alertController addAction:okAction];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                [loginHud hide:YES];
                loginHud = nil;
                if([object isKindOfClass:[NSDictionary class]]) {
                    //---Check single logout---//
                    if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                        errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                        if (object[kMessageKey][@"en"]) {
                            errorMsgForNotActive = object[kMessageKey][@"en"];
                        }
                    }else {
                        errorMsg = LOGIN_ERROR;
                    }
                }else {
                    errorMsg = NSLocalizedString(LOGIN_ERROR,nil);
                }
                if([errorMsgForNotActive isEqualToString:@"User is not active."]) {
                    [self gotoSmsVerifycationVC];
                }else {
                    [self showAlertMessage:errorMsg message:nil];
                }
            }
        }//---end if---//
    });
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sourceType == FORCE_SIGNOUT_SUCCCEEDED) {
            if (loginHud) {
                [loginHud hide:YES];
                loginHud = nil;
            }
            [self doLogin];
        } else if(sourceType == FORCE_SIGNOUT_FAILED) {
            if (loginHud) {
                [loginHud hide:YES];
                loginHud = nil;
            }
            [self showAlertMessage:NSLocalizedString(@"Please try again", nil) message:nil];
        }
    });
}

@end
