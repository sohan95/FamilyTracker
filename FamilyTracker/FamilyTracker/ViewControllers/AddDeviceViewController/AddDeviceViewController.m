//
//  AddDeviceViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/11/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

@interface AddDeviceViewController ()<DataUpdater> {
    MBProgressHUD *addDevicetHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MemberData *selectedMember;
}
@end

@implementation AddDeviceViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _memberList = [ModelManager sharedInstance].members.rows;
    _modelManager = [ModelManager sharedInstance];
    if ([self.qrTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.qrTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Manually Input QR Id",nil) attributes:@{NSForegroundColorAttributeName: color}];
    }
    [self setDefaultView];
    [self initService];
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

#pragma mark - user Define Method
- (void)setDefaultView {
    [_dropDownView setHidden:YES];
    [self inVisiblePermission:YES];
    if(_isUnPairVc) {
        [_unPairView setHidden:NO];
        [self.view bringSubviewToFront:_unPairView];
        [_dropDownViewForUnPair setHidden:YES];
    } else {
        [_unPairView setHidden:YES];
    }
}

-(void)inVisiblePermission:(BOOL)value{
    [_scannerBtOutlet setHidden:value];
    [_qrTextField setHidden:value];
    [_addDeviceButtonOutlet setHidden:value];
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

#pragma mark - ButtonAction
- (IBAction)scannnerBtAction:(id)sender {
    _qrTextField.text = @"";
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
}
- (IBAction)addButtonAction:(id)sender {
    self.qrTextField.text = [self.qrTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.qrTextField.text isEqualToString:@""] || [self.qrTextField.text isEqual:nil]) {
        [self showAlertMessage:nil message:NSLocalizedString(@"Qr Code Can Not Empty!", nil)];
        return;
    }
    [self addDeviceService];                                                                                                                      
}
- (IBAction)memberSelectAction:(id)sender {
    _qrTextField.text = @"";
    if([_dropDownView isHidden]) {
        [_dropDownView setHidden:NO];
        [_dropDownViewForUnPair setHidden:NO];
    } else {
        [_dropDownView setHidden:YES];
         [_dropDownViewForUnPair setHidden:YES];
    }
}

- (IBAction)unPairAction:(id)sender {
    [self inActiveWatchService];
}

#pragma mark tableview delegate methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return _memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    MemberData *member = [_memberList objectAtIndex:indexPath.row];
    NSString *fullName = @"";
    if(([Common isNullObject:member.firstName] || member.firstName.length<1) && ([Common isNullObject:member.lastName] || member.lastName.length<1)) {
        fullName = member.userName;
    }else {
        if ([Common isNullObject:member.lastName] || member.lastName.length<1) {
            fullName = [NSString stringWithFormat:@"%@",member.firstName];
        }else {
            fullName = [NSString stringWithFormat:@"%@ %@",member.firstName, member.lastName];
        }
    }
    cell.textLabel.text = fullName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_dropDownView setHidden:YES];
    [_dropDownViewForUnPair setHidden:YES];
    selectedMember = [_memberList objectAtIndex:indexPath.row];
    NSString *fullName = @"";
    if(([Common isNullObject:selectedMember.firstName] || selectedMember.firstName.length<1) && ([Common isNullObject:selectedMember.lastName] || selectedMember.lastName.length<1)) {
        fullName = selectedMember.userName;
    }else {
        if ([Common isNullObject:selectedMember.lastName] || selectedMember.lastName.length<1) {
            fullName = [NSString stringWithFormat:@"%@",selectedMember.firstName];
        }else {
            fullName = [NSString stringWithFormat:@"%@ %@",selectedMember.firstName, selectedMember.lastName];
        }
    }
    [_memberSelectButtonOutlet setTitle:fullName forState:UIControlStateNormal];
    [self inVisiblePermission:NO];
}


#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QRCodeReader" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        _qrTextField.text = result;
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - service call
- (void)addDeviceService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        addDevicetHud = [[MBProgressHUD alloc] initWithView:self.view];
        [addDevicetHud setLabelText:NSLocalizedString(@"Add Device",nil)];
        [self.view addSubview:addDevicetHud];
        [addDevicetHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_USER_WATCH],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kWatch_id:_qrTextField.text,
                                           kGuardianId:_modelManager.user.guardianId,
                                         kUser_id_key:selectedMember.identifier,
                                           kUserName:selectedMember.userName,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

-(void)inActiveWatchService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        addDevicetHud = [[MBProgressHUD alloc] initWithView:self.view];
        [addDevicetHud setLabelText:NSLocalizedString(@"Unpair Device",nil)];
        [self.view addSubview:addDevicetHud];
        [addDevicetHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:INACTIVE_USER_WATCH],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kWatch_id:@"",//now watch_id is not found
                                           kGuardianId:_modelManager.user.guardianId,
                                           kUser_id_key:selectedMember.identifier,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [addDevicetHud hide:YES];
        addDevicetHud = nil;
        if (ADD_USER_WATCH_SUCCCEEDED == sourceType) {
            [self showAlertMessage:nil message:NSLocalizedString(@"Add Device Successfully", nil)];
        } else if(ADD_USER_WATCH_FAILED == sourceType) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    if(object[kMessageKey][_modelManager.defaultLanguage]) {
                        errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                    }else {
                        errorMsg = NSLocalizedString(@"Add Device Fail", nil);
                    }
                }else {
                    errorMsg = NSLocalizedString(@"Add Device Fail", nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Add Device Fail", nil);
            }
            [self showAlertMessage:errorMsg message:nil];
            
        } else if(sourceType == INACTIVE_USER_WATCH_SUCCCEEDED) {
            [self showAlertMessage:nil message:NSLocalizedString(@"Unpair Device Successfully", nil)];
        } else if(sourceType == INACTIVE_USER_WATCH_FAILED) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey]) {
                    if(object[kMessageKey][_modelManager.defaultLanguage]) {
                        errorMsg = object[kMessageKey][_modelManager.defaultLanguage];
                    }else {
                        errorMsg = NSLocalizedString(@"Unpair Device Fail",nil);
                    }
                }else {
                    errorMsg = NSLocalizedString(@"Unpair Device Fail",nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Unpair Device Fail",nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

@end
