//
//  ContactViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/28/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "TrialExpiredViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "FamilyMemberListViewController.h"
#import "HomeViewController.h"
#import "UpdateProfileViewController.h"
#import "ModelManager.h"
#import "LoginViewController.h"
#import "SurroundAppsViewController.h"
#import "EmergencyContactViewController.h"
#import "NewSettingViewController.h"
#import "GlobalServiceManager.h"
#import "ServiceHandler.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "JsonUtil.h"
@interface TrialExpiredViewController () {
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MBProgressHUD *_progressHud;
    SWRevealViewController *revealController;
    UIViewController *newFrontController;
}

@end

@implementation TrialExpiredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem* logoutBarBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout",nil) style:UIBarButtonItemStylePlain target:self action:@selector(logoutService)];
    self.navigationItem.rightBarButtonItem = logoutBarBtn;
    _modelManager = [ModelManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Call Methods -
- (void)initService {
    //Initialize Service CallBack Handler
    ReplyHandler * _handler = [[ReplyHandler alloc]
                               initWithModelManager:_modelManager
                               operator:nil
                               progress:nil
                               signupUpdate:nil
                               addMemberUpdate:nil
                               updateUserUpdate:nil
                               settingsUpdate:nil
                               loginUpdate:nil
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:nil
                               getLocationUpdate:nil
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:(id)self
                               getAlertUpdate:nil
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}

#pragma mark - user define method
- (void)logoutService {
    _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [_progressHud setLabelText:NSLocalizedString(LOGOUT_TEXT,nil)];
    [self.view addSubview:_progressHud];
    [_progressHud show:YES];
    [self initService];
    NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *requestDataDic = @{WHAT_KEY:[NSNumber numberWithInteger:SIGN_OUT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:@{kTokenKey:_modelManager.user.sessionToken,
                                               kUser_id_key:_modelManager.user.identifier,
                                               kDeviceTypeKey:@"1",
                                               kDeviceNoKey:deviceUUID}
                                     };
    [_serviceHandler onOperate:requestDataDic];
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressHud hide:YES];
        _progressHud = nil;
        if(sourceType == SIGN_OUT_SUCCCEEDED) {
            User * user = _modelManager.user;
            user.sessionToken = nil;
            [JsonUtil saveObject:user withFile:NSStringFromClass([User class])];
            [[GlobalData sharedInstance] reset];
            [_modelManager logOut];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClearMapNotification"
             object:nil];
            //---goto LoginVC ---//
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [sb instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER_KEY];
            UINavigationController *loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            [UIApplication sharedApplication].delegate.window.rootViewController = loginNavigationController;
        }else if(sourceType == SIGN_OUT_FAILED) {
            [Common displayToast:NSLocalizedString(@"LogOut failed!", nil) title:NSLocalizedString(@"Try again", nil) duration:1];
        }
    });
}

@end
