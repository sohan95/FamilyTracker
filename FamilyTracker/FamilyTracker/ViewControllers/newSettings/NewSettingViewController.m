//
//  NewSettingViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/9/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "NewSettingViewController.h"
#import "UserSettingCell.h"
#import "UserSettingSwitchCell.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "HexToRGB.h"
#import "PopUpCell.h"
#import "SettingModel.h"
#import "ChangePasswordViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface NewSettingViewController ()<SignupUpdater,UIGestureRecognizerDelegate> {
    MBProgressHUD *settingUpdateHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}

@property (weak, nonatomic) IBOutlet UITableView *popUpTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popUpTableViewHeight;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property(nonatomic) int currentTableViewRowNumber;
@property(nonatomic, readwrite) NSArray *userSettingsAllKeys;
@property(nonatomic, readwrite) NSMutableDictionary *userSettingsDic;
@property(nonatomic, readwrite) NSMutableArray *settingsList;
@property(nonatomic, readwrite) NSMutableDictionary *userSettingsDicNew;
@property (weak, nonatomic) IBOutlet UILabel *popUpTableTitle;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *addButtonInputView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonInputView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldInputView;
- (IBAction)popUpViewCancelAction:(id)sender;
- (IBAction)inputViewAddAction:(id)sender;
- (IBAction)inputViewCancelAction:(id)sender;
@end

@implementation NewSettingViewController {
    NSArray *subTableData;
    NSString *bottomTableRowIdentifier;
    NSArray * settingValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelManager = [ModelManager sharedInstance];
    self.title = NSLocalizedString(SETTINGS_BUTTON_TEXT,nil);
    _popUpView.layer.cornerRadius = 5.0;
    _popUpView.layer.borderWidth = 2.0;
    _popUpView.layer.borderColor = [HexToRGB colorForHex:@"FFFFFF"].CGColor;
    _popUpView.layer.masksToBounds = NO;
    _popUpView.layer.shadowRadius = 10;
    _popUpView.layer.shadowOpacity = 0.5;
    _popUpView.layer.shadowOffset = CGSizeMake(15, 20);
    _inputView.layer.cornerRadius = 5.0;
    _inputView.layer.borderWidth = 2.0;
    _inputView.layer.borderColor = [HexToRGB colorForHex:@"FFFFFF"].CGColor;
    _inputView.layer.masksToBounds = NO;
    _inputView.layer.shadowRadius = 10;
    _inputView.layer.shadowOpacity = 0.5;
    _inputView.layer.shadowOffset = CGSizeMake(15, 20);
    //--round inputview add button---
    self.addButtonInputView.layer.cornerRadius = 20;
    self.addButtonInputView.layer.masksToBounds = YES;
    //---round inputview cancel button---
    self.cancelButtonInputView.layer.cornerRadius = 20;
    self.cancelButtonInputView.layer.masksToBounds = YES;
    UITapGestureRecognizer *tranperentViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseBtnAction:)];
    [tranperentViewTap setDelegate:self];
    [self.transperentView addGestureRecognizer:tranperentViewTap];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initService];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_transperentView setHidden:YES];
    self.settingsList = _modelManager.settings.rows;
    _userSettingsDic = [[NSMutableDictionary alloc] init];
    _userSettingsDic = (NSMutableDictionary*)[ModelManager sharedInstance].user.userSettings;
    _userSettingsAllKeys = [_userSettingsDic allKeys];
    _currentTableViewRowNumber = (int)_userSettingsAllKeys.count;
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
                              updateUserUpdate:nil
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

#pragma mark tableview delegate methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView) {
        return _currentTableViewRowNumber;
    } else {
        return _currentTableViewRowNumber;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView) {
        NSString *settingId = _userSettingsAllKeys[indexPath.row];
        if ([settingId isEqualToString:@"1006"]) {//SMS
            UserSettingSwitchCell *cell = (UserSettingSwitchCell*)[tableView dequeueReusableCellWithIdentifier:@"UserSettingSwitchCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserSettingSwitchCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            NSString *settingId = _userSettingsAllKeys[indexPath.row];
            for (SettingModel *settingModel in _settingsList) {
                if ([settingId isEqualToString:settingModel.identifier]) {
                    [cell.label setText:settingModel.title[_modelManager.defaultLanguage]];
                    NSString * type = _userSettingsDic[settingId];
                    [cell.controlSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
                    if ([type isEqualToString:@"Email"]) {
                        [cell.controlSwitch setOn:0];
                    } else {
                        [cell.controlSwitch setOn:1];
                    }
                    break;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else {
            UserSettingCell *cell = (UserSettingCell *)[tableView dequeueReusableCellWithIdentifier:@"UserSettingCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserSettingCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            NSString *settingId = _userSettingsAllKeys[indexPath.row];
            for (SettingModel *settingModel in _settingsList) {
                if ([settingId isEqualToString:settingModel.identifier]) {
                    [cell.title setTag:[settingId intValue]];
                    [cell.title setText:settingModel.title[_modelManager.defaultLanguage]];
                    [cell.subTitle setText:_userSettingsDic[settingId]];
                    break;
                }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        }
    } else {
        PopUpCell *cell = (PopUpCell*)[tableView dequeueReusableCellWithIdentifier:@"PopUpCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopUpCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.cellSubText.text = subTableData[indexPath.row];
        if([_userSettingsDic[bottomTableRowIdentifier] isEqual:subTableData[indexPath.row]]) {
            [cell.radioButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
        }else {
            [cell.radioButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        }
        cell.radioButton.tag = indexPath.row;
        [cell.radioButton addTarget:self action:@selector(panicCountDownTap:)  forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView) {
         return 60.0f;
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView) {
        NSString *settingId = _userSettingsAllKeys[indexPath.row];
        if([settingId isEqualToString:@"1004"]){
             [_transperentView setHidden:NO];
            [_popUpView setHidden:YES];
            [_inputView setHidden:NO];
            NSString *settingId = _userSettingsAllKeys[indexPath.row];
            for (SettingModel *settingModel in _settingsList) {
                if ([settingId isEqualToString:settingModel.identifier]) {
                    NSString * value =  _userSettingsDic[settingId];
                    [_textFieldInputView setText:value];
                    break;
                }
            }
            [self fadeIn:_inputView];
        } else if([settingId isEqualToString:@"1006"]) {
            return;
        } else if([settingId isEqualToString:@"1005"]) {
             [_transperentView setHidden:NO];
            [_popUpView setHidden:NO];
            [_inputView setHidden:YES];
            _userSettingsDic = (NSMutableDictionary*)[ModelManager sharedInstance].user.userSettings;
            subTableData = [[NSArray alloc] init];
            NSString *settingId = _userSettingsAllKeys[indexPath.row];
            for (SettingModel *settingModel in _settingsList) {
                if ([settingId isEqualToString:settingModel.identifier]) {
                    subTableData = settingModel.settingValue;
                    _popUpTableTitle.text = settingModel.title[_modelManager.defaultLanguage];
                    break;
                }
            }
            _currentTableViewRowNumber = (int)subTableData.count;
            bottomTableRowIdentifier = settingId;
            _popUpTableViewHeight.constant = 75.0f + (_currentTableViewRowNumber*44.0f);
            [_popUpTableView reloadData];
            [self fadeIn:_popUpView];
        }
    } else {
    }
}

#pragma - mark Button Action -
- (IBAction)popUpViewCancelAction:(id)sender {
    _currentTableViewRowNumber = (int)_userSettingsDic.count;
    [_tableView reloadData];
    NSMutableDictionary * userPreviousSettingsDic = [[NSMutableDictionary alloc] init];
    userPreviousSettingsDic =(NSMutableDictionary*)[ModelManager sharedInstance].user.userSettings;
    bool changeFound = NO;
    for(NSString * key in [userPreviousSettingsDic allKeys]) {
        if(![[userPreviousSettingsDic valueForKey:key] isEqual: [_userSettingsDic valueForKey:key]]) {
            changeFound = YES;
            break;
        }
    }
    if(changeFound) {
        NSMutableDictionary * dictionary;
        dictionary = [[NSMutableDictionary alloc] init];
        dictionary = [self updateMemberSettingsDic];
        if([self checkPanicTypeBothNo:dictionary]) {
            return;
        }
        [self updateSettingService:nil];
    }
    [self fadeOut:_popUpView];
}

- (IBAction)panicCountDownTap:(id)sender{
    UIButton *btn = (UIButton*)sender;
    NSMutableDictionary * tempDic = [[NSMutableDictionary alloc] init];
    for(NSString *key in [_userSettingsDic allKeys]) {
        if([key isEqual:bottomTableRowIdentifier]) {
            [tempDic setValue:subTableData[(int)btn.tag] forKey:key];
        } else {
            [tempDic setValue:[_userSettingsDic objectForKey:key] forKey:key];
        }
    }
    _userSettingsDic = [[NSMutableDictionary alloc] init];
    _userSettingsDic = tempDic;
    tempDic = nil;
     [_popUpTableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_popUpView]  || [touch.view isDescendantOfView:_inputView]) {
        return NO;
    }
    return YES;
}

- (IBAction)CloseBtnAction:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    if(![view isEqual:_transperentView]) {
        return;
    }
    if([_inputView isHidden]) {
        [self fadeOut:_popUpView];
    } else {
        [self fadeOut:_inputView];
    }
    _currentTableViewRowNumber = (int)_userSettingsDic.count;
    [_tableView reloadData];
}

- (IBAction)inputViewAddAction:(id)sender {
    _currentTableViewRowNumber = (int)_userSettingsDic.count;
    [_tableView reloadData];
    [self fadeOut:_inputView];
    // service call
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.settings];
    _userSettingsDicNew = [NSMutableDictionary new];
    for(NSString *key in [settingDic allKeys]) {
        if([key isEqualToString:@"1004"]) {
            [_userSettingsDicNew setValue:_textFieldInputView.text forKey:key];
        } else {
            [_userSettingsDicNew setValue:[settingDic valueForKey:key] forKey:key];
        }
    }
    [self updateSettingService:_userSettingsDicNew];
    
}

- (IBAction)inputViewCancelAction:(id)sender {
    [self fadeOut:_inputView];
    _currentTableViewRowNumber = (int)_userSettingsDic.count;
    [_tableView reloadData];
}

#pragma - mark User define methods -
- (NSMutableDictionary *)updateMemberSettingsDic {
    NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.settings];
    _userSettingsDicNew = [NSMutableDictionary new];
    for(NSString *key in [settingDic allKeys]) {
        bool found = NO;
        for(NSString * key2 in [_userSettingsDic allKeys]) {
            if([key isEqual:key2] ){
                found = YES;
                [_userSettingsDicNew setValue:[_userSettingsDic valueForKey:key2] forKey:key];
                break;
            }
        }
        if(!found) {
            [_userSettingsDicNew setValue:[settingDic valueForKey:key] forKey:key];
        }
    }
    return _userSettingsDicNew;
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

- (void)changeSwitch:(UISwitch *)sender{
    if([sender isOn]){
        NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.settings];
        _userSettingsDicNew = [NSMutableDictionary new];
        for(NSString *key in [settingDic allKeys]) {
            if([key isEqualToString:@"1006"]) {
                [_userSettingsDicNew setValue:@"SMS" forKey:key];
            } else {
                [_userSettingsDicNew setValue:[settingDic valueForKey:key] forKey:key];
            }
        }
        [self updateSettingService:_userSettingsDicNew];
        
    } else{
        NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.settings];
        _userSettingsDicNew = [NSMutableDictionary new];
        for(NSString *key in [settingDic allKeys]) {
            if([key isEqualToString:@"1006"]) {
                [_userSettingsDicNew setValue:@"Email" forKey:key];
            } else {
                [_userSettingsDicNew setValue:[settingDic valueForKey:key] forKey:key];
            }
        }
        
        if([self checkPanicTypeBothNo:_userSettingsDicNew]) {
            return;
        }
        [self updateSettingService:_userSettingsDicNew];
    }
}

- (void)fadeIn:(UIView *)popUpView {
    popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    popUpView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        popUpView.alpha = 1;
        popUpView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut:(UIView *)popUpView
{
    [UIView animateWithDuration:.35 animations:^{
        popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_transperentView setHidden:YES];
        }
    }];
}

-(BOOL)checkPanicTypeBothNo:(NSMutableDictionary *)dictionary {
    if([[dictionary valueForKey:@"1006"] isEqualToString:@"Email"]  && [[dictionary valueForKey:@"1005"] isEqualToString:@"None"]) {
        [self showAlertMessage:nil message:NSLocalizedString(@"Send SMS when pressing alert and panic resource type both can not be none",nil)];
        [self fadeOut:_popUpView];
        self.settingsList = _modelManager.settings.rows;
        _userSettingsDic = [[NSMutableDictionary alloc] init];
        _userSettingsDic = (NSMutableDictionary*)[ModelManager sharedInstance].user.userSettings;
        _userSettingsAllKeys = [_userSettingsDic allKeys];
        _currentTableViewRowNumber = (int)_userSettingsAllKeys.count;
        [_tableView reloadData];
        return YES;
    }
    return NO;
}

#pragma mark - Service Call -
- (void)updateSettingService:(NSMutableDictionary *)dic{
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        settingUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [settingUpdateHud setLabelText:NSLocalizedString(SETTINGS_TEXT,nil)];
        [self.view addSubview:settingUpdateHud];
        [settingUpdateHud show:YES];
        NSMutableDictionary * newSettingDic;
        if(dic == nil) {
            newSettingDic = [self updateMemberSettingsDic];
        } else {
            newSettingDic = dic;
        }
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_SETTINGS],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kIdentifier:_modelManager.user.identifier,
                                           kGuardianId:_modelManager.user.guardianId,
                                           kUserName: _modelManager.user.userName,
                                           kSettings:newSettingDic
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
            _modelManager.user.settings = responseDic[kSettings];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            for(NSString * key in [_userSettingsDic allKeys]) {
                [dic setValue:[_modelManager.user.settings valueForKey:key] forKey:key];
            }
            _userSettingsDic = nil;
            _userSettingsDic = dic;
            _modelManager.user.userSettings = dic;
            [_tableView reloadData];
            [self showAlertMessage:NSLocalizedString(@"Successfully Updated",nil) message:nil];
            
        }else {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    errorMsg = object[kMessageKey];
                }else {
                    errorMsg = UPDATE_SETTING_ERROR;
                }
            }else {
                errorMsg = UPDATE_SETTING_ERROR;
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
