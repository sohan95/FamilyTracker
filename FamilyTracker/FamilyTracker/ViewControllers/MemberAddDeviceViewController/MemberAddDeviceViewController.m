//
//  MemberAddDeviceViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "MemberAddDeviceViewController.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"

@interface MemberAddDeviceViewController ()<DataUpdater> {
    MBProgressHUD *addDevicetHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@end

@implementation MemberAddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelManager = [ModelManager sharedInstance];
    [self initService];
    if(_isUnPairVc) {
        [_unPairDeviceView setHidden:NO];
    } else {
        [_unPairDeviceView setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - user define method
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

#pragma mark - button Action
- (IBAction)scannerAction:(id)sender {
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
//            NSLog(@"Completion with result: %@", resultAsString);
        }];
        [self presentViewController:vc animated:YES completion:NULL];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)addCodeAction:(id)sender {
    self.qrCodeTextField.text = [self.qrCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.qrCodeTextField.text isEqualToString:@""] || [self.qrCodeTextField.text isEqual:nil]) {
        [self showAlertMessage:nil message:NSLocalizedString(@"Qr Code Can Not Empty!",nil)];
        return;
    }
    [self addDeviceService];
}

- (IBAction)unPairDeviceAction:(id)sender {
    [self inActiveWatchService];
}

#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QRCodeReader" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        _qrCodeTextField.text = result;
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
                                 OBJ_KEY:@{kWatch_id:_qrCodeTextField.text,
                                           kGuardianId:_modelManager.user.guardianId,
                                           kUser_id_key:_modelManager.user.identifier,
                                           kUserName:_modelManager.user.userName,
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
                                           kUser_id_key:_modelManager.user.identifier,
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
                        errorMsg = NSLocalizedString(@"Add Device Fail",nil);
                    }
                }else {
                    errorMsg = NSLocalizedString(@"Add Device Fail",nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Add Device Fail",nil);
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
