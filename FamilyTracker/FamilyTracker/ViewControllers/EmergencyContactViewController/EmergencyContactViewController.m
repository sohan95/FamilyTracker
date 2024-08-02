//
//  EmergencyContactViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/6/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "EmergencyContactViewController.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "EmergencyContactModel.h"
#import "DbHelper.h"
#import "FamilyTrackerReachibility.h"
#import "GlobalServiceManager.h"

@interface EmergencyContactViewController ()<DataUpdater> {
    MBProgressHUD *emergencyContactHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property(nonatomic,strong) NSString * contactName;
@property(nonatomic,strong) NSString * contactPhoneNumber;
@end

@implementation EmergencyContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelManager = [ModelManager sharedInstance];
    [self setDefaultView];
    [self initService];
    BOOL isUpdatedContactList = [[NSUserDefaults standardUserDefaults] boolForKey:IS_UPDATED_CONTACTLIST];
    if(!isUpdatedContactList) {
        [[DbHelper sharedInstance] resetSingleTable:k_Db_EmergencyContactTable];
        [self getEmergencyContactService];
    } else {
        [self updateDefaultView];
    }
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
                              updateUserUpdate:(id)self
                              settingsUpdate:nil
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

#pragma mark - User Defined Methods -
-(void)setDefaultView {
    self.title = NSLocalizedString(EMERGENCY_CONTACT_BUTTON_TITLE_TEXT, nil);
    self.emergencyContactImageView1.layer.cornerRadius = self.emergencyContactImageView1.frame.size.width / 2;
    self.emergencyContactImageView1.clipsToBounds = YES;
    self.emergencyContactImageView2.layer.cornerRadius = self.emergencyContactImageView2.frame.size.width / 2;
    self.emergencyContactImageView2.clipsToBounds = YES;
    self.emergencyContactImageView3.layer.cornerRadius = self.emergencyContactImageView3.frame.size.width / 2;
    self.emergencyContactImageView3.clipsToBounds = YES;
    [_addOrRemoveBtn1 setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [_addOrRemoveBtn2 setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [_addOrRemoveBtn3 setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    _emergencyContactNameLbl1.text = NSLocalizedString(@"Mobile",nil);
    _emergencyContactNameLbl2.text = NSLocalizedString(@"Mobile",nil);
    _emergencyContactNameLbl3.text = NSLocalizedString(@"Mobile",nil);
    [_emergencyContactImageView1 setImage:[UIImage imageNamed:@"user_placeholder"]];//User-Profile-Menu-Item
    [_emergencyContactImageView2 setImage:[UIImage imageNamed:@"user_placeholder"]];
    [_emergencyContactImageView3 setImage:[UIImage imageNamed:@"user_placeholder"]];
}

-(void)updateDefaultView {
    [self setDefaultView];
    int totalEmergencyContacts = (int)_modelManager.emergencyContacts.count;
    EmergencyContactModel * emergencyContactModel;
    for(int i= 0; i<totalEmergencyContacts;i++) {
        emergencyContactModel = _modelManager.emergencyContacts[i];
        if([emergencyContactModel.listOrder isEqualToString:@"1"] ) {
            _emergencyContactNameLbl1.text = emergencyContactModel.contactName;
            [_addOrRemoveBtn1 setImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
        } else if([emergencyContactModel.listOrder isEqualToString:@"2"] ) {
            _emergencyContactNameLbl2.text = emergencyContactModel.contactName;
            [_addOrRemoveBtn2 setImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
        }else if([emergencyContactModel.listOrder isEqualToString:@"3"] ) {
            _emergencyContactNameLbl3.text = emergencyContactModel.contactName;
            [_addOrRemoveBtn3 setImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
        }
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

#pragma mark button action event -
- (IBAction)addEmergencyContact:(id)sender {
    UIButton *btn = (UIButton*)sender;
    int buttonIndex = (int)btn.tag;
    BOOL isfound = NO;
    for (EmergencyContactModel * emergencyContact in _modelManager.emergencyContacts) {
        if([emergencyContact.listOrder isEqualToString:[NSString stringWithFormat:@"%d",buttonIndex]]) {
            [self removeEmergencyContactService:emergencyContact];
            isfound = YES;
            break;
        }
    }
    if(!isfound) {
        if(_modelManager.emergencyContacts.count >= 3 ){
            [self showAlertMessage:NSLocalizedString(@"Emergency contacts already add 3 numbers",nil) message:nil];
        }else {
            _emergencyContactToBeAddedIndex = (int)btn.tag;
            NSLog(@"--emergency to add index=%d",_emergencyContactToBeAddedIndex);
            
            if(_modelManager.emergencyContacts.count> _emergencyContactToBeAddedIndex) {
                return;
            }
            CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
            contactPicker.delegate = self;
            NSArray *keysToFetch = @[CNContactGivenNameKey,
                                     CNContactMiddleNameKey,
                                     CNContactPhoneNumbersKey,
                                     CNContactImageDataKey,
                                     CNContactThumbnailImageDataKey,CNContactEmailAddressesKey];
            contactPicker.displayedPropertyKeys = keysToFetch;
            [self presentViewController:contactPicker animated:NO completion:nil];
        }
    }
}

#pragma mark contact picker delegate -
-(void) contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
        NSString * phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
        if( contact.phoneNumbers && phoneNumber.length > 0) {
        NSString * name = contact.givenName;
        _contactName = name;
        NSString * phone = phoneNumber/*[[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"]*/;
         NSString *firstChar = [phone substringToIndex:1];
        if ([firstChar isEqualToString:@"+"]) {
            phone = [phone substringFromIndex:1];
    }
    _contactPhoneNumber = phone;
    NSData * imageNSdata = contact.imageData;
    NSData * imageThumnilNSdata = contact.thumbnailImageData;
    UIImage *contactImage = [UIImage imageWithData:imageNSdata];
    UIImage *thumnil = [UIImage imageWithData:imageThumnilNSdata];
    if(_emergencyContactToBeAddedIndex == 1) {
        [_emergencyContactImageView1 setImage:contactImage];
        _emergencyContactNameLbl1.text = name;
        if(contactImage != nil) {
            [_emergencyContactImageView1 setImage:contactImage];
        } else {
            [_emergencyContactImageView1 setImage:[UIImage imageNamed:@"user_placeholder"]];
        }
    }else if (_emergencyContactToBeAddedIndex == 2) {
        [_emergencyContactImageView2 setImage:thumnil];
        _emergencyContactNameLbl2.text = name;
        if(contactImage != nil) {
            [_emergencyContactImageView2 setImage:contactImage];
        }else {
            [_emergencyContactImageView2 setImage:[UIImage imageNamed:@"user_placeholder"]];
        }
    }else if(_emergencyContactToBeAddedIndex == 3) {
        _emergencyContactNameLbl3.text = name;
        if(contactImage != nil) {
            [_emergencyContactImageView3 setImage:contactImage];
        }else {
            [_emergencyContactImageView3 setImage:[UIImage imageNamed:@"user_placeholder"]];
        }
    }
        // add local db
        NSMutableDictionary *emergencyContactLocalDic = [[NSMutableDictionary alloc] init];
        [emergencyContactLocalDic setValue:[NSString stringWithFormat:@"%d",_emergencyContactToBeAddedIndex] forKey:k_Db_Id];
        [emergencyContactLocalDic setValue:_contactName forKey:k_Db_ContactName];
        [emergencyContactLocalDic setValue:_contactPhoneNumber forKey:k_Db_ContactNumber];
        [emergencyContactLocalDic setValue:@"" forKey:k_Db_ContactNumberServerId];
        [emergencyContactLocalDic setValue:@"" forKey:k_Db_ContactPic];
        [emergencyContactLocalDic setValue:@"0" forKey:k_Db_Status];
        [emergencyContactLocalDic setValue:[NSString stringWithFormat:@"%d",_emergencyContactToBeAddedIndex] forKey:k_Db_List_Order];
        [[DbHelper sharedInstance] insertEmergencyContact:emergencyContactLocalDic];
        if([FamilyTrackerReachibility isUnreachable]) {
            // update offline tracking and update model manager
            NSError *error = nil;
            NSMutableArray * allContactFromSqlite = [[NSMutableArray alloc] init];
            allContactFromSqlite = [[DbHelper sharedInstance] getAllEmergencyContactFromSqlit:@""];
            _modelManager.emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
            NSArray *resultSetDic = allContactFromSqlite;
            for(NSDictionary * dic in resultSetDic) {
                EmergencyContactModel * emergencyContactModel = (EmergencyContactModel*)[[EmergencyContactModel alloc] initWithDictionary:dic error:&error];
                [_modelManager.emergencyContacts addObject:emergencyContactModel];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_OFFLINE_CONTACT_STORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self updateDefaultView];
            
        }else {
            [self addEmergencyContactService];
        }
        
    } else { // phone nubmer is empty
        UIAlertView *trialMessageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:NSLocalizedString(@"Phone nubmer cannot be empty!",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [trialMessageAlert show];
    }
}

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    NSLog(@"Cancelled");
}

#pragma mark - Service Call -
- (void)getEmergencyContactService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(@"getting emergency contact",nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_modelManager.user.identifier,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)addEmergencyContactService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        NSArray * contactArray = [NSArray arrayWithObjects:_contactPhoneNumber, nil];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                           kUserContactName: _contactName,
                                           kUserContact: contactArray,
                                           kListOrder: [NSNumber numberWithInt: _emergencyContactToBeAddedIndex],
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

-(void)removeEmergencyContactService:(EmergencyContactModel *)emergencyContactModel{
    if ([FamilyTrackerReachibility isUnreachable]) {
        if([Common isNullObject:emergencyContactModel.contactId] || emergencyContactModel.contactId.length == 0) {
        } else {
         [[DbHelper sharedInstance] insertRemoveEmergencyContact:emergencyContactModel];
        }
        [[DbHelper sharedInstance] resetSingleTable:k_Db_EmergencyContactTable];
        NSArray *resultSetDic = _modelManager.emergencyContacts;
        NSError *error = nil;
        for(EmergencyContactModel * tempEmergencyContactModel in resultSetDic) {
            if([tempEmergencyContactModel.listOrder isEqualToString:emergencyContactModel.listOrder] && [tempEmergencyContactModel.contactName isEqualToString:emergencyContactModel.contactName] && [tempEmergencyContactModel.contactArray[0] isEqualToString:emergencyContactModel.contactArray[0]]){
            } else {
                NSMutableDictionary *emergencyContactLocalDic = [[NSMutableDictionary alloc] init];
                [emergencyContactLocalDic setValue:[NSString stringWithFormat:@"%d",_emergencyContactToBeAddedIndex] forKey:k_Db_Id];
                [emergencyContactLocalDic setValue:tempEmergencyContactModel.contactName forKey:k_Db_ContactName];
                NSString *contactNumber = tempEmergencyContactModel.contactArray[0];
                [emergencyContactLocalDic setValue:contactNumber forKey:k_Db_ContactNumber];
                if([Common isNullObject:tempEmergencyContactModel.contactId] || tempEmergencyContactModel.contactId.length == 0){
                    [emergencyContactLocalDic setValue:@"" forKey:k_Db_ContactNumberServerId];
                    [emergencyContactLocalDic setValue:@"0" forKey:k_Db_Status];
                } else {
                    [emergencyContactLocalDic setValue:tempEmergencyContactModel.contactId forKey:k_Db_ContactNumberServerId];
                    [emergencyContactLocalDic setValue:@"1" forKey:k_Db_Status];
                }
                [emergencyContactLocalDic setValue:@"" forKey:k_Db_ContactPic];
                [emergencyContactLocalDic setValue:[NSString stringWithFormat:@"%@",tempEmergencyContactModel.listOrder] forKey:k_Db_List_Order];
                [[DbHelper sharedInstance] insertEmergencyContact:emergencyContactLocalDic];
            }
        }
        error = nil;
        NSMutableArray * allContactFromSqlite = [[NSMutableArray alloc] init];
        allContactFromSqlite = [[DbHelper sharedInstance] getAllEmergencyContactFromSqlit:@""];
        _modelManager.emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
       resultSetDic = allContactFromSqlite;
        for(NSDictionary * dic in resultSetDic) {
            EmergencyContactModel * emergencyContactModel = (EmergencyContactModel*)[[EmergencyContactModel alloc] initWithDictionary:dic error:&error];
            [_modelManager.emergencyContacts addObject:emergencyContactModel];
        }
        [self updateDefaultView];
    }else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:REMOVE_EMERGENCY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                           kcontactid:emergencyContactModel.contactId,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [emergencyContactHud hide:YES];
        emergencyContactHud = nil;
        if (ADD_EMERGENCY_SUCCCEEDED == sourceType) {      
            [self showAlertMessage:NSLocalizedString(@"Emergency contact add successfully",nil) message:nil];
            [self getEmergencyContactService];
        }else if(ADD_EMERGENCY_FAILED == sourceType){
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    if(object[kMessageKey][_modelManager.defaultLanguage]) {
                        errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                    }else {
                        errorMsg = UPDATE_SETTING_ERROR;
                    }
                }else {
                    errorMsg = UPDATE_SETTING_ERROR;
                }
            }else {
                errorMsg = UPDATE_SETTING_ERROR;
            }
            [self showAlertMessage:errorMsg message:nil];
        } else if(GET_EMERGENCY_SUCCCEEDED == sourceType) {
            [[DbHelper sharedInstance] resetSingleTable:k_Db_EmergencyContactTable];
            NSError *error = nil;
            _modelManager.emergencyContacts = [[NSMutableArray<EmergencyContactModel> alloc] init];
            NSArray *resultSetDic = [object valueForKey:kResultsetKey];
            for(NSDictionary * dic in resultSetDic) {
                EmergencyContactModel * emergencyContactModel = (EmergencyContactModel*)[[EmergencyContactModel alloc] initWithDictionary:dic error:&error];
                // insert locally data
                [[DbHelper sharedInstance] insertEmergencyContact1:emergencyContactModel];
                [_modelManager.emergencyContacts addObject:emergencyContactModel];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_UPDATED_CONTACTLIST];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self updateDefaultView];
        } else if(GET_EMERGENCY_FAILED == sourceType) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    if(object[kMessageKey][_modelManager.defaultLanguage]) {
                        errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                    }else {
                        errorMsg = NSLocalizedString(@"Get emergency contact fail",nil);
                    }
                }else {
                    errorMsg = NSLocalizedString(@"Get emergency contact fail",nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Get emergency contact fail",nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        } else if(REMOVE_EMERGENCY_SUCCESS == sourceType) {
            [self showAlertMessage:NSLocalizedString(@"Emergency contact remove successfully",nil) message:nil];
            [self getEmergencyContactService];
        } else if(REMOVE_EMERGENCY_FAILED == sourceType) {
        }
    });
}

@end
