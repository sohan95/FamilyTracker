//
//  MenuViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/15/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//
#import "MenuViewController.h"
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
//#import "SVWebViewController.h"
#import "PaymentViewController.h"
#import "MenuTableViewCell.h"
#import "AddDeviceViewController.h"
#import "SilentAudioStreamingViewController.h"
#import "MemberAddDeviceViewController.h"
#import "PackagesViewController.h"
#import "BatteryStatusViewController.h"

@interface MenuViewController () {
    NSInteger _presentedRow;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MBProgressHUD *_progressHud;
    SWRevealViewController *revealController;
    UIViewController *newFrontController;
}
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelManager = [ModelManager sharedInstance];
    self.view.backgroundColor = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];//[HexToRGB colorForHex:MENU_BACKGROUND_COLOR];
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2;
    self.userProfileImageView.layer.masksToBounds = YES;
    self.menuTableView.backgroundColor = [UIColor clearColor];
    _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUIWithUserRole];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark User Defined Methods -
- (void)gotoMemberListVC {
    UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
    UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
    if([currentVC isKindOfClass:[FamilyMemberListViewController class]]){
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }else {
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        FamilyMemberListViewController *familyMemberListViewController = [sb instantiateViewControllerWithIdentifier:FAMILY_MEMBER_VIEW_CONTROLLER_KEY];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:familyMemberListViewController];
        [revealController pushFrontViewController:newFrontController animated:YES];
    }
}

- (void)gotoEmergencyContactVC {
    UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
    UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
    if([currentVC isKindOfClass:[EmergencyContactViewController class]]){
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }else {
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        EmergencyContactViewController *emergencyContactVC= [sb instantiateViewControllerWithIdentifier:EMERGENCY_CONTACT_VIEW_CONTROLLER_KEY];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:emergencyContactVC];
        [revealController pushFrontViewController:newFrontController animated:YES];
    }
}

- (void)gotoUserSettingsVC {
    UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
    UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
    
    if([currentVC isKindOfClass:[NewSettingViewController class]]){
        [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
    }else {
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        NewSettingViewController *newSettingViewController = [sb instantiateViewControllerWithIdentifier:@"NewSettingViewController"];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:newSettingViewController];
        [revealController pushFrontViewController:newFrontController animated:YES];
    }
}

- (void)setUIWithUserRole {
    if ([GlobalData sharedInstance].profilePicture) {
        [_blurUserProfileImageView setImage:[GlobalData sharedInstance].profilePicture];
        [_userProfileImageView setImage:[GlobalData sharedInstance].profilePicture];
    }
    if ([_modelManager.user.role integerValue] == 1) {
        _userRoleLbl.text = NSLocalizedString(@"Guardian",nil);
    }else {
        _userRoleLbl.text = NSLocalizedString(@"Member",nil);
    }
    if(([Common isNullObject:_modelManager.user.firstName] || _modelManager.user.firstName.length<1) && ([Common isNullObject:_modelManager.user.lastName] || _modelManager.user.lastName.length<1)) {
        _userNameLbl.text = _modelManager.user.userName;
    } else {
        if ([Common isNullObject:_modelManager.user.lastName] || _modelManager.user.lastName.length<1) {
            _userNameLbl.text = [NSString stringWithFormat:@"%@",_modelManager.user.firstName];
        }else {
            _userNameLbl.text = [NSString stringWithFormat:@"%@ %@",_modelManager.user.firstName, _modelManager.user.lastName];
        }
    }
}

#pragma mark TableView delegate methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_modelManager.user.role integerValue] == 1) {//Guardian user
        return 8;
    }else {//Member user
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableViewCell *menuCell = [tableView dequeueReusableCellWithIdentifier:MENU_CELL_IDENTIFIER_KEY];
    if (menuCell == nil) {
        menuCell = (MenuTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MENU_CELL_IDENTIFIER_KEY];
    }
    if ([_modelManager.user.role integerValue] == 1) {//Guardian user
        switch (indexPath.row) {
            case 0:
                menuCell.titleLabel.text = NSLocalizedString(PROFILE_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(PROFILE_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:USER_PROFILE]];
                break;
            case 1:
                menuCell.titleLabel.text =  NSLocalizedString(CONFIGURE_MEMBER_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(CONFIGURE_MEMBER_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:USER_CONTROL]];
                break;
            case 2:
                menuCell.titleLabel.text = NSLocalizedString(EMERGENCY_CONTACT_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(EMERGENCY_CONTACT_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:EMERGENCY_MENU_ITEM]];
                break;
            case 3:
                menuCell.titleLabel.text = NSLocalizedString(SETTINGS_BUTTON_TEXT, nil);
                menuCell.subTitleLabel.text = NSLocalizedString(SETTINGS_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
                break;
            case 4://pricing
                menuCell.titleLabel.text = NSLocalizedString(PRICING_BUTTON_TEXT, nil);
                menuCell.subTitleLabel.text = NSLocalizedString(PRICING_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:PAYMENT_MENU_ITEM]];
                break;
            case 5:
                menuCell.titleLabel.text = NSLocalizedString(PAIR_DEVICE_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(PAIR_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:LogoutMeneIcon]];
                break;
            /*case 6:
                menuCell.titleLabel.text = NSLocalizedString(UN_PAIR_DEVICE_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(UN_PAIR_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:LogoutMeneIcon]];
                break;
            case 6:
                menuCell.titleLabel.text = NSLocalizedString(SILENT_STREAMING_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(SILENT_STREAMING_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:LogoutMeneIcon]];
                break;*/
            case 6:
                menuCell.titleLabel.text = NSLocalizedString(BATTERY_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(BATTERY_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
                break;
            case 7:
                menuCell.titleLabel.text = NSLocalizedString(LOGOUT_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(LOGOUT_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:LogoutMeneIcon]];
                break;
            default:
                break;
        }
    }else {//Member user
        switch (indexPath.row) {
//            case 0:
//                menuCell.titleLabel.text = NSLocalizedString(SURROUND_HOME_TITLE_TEXT,nil);
//                menuCell.subTitleLabel.text = NSLocalizedString(SURROUND_HOME_SUBTITLE_TEXT,nil);
//                [menuCell.iconImage setImage:[UIImage imageNamed:HomeMeneIcon]];
//                break;
            case 0:
                menuCell.titleLabel.text = NSLocalizedString(PROFILE_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(PROFILE_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:USER_PROFILE]];
                break;
            case 1:
                menuCell.titleLabel.text = NSLocalizedString(EMERGENCY_CONTACT_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(EMERGENCY_CONTACT_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:EMERGENCY_MENU_ITEM]];
                break;
            case 2:
                menuCell.titleLabel.text = NSLocalizedString(SETTINGS_BUTTON_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(SETTINGS_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
                break;
            case 3:
                menuCell.titleLabel.text = NSLocalizedString(PAIR_DEVICE_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(PAIR_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
                break;
            /*case 4:
                menuCell.titleLabel.text = NSLocalizedString(UN_PAIR_DEVICE_BUTTON_TITLE_TEXT,nil);
                menuCell.subTitleLabel.text = NSLocalizedString(UN_PAIR_BUTTON_SUBTITLE_TEXT,nil);
                [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
                break;*/
            case 4:
                 menuCell.titleLabel.text = NSLocalizedString(BATTERY_BUTTON_TITLE_TEXT,nil);
                 menuCell.subTitleLabel.text = NSLocalizedString(BATTERY_BUTTON_SUBTITLE_TEXT,nil);
                 [menuCell.iconImage setImage:[UIImage imageNamed:SETTTINGS_MENU_ITEM]];
              break;
            default:
                break;
        }
    }
    [menuCell.titleLabel setTextColor:[UIColor blackColor]];
    [menuCell.subTitleLabel setTextColor:[UIColor whiteColor]];
    
//    [menuCell.titleLabel setFont:ROBOTOBOLD(18)];//18
//    [menuCell.subTitleLabel setFont:[UIFont systemFontOfSize:10]];
    menuCell.backgroundColor = [UIColor clearColor];
    menuCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return menuCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight <= 568) {
        return 44.0f;
    }
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    newFrontController = nil;
    revealController = self.revealViewController;
    NSInteger row = indexPath.row;
    /*
    if (row == 0) {//---Home---//
        UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
        UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
        if([currentVC isKindOfClass:[HomeViewController class]]){
            [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
        }else {
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
            HomeViewController *homeViewController = [sb instantiateViewControllerWithIdentifier:HOME_VIEW_CONTROLLER_KEY];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
            [revealController pushFrontViewController:newFrontController animated:YES];
        }
        return;
    }else*/
    if (row == 0) {//---UserProfile---//
        UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
        UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
        if([currentVC isKindOfClass:[UpdateProfileViewController class]]){
            [revealController setFrontViewPosition:FrontViewPositionRightMost animated:YES];
        }else {
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
            UpdateProfileViewController *userProfileVC = [sb instantiateViewControllerWithIdentifier:UPDATE_PROFILE_VIEW_CONTROLLER_KEY];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:userProfileVC];
            [revealController pushFrontViewController:newFrontController animated:YES];
        }
        return;
    }else if (row == 1) {//---FamilyMemberList---//
        if ([_modelManager.user.role integerValue] == 1) {
            [self gotoMemberListVC];
        }else {
            [self gotoEmergencyContactVC];
        }
        return;
    }else if (row == 2) {//---EmergencyContact---//
        if ([_modelManager.user.role integerValue] == 1) {
            [self gotoEmergencyContactVC];
            return;
        } else {
            [self gotoUserSettingsVC];
            return;
        }
    }else if (row == 3) {//---Settings---//
        if ([_modelManager.user.role integerValue] == 1) {
            [self gotoUserSettingsVC];
            return;
        }
        else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MemberAddDeviceViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"MemberAddDeviceViewController"];
            addDeviceVC.title = @"Add Device";
            addDeviceVC.isUnPairVc = NO;
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
            [revealController pushFrontViewController:newFrontController animated:YES];
            return;
            /*
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MemberAddDeviceViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"MemberAddDeviceViewController"];
            addDeviceVC.title = @"Unpair Device";
            addDeviceVC.isUnPairVc = NO;
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
            [revealController pushFrontViewController:newFrontController animated:YES];
            return;*/
        }

    }else if (row == 4) {//Pricing
        //---defaultWay---//
        if ([_modelManager.user.role integerValue] == 1) {
            /*
//            NSString *urlStr = [NSString stringWithFormat:@"http://192.168.102.205:5000/#/Payment?userid=%@&token=%@",_modelManager.user.identifier,_modelManager.user.sessionToken];
            NSString *urlStr = [NSString stringWithFormat:@"http://console.surround.family:5000/#/payment?userid=%@&token=%@&lang=%@",_modelManager.user.identifier,_modelManager.user.sessionToken,_modelManager.defaultLanguage];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PaymentViewController *paymentVC = [sb instantiateViewControllerWithIdentifier:@"PaymentViewController"];
            paymentVC.currentURL = urlStr;
            paymentVC.title = NSLocalizedString(@"Account Status", nil);
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:paymentVC];
            [revealController pushFrontViewController:newFrontController animated:YES];
            return;
             */
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             PackagesViewController *packagesViewController = [sb instantiateViewControllerWithIdentifier:@"PackagesViewController"];
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:packagesViewController];
            [revealController pushFrontViewController:newFrontController animated:YES];
            return;
            
        }
        else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BatteryStatusViewController *batteryStatusVC = [sb instantiateViewControllerWithIdentifier:@"BatteryStatusViewController"];
            batteryStatusVC.title = NSLocalizedString(@"Battery Status", nil);
            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
            newFrontController = [[UINavigationController alloc] initWithRootViewController:batteryStatusVC];
            [revealController pushFrontViewController:newFrontController animated:YES];
            return;
        }
//        else {
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            MemberAddDeviceViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"MemberAddDeviceViewController"];
//            addDeviceVC.title = @"Add Device";
//            addDeviceVC.isUnPairVc = YES;
//            [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
//            newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
//            [revealController pushFrontViewController:newFrontController animated:YES];
//            return;
//        }
    } else if(row == 5) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddDeviceViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"AddDeviceViewController"];
        addDeviceVC.title = NSLocalizedString(@"Add Device", nil);
        addDeviceVC.isUnPairVc = NO;
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
        [revealController pushFrontViewController:newFrontController animated:YES];
        return;
    }
    /*else if(row == 6) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddDeviceViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"AddDeviceViewController"];
        addDeviceVC.title = NSLocalizedString(@"Unpair Device", nil);
        addDeviceVC.isUnPairVc = YES;
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
        [revealController pushFrontViewController:newFrontController animated:YES];
        return;
    }
     else if(row == 6) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SilentAudioStreamingViewController *addDeviceVC = [sb instantiateViewControllerWithIdentifier:@"SilentAudioStreamingViewController"];
        addDeviceVC.title = NSLocalizedString(@"Silent Remote Streaming Control",nil);
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:addDeviceVC];
        [revealController pushFrontViewController:newFrontController animated:YES];
        return;
    }*/
    else if(row == 6) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BatteryStatusViewController *batteryStatusVC = [sb instantiateViewControllerWithIdentifier:@"BatteryStatusViewController"];
        batteryStatusVC.title = NSLocalizedString(@"Battery Status", nil);
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        newFrontController = [[UINavigationController alloc] initWithRootViewController:batteryStatusVC];
        [revealController pushFrontViewController:newFrontController animated:YES];
        return;
    }
    else if (row == 7) {
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want to logout?",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Yes",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [navigationArray removeAllObjects];
                                       [self logOutService];
                                    }];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"No",nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                        }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    _presentedRow = row;  // <- store the presented row
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

- (void)logOutService {
    //---Progress HUD---//
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
