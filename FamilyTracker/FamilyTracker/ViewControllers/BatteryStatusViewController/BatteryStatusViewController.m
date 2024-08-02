//
//  BatteryStatusViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "BatteryStatusViewController.h"
#import "BatteryStatusTableViewCell.h"
#import "BatteryStatManager.h"
#import "ModelManager.h"
#import "ReplyHandler.h"
#import "ServiceHandler.h"
#import "MBProgressHUD.h"
#import "Common.h"
#import "DeviceStatus.h"


@interface BatteryStatusViewController () <UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate> {
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MBProgressHUD *progressHUD;
    UIRefreshControl *refreshControl;
}

@property (nonatomic, weak) IBOutlet UITableView *tView;
@property (nonatomic, strong) NSMutableArray<DeviceStatus> *deviceStatusArray;

@end

@implementation BatteryStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _modelManager = [ModelManager sharedInstance];
    _deviceStatusArray = _deviceStatusArray = [[NSMutableArray<DeviceStatus> alloc] init];
    _deviceStatusArray = _modelManager.deviceStatusArray;
    if (_modelManager.deviceStatusArray.count < 1) {
        progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [progressHUD setLabelText:NSLocalizedString(LOADING_INFO_TEXT,nil)];
        [self.view addSubview:progressHUD];
        [progressHUD hide:YES afterDelay:10];
        [progressHUD show:YES];
        [self initService];
    } else {
        [self initService];
    }
    //---Add pull to refresh control to top of table view---//
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshUserBatteryList) forControlEvents:UIControlEventValueChanged];
    //---Add Device Charging state change status trigger observer ---//
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BatteryNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryNotification:)
                                                 name:@"BatteryNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalData sharedInstance].currentVC = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {

}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelManager.deviceStatusArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BatteryStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BatteryStatusTableViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BatteryStatusTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    DeviceStatus *deviceStatus = _modelManager.deviceStatusArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userNameLabel.text = [Common getUserName:deviceStatus.userId];
    cell.batteryLevelLabel.text = [NSString stringWithFormat:@"%@%%",deviceStatus.batteryPercent];
    cell.levelConstraint.constant = 0.24*[deviceStatus.batteryPercent intValue];
    [cell.powerImg setHidden:![deviceStatus.isBatteryCharging boolValue]];
    [cell.panicSwitch addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
    cell.panicSwitch.tag = indexPath.row;
    return cell;
}


- (void)setSwitchState:(id)sender {
//    UISwitch *sw = (UISwitch *)sender;
//    NSLog(@"%ld",(long)sw.tag);
//    NSIndexPath *theIndexPath = [NSIndexPath indexPathForRow:sw.tag inSection:0];
//     UITableViewCell *cell = [_tView cellForRowAtIndexPath:theIndexPath];
//    BatteryStatusTableViewCell *cell2 = (BatteryStatusTableViewCell *)cell;
////    BatteryStatusTableViewCell *cell2 = (BatteryStatusTableViewCell *)[_tView cellForRowAtIndexPath:theIndexPath];
//    cell2.levelConstraint.constant = cell2.levelConstraint.constant + 0.24f;
//    cell.levelConstraint.constant = 0.24;
//    BOOL state = [sender isOn];
    if ([sender isOn]) {
        NSLog(@"Switch is ON");
    } else {
        NSLog(@"Switch is OFF");
    }
}

- (void)refreshUserBatteryList {
    [self getDeviceUseageService];
}

#pragma mark - Service Call -
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
                               getAlertUpdate:(id)self
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
    [self getDeviceUseageService];
}

- (void)getDeviceUseageService {
    if (_modelManager.user.sessionToken.length > 0) {
        NSDictionary *requestBody = @{
                                      kTokenKey:_modelManager.user.sessionToken,
                                      kGuardianId:_modelManager.user.guardianId
                                      };
        NSDictionary *requestBody1 = @{
                                       WHAT_KEY:[NSNumber numberWithInt:GET_DEVICE_USEAGES],
                                       WHEN_KEY:[NSDate date],
                                       OBJ_KEY:requestBody
                                       };
        [_serviceHandler onOperate:requestBody1];
    }
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressHUD hide:YES];
        if(sourceType == GET_DEVICE_USEAGES_SUCCESSED) {
            NSLog(@"get device useages successed");
            _deviceStatusArray = _modelManager.deviceStatusArray;
            [refreshControl endRefreshing];
            [_tView reloadData];
        } else if(sourceType == GET_DEVICE_USEAGES_FAILED) {
            NSLog(@"get device useages failed");
        } 
    });
}

#pragma mark - NotificationCenter Methods -
- (void)batteryNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"BatteryNotification"]) {
        [self getDeviceUseageService];
    }
}

@end
