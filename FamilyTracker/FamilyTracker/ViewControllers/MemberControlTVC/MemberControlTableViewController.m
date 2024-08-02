//
//  MemberControlTableViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/23/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "MemberControlTableViewController.h"
#import "ModelManager.h"
#import "SettingModel.h"
#import "MemberControlTableViewCell.h"
#import "MemberData.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "HexToRGB.h"

@interface MemberControlTableViewController ()<SignupUpdater,DataUpdater,UITextFieldDelegate> {
    MBProgressHUD *settingUpdateHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    NSMutableArray *newSettings;
    int previousSwitchValue;
    int previousSwitchTag;
}

@property(nonatomic, readwrite) NSMutableArray *settingsList;
@property(nonatomic, readwrite) NSMutableDictionary *guardianSettingsDic;
@property(nonatomic, readwrite) NSMutableDictionary *guardianSettingsDicNew;
@property(nonatomic, readwrite) NSArray *guardianSettingsAllKeys;
@end

@implementation MemberControlTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    previousSwitchValue = -1;
    previousSwitchTag = -1;
    if(([_member.firstName isEqualToString:@""] || _member.firstName == nil) &&
       ([_member.lastName isEqualToString:@""] ||_member.lastName == nil)) {
        self.title = _member.userName;
    } else {
        if ([_member.lastName isEqualToString:@""] || _member.lastName == nil) {
            self.title = [NSString stringWithFormat:@"%@",_member.firstName];
        }else {
            self.title = [NSString stringWithFormat:@"%@ %@",_member.firstName, _member.lastName];
        }
    }
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToMemberList)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Update",nil) style:UIBarButtonItemStylePlain target:self action:@selector(updateSettingService)];
    self.navigationItem.rightBarButtonItem = updateButton;
    _modelManager = [ModelManager sharedInstance];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    newSettings = [NSMutableArray new];
    [self initService];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.settingsList = _modelManager.settings.rows;
    _guardianSettingsDic = [NSMutableDictionary new];
    _guardianSettingsDic = (NSMutableDictionary*)_member.guardianSettings;
    _guardianSettingsAllKeys = [_guardianSettingsDic allKeys];
    [GlobalData sharedInstance].currentVC = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Defined Methods
- (void)backToMemberList {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeSwitch:(UISwitch *)sender{
    if(previousSwitchTag != sender.tag) {
        previousSwitchTag = (int)sender.tag;
        previousSwitchValue = -1;
    }
    if((int)[sender isOn] == previousSwitchValue)
        return;
    if([sender isOn]){
//        NSLog(@"Switch is ON");
        [self memberActiveInactiveMemberService:YES];
        previousSwitchValue = 1;
    } else{
//        NSLog(@"Switch is OFF");
        [self memberActiveInactiveMemberService:NO];
        previousSwitchValue = 0;
    }
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(OK_BUTTON_TITLE_KEY,nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)checkSwitchStatus:(NSString *)settingId {
    for (NSString *idStr in _member.settings) {
        if ([settingId isEqualToString:idStr]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Service Call Method -
- (void)initService {
    //---Initialize Service Call Back Handler---//
    ReplyHandler * handler = [[ReplyHandler alloc]
                               initWithModelManager:_modelManager
                               operator:nil
                               progress:nil
                               signupUpdate:nil
                               addMemberUpdate:nil
                               updateUserUpdate:(id)self
                               settingsUpdate:(id)self
                               loginUpdate:nil
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:nil
                               getLocationUpdate:nil
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:nil 
                               getAlertUpdate:nil
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

- (NSMutableDictionary *)updateGuardianSettingsDic {
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_member.settings];
    _guardianSettingsDicNew = [NSMutableDictionary new];
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
        MemberControlTableViewCell *cell = (MemberControlTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
        NSString *keyStr = [NSString stringWithFormat:@"%ld",(long)cell.controlSwitch.tag];
        
        if (cell.controlSwitch.isOn) {
            [settingDic removeObjectForKey:keyStr];
            [settingDic setValue:@"true" forKey:keyStr];
            [_guardianSettingsDicNew setObject:@"true" forKey:keyStr];
        }else {
            [settingDic removeObjectForKey:keyStr];
            [settingDic setValue:@"false" forKey:keyStr];
            [_guardianSettingsDicNew setObject:@"false" forKey:keyStr];
        }
    }
    
    return settingDic;
}

#pragma mark tableview delegate methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([_member.role intValue] == 2) {
        return _guardianSettingsAllKeys.count + 1;
    } else {
        return _guardianSettingsAllKeys.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberControlTableViewCell *cell = (MemberControlTableViewCell*)[tableView dequeueReusableCellWithIdentifier:MEMBER_CONTROL_CELL_IDENTIFIER_KEY];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:MEMBER_CONTROL_CELL_IDENTIFIER_KEY owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    if((int)indexPath.row != 0) {
        NSString *settingId = @"";
        if ([_member.role intValue] == 1) {
             settingId = _guardianSettingsAllKeys[indexPath.row];
        } else {
            settingId = _guardianSettingsAllKeys[indexPath.row - 1];
        }
        for (SettingModel *settingModel in _settingsList) {
            if ([settingId isEqualToString:settingModel.identifier]) {
                [cell.title setText:settingModel.title[_modelManager.defaultLanguage]];
                [cell.controlSwitch setTag:[settingId intValue]];
                NSString *str = _guardianSettingsDic[settingId];
                BOOL switchVal = (BOOL)[str boolValue];
                if ([settingId isEqualToString:@"1000"] &&
                    _modelManager.members.rows.count <= 2) {
                    [cell.controlSwitch setEnabled:NO];
                }
                [cell.controlSwitch setOn:switchVal];
                break;
            }
        }
        if ( [_member.role intValue] == 1 &&
            [_modelManager.user.guardianId isEqualToString:_member.identifier] &&
            [settingId isEqualToString:@"1000"]) {
            [cell.controlSwitch setEnabled:NO];
        }
//        [cell.controlSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    } else {
        if([_member.role intValue] == 2) {
            if([_member.isActive boolValue]) {
                [cell.title setText:NSLocalizedString(@"Member Active",nil)];
            } else {
                [cell.title setText:NSLocalizedString(@"Member Inactive",nil)];
            }
            [cell.controlSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell.controlSwitch setTag:indexPath.row];
            [cell.controlSwitch setOn:[_member.isActive boolValue]];
        } else {
            NSString *settingId = _guardianSettingsAllKeys[indexPath.row];
            for (SettingModel *settingModel in _settingsList) {
                if ([settingId isEqualToString:settingModel.identifier]) {
                    [cell.title setText:settingModel.title[_modelManager.defaultLanguage]];
                    [cell.controlSwitch setTag:[settingId intValue]];
                    NSString *str = _guardianSettingsDic[settingId];
                    BOOL switchVal = (BOOL)[str boolValue];
                    if ([settingId isEqualToString:@"1000"] &&
                        _modelManager.members.rows.count <= 2) {
                        [cell.controlSwitch setEnabled:NO];
                    }
                    [cell.controlSwitch setOn:switchVal];
                    break;
                }
            }
            if ( [_member.role intValue] == 1 &&
                [_modelManager.user.guardianId isEqualToString:_member.identifier] &&
                [settingId isEqualToString:@"1000"]) {
                [cell.controlSwitch setEnabled:NO];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - Service Call -
- (void)updateSettingService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        settingUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [settingUpdateHud setLabelText:NSLocalizedString(SETTINGS_TEXT,nil)];
        [self.view addSubview:settingUpdateHud];
        [settingUpdateHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_SETTINGS],
                             WHEN_KEY:[NSDate date],
                             OBJ_KEY:@{kIdentifier:_member.identifier,
                                       kGuardianId:_member.guardianId,
                                       kUserName: _member.userName,
                                       kSettings:[self updateGuardianSettingsDic]
                                       }
                             };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)memberActiveInactiveMemberService:(BOOL)status {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    } else {
        settingUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [settingUpdateHud setLabelText:NSLocalizedString(SETTINGS_TEXT,nil)];
        [self.view addSubview:settingUpdateHud];
        [settingUpdateHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ACTIVE_INACTIVE_MEMBER],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kTokenKey:_modelManager.user.sessionToken,
                                         kUser_id_key:_modelManager.user.identifier,
                                           kIdentifier:_member.identifier,
                                           kIsActive:[NSNumber numberWithBool:status]
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Callback -
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [settingUpdateHud hide:YES];
        settingUpdateHud = nil;
        if (success) {
            NSDictionary *responseDic = (NSDictionary*)object;
            _member.settings = responseDic[kSettings];
            _member.guardianSettings = _guardianSettingsDicNew;
            
            [self showAlertMessage:NSLocalizedString(@"Successfully Updated",nil) message:nil];
        }else {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    @try {
                       errorMsg = object[kMessageKey];
                    } @catch (NSException *exception) {
                        errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
                    }
                    
                }else {
                    errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
                }
            }else {
                errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];            
        }
    });
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [settingUpdateHud hide:YES];
        settingUpdateHud = nil;
        if (ACTIVE_INACTIVE_MEMBER_SUCCESS == sourceType) {
            [self showAlertMessage:NSLocalizedString(@"Successfully Updated",nil) message:nil];
        } else if(ACTIVE_INACTIVE_MEMBER_FAILED == sourceType) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey]) {
                    if([object[kMessageKey] isKindOfClass:[NSDictionary class]]) {
                        if(object[kMessageKey][_modelManager.defaultLanguage]) {
                            errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                        } else {
                            errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
                        }
                    } else {
                        errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
                    }
                }else {
                    errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
                }
            }else {
                errorMsg = NSLocalizedString(UPDATE_SETTING_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}


@end
