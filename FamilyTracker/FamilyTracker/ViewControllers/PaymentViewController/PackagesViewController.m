//
//  PackagesViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/21/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "PackagesViewController.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "EmergencyContactModel.h"
#import "DbHelper.h"
#import "FamilyTrackerReachibility.h"
#import "GlobalServiceManager.h"
#import "UserPackages.h"
#import "UserPackage.h"
#import "PackAgeCell.h"
#import "Common.h"
#import "PaymentViewController.h"

@interface PackagesViewController ()<DataUpdater> {
    MBProgressHUD *getPackAgesHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    UserPackages *userPackages;
}

@end

@implementation PackagesViewController

- (void)viewDidLoad {
    _modelManager = [ModelManager sharedInstance];
    [super viewDidLoad];
    [self initService];
    self.tView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self getAllPackagesService];
}

#pragma mark - userDefine Methods
- (NSString*)getStringFromEpochTime:(NSString *)epochTime {
    epochTime = [Common getEpochTimeFromServerTime:epochTime];
    NSTimeInterval seconds = [epochTime doubleValue];
    NSDate *epochNSDate = [NSDate dateWithTimeIntervalSince1970:(seconds / 1000)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:epochNSDate];
    return formattedDate;
}

- (void)showAlertTitle:(NSString *)title
           withMessage:(NSString *)message {
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

#pragma mark - Button Action
- (IBAction)upgradeBtnTapped:(id)sender {
   // NSString *urlStr = [NSString stringWithFormat:@"http://192.168.102.205:5000/#/Payment?userid=%@&token=%@",_modelManager.user.identifier,_modelManager.user.sessionToken];
    NSString *urlStr = [NSString stringWithFormat:@"http://console.surround.family:5000/#/payment?userid=%@&token=%@&lang=%@",_modelManager.user.identifier,_modelManager.user.sessionToken,_modelManager.defaultLanguage];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PaymentViewController *paymentVC = [sb instantiateViewControllerWithIdentifier:@"PaymentViewController"];
    paymentVC.currentURL = urlStr;
    paymentVC.title = NSLocalizedString(@"Account Status", nil);
    [self.navigationController pushViewController:paymentVC animated:YES];
}

#pragma mark tableview delegate methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userPackages.resultset count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserPackage *userPackage = [userPackages.resultset objectAtIndex:indexPath.row];
    PackAgeCell *cell = (PackAgeCell*)[tableView dequeueReusableCellWithIdentifier:@"PackageIdentifire"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PackageIdentifire" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSString *period = @"";
    for (NSString *key in userPackage.period) {
        period = key;
        break;
    }
    if([period isEqualToString:@"m"]) {
        period = @"MONTHLY";
    } else if([period isEqualToString:@"q"]) {
        period = @"QUARTERLY";
    }else if([period isEqualToString:@"h"]) {
        period = @"HALFYEARLY";
    }else if([period isEqualToString:@"y"]) {
        period = @"YEARLY";
    }
    cell.packName.text = userPackage.package_name;
    cell.offer.text = [NSString stringWithFormat:@"Offer: %@",period];
    NSString *startDate = [self getStringFromEpochTime:userPackage.start_date];
    NSString *endDate = [self getStringFromEpochTime:userPackage.end_date];
    cell.startDate.text = [NSString stringWithFormat:@"purchased: %@",startDate];
    cell.endDate.text = [NSString stringWithFormat:@"Expiration: %@",endDate];
    cell.price.text = @"Price";
    cell.amount.text = [NSString stringWithFormat:@"%@",userPackage.final_cost];
    if([userPackage.is_active intValue] == 0) {
        [cell.upgradeBtn setHidden:YES];
    } else {
        cell.upgradeBtn.layer.cornerRadius = 10;
        cell.upgradeBtn.layer.masksToBounds = YES;
        [cell.upgradeBtn addTarget:self action:@selector(upgradeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

#pragma mark - Service Call -
- (void)getAllPackagesService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        getPackAgesHud = [[MBProgressHUD alloc] initWithView:self.view];
        [getPackAgesHud setLabelText:NSLocalizedString(@"getting packages",nil)];
        [self.view addSubview:getPackAgesHud];
        [getPackAgesHud show:YES];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_ALL_USER_PACKAGE],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kGuardianId:_modelManager.user.guardianId,
                                           kTokenKey : _modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [getPackAgesHud hide:YES];
        getPackAgesHud = nil;
        if (GET_ALL_USER_PACKAGE_SUCCCEEDED == sourceType) {
            NSError *error = nil;
            userPackages = [[UserPackages alloc] initWithDictionary:object error:&error];
            [_tView reloadData];
        }else if(GET_ALL_USER_PACKAGE_FAILED == sourceType) {
            [self showAlertTitle:nil withMessage:NSLocalizedString(@"Get package fail", nil)];
        }
    });
}

@end
