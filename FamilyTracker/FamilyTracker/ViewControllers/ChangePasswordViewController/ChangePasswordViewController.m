//
//  ChangePasswordViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/6/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "Common.h"
#import "GlobalServiceManager.h"
#import "MBProgressHUD.h"
#import "JsonUtil.h"

@interface ChangePasswordViewController () <Updater,UITextFieldDelegate> {
    MBProgressHUD *changePasswordHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property (weak, nonatomic) IBOutlet UITextField *changePasswordField;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
- (IBAction)changePasswordAction:(id)sender;

@end

@implementation ChangePasswordViewController{
    BOOL isChangePasswordSuccess;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Change password",nil);
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToSettingVc)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    _modelManager = [ModelManager sharedInstance];
    [self setDefaultView];
    [self initService];
    isChangePasswordSuccess = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Defined Methods -
- (void)setDefaultView {
    if ([self.oldPasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.oldPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(OLD_PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    if ([self.changePasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.changePasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(NEW_PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
}

- (BOOL)checkInput {
    NSString *alertMessage = nil;
    self.oldPasswordField.text = [self.oldPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.changePasswordField.text = [self.changePasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.oldPasswordField.text isEqualToString:@""] || [self.oldPasswordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"Old Password cannot be empty",nil);
    }else if ([self.changePasswordField.text isEqualToString:@""] || [self.changePasswordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"New Password cannot be empty",nil);
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
                                   if(isChangePasswordSuccess) {
                                       [self backToSettingVc];
                                   }
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma - mark button action 
- (void)backToSettingVc {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePasswordAction:(id)sender {
    if([self checkInput]) {
        [self changePasswordService];
    }
}


#pragma mark -Gesture Recognizer Delegate-
- (void)hideKeyboard:(UITapGestureRecognizer*)sender {
    [self.oldPasswordField resignFirstResponder];
    [self.changePasswordField resignFirstResponder];
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

-(void)changePasswordService {
    changePasswordHud = [[MBProgressHUD alloc] initWithView:self.view];
    [changePasswordHud setLabelText:NSLocalizedString(CHANGE_PASSWORD_INFO_TEXT,nil)];
    [self.view addSubview:changePasswordHud];
    [changePasswordHud show:YES];
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kUser_id_key: _modelManager.user.identifier,
                                  kOldPassword_key:_oldPasswordField.text,
                                  kNewPassword_key:_changePasswordField.text
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:CHANGE_PASSWORD],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma - mark Service call back - 
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [changePasswordHud hide:YES];
        changePasswordHud = nil;
        isChangePasswordSuccess = NO;
        if (success) {
            _modelManager.user.password = _changePasswordField.text;
            [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
            [userDic setObject:_modelManager.user.userName forKey:kUserName];
            [userDic setObject:_changePasswordField.text forKey:kPasswordKey];
            [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:USER_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            isChangePasswordSuccess = YES;
            [self showAlertMessage:NSLocalizedString(@"Password change successfully",nil) message:nil];
        }else {
            isChangePasswordSuccess = NO;
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(CHANGE_PASSWORD_ERROR,nil);
                }
            } else {
                errorMsg = NSLocalizedString(CHANGE_PASSWORD_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
