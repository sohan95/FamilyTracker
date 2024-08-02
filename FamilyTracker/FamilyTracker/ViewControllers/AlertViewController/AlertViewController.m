 //
//  AlertViewController.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 10/7/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "AlertViewController.h"
#import "AppDelegate.h"
#import "Notification.h"
#import "AlertTableViewCell.h"
#import "JsonUtil.h"
#import "FamilyTrackerDefine.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "FamilyTrackerReachibility.h"
#import "GlobalServiceManager.h"
#import "AudioPlayerVC.h"
#import "StreamingVC.h"
#import "HexToRGB.h"
#import "Common.h"

#define UNSEEN_ROW_BACKGROUND @"#66CCFF" //@"#95B9C7"//#306EFF
#define SEEN_ROW_BACKGROUND @"#F1F8F0" //@"#95B9C7"//#306EFF

@interface AlertViewController ()<UITableViewDataSource,UITableViewDelegate> {
    AppDelegate *appDelegate;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}

@property(nonatomic, strong) IBOutlet UITableView *tView;
- (void)backToHomeFromNoti;

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //---SetBackButton on NavigationBar---//
    self.title = NSLocalizedString(NOTIFICATION_PAGE_TITLE_KEY,nil);
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHomeFromNoti)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    leftBarBtnItem = nil;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _tView.backgroundColor = [UIColor whiteColor];
    self.tView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _modelManager = [ModelManager sharedInstance];
    //---Recheck for get alerts ---//
    [self setFilteredAlerts];
    [self initService];
    //---Add pull to refresh control to top of table view---//
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshAlertList) forControlEvents:UIControlEventValueChanged];
    //---Pull to load more data on scroll control---//
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f width:width tableView:self.tView withClient:self];
    alertsHud = [[MBProgressHUD alloc] initWithView:self.view];
    [alertsHud setLabelText:NSLocalizedString(@"Loading Alerts...",nil)];
    [self.tView addSubview:alertsHud];
    if ([FamilyTrackerReachibility isReachable]) {
        if (_allAlertList.count == 0) {
            [alertsHud show:YES];
        }
        if ([GlobalData sharedInstance]._allAlertFullList) {
//            [[GlobalData sharedInstance]._allAlertFullList.rows removeAllObjects];
            [GlobalData sharedInstance]._allAlertFullList = nil;
        }
        [self performSelector:@selector(loadAlertsServiceWithoutPaging) withObject:nil afterDelay:0.5];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
    [self.tView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_pullToRefreshManager relocatePullToRefreshView];
}

#pragma mark - User Defined Methods -
- (void)backToHomeFromNoti {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshAlertList {
    if ([GlobalData sharedInstance]._allAlertFullList) {
        //[[GlobalData sharedInstance]._allAlertFullList.rows removeAllObjects];
        [GlobalData sharedInstance]._allAlertFullList = nil;
    }
    [self loadAlertsServiceWithoutPaging];
}

#pragma mark - PopUpViewNotification Call Method -
- (void)playSelectedStreamUrl:(NSInteger)section andRow:(NSInteger)row {
    Notification *notiAlert = [_modelManager.notifications.rows objectAtIndex:row];
    //--Call UpdateService for ReadStatus---//
    if ([notiAlert.isSeen integerValue] != 1) {
        notiAlert.isSeen = [NSNumber numberWithInt:1];
        [[GlobalServiceManager sharedInstance] acknowledgedReadAlertService:notiAlert.identifier];
    }
    //--End Call UpdateService for ReadStatus---//
    if ([notiAlert.alertType isEqualToString:kAlert_type_panic] ||
        [notiAlert.alertType isEqualToString:kAlert_type_videoStreaming] ||
        [notiAlert.alertType isEqualToString:kAlert_type_audioStreaming]) {
        //Check Streaming contentType---//
        NSString *contentType = notiAlert.link;
        contentType = [contentType substringToIndex:4];
        if ([contentType isEqualToString:@"http"]) {
            //---Play audio---
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AudioPlayerVC *audioStreamingVC = [sb instantiateViewControllerWithIdentifier:@"AudioPlayerVC"];
            audioStreamingVC.url = [NSURL URLWithString:(NSString* )notiAlert.link];
            audioStreamingVC.alertId = notiAlert.identifier;
            [self.navigationController pushViewController:audioStreamingVC animated:YES];
        }else {
            //--Play Video ---//
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
            StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
            streamingVC.myTagValue = 0;
            streamingVC.url = [NSURL URLWithString:(NSString* )notiAlert.link];
            streamingVC.isONVIFPlayer = NO;
            streamingVC.xAddr = @"";
            streamingVC.username = @"";
            streamingVC.password = @"";
            streamingVC.ptzProfileToken = @"";
            streamingVC.isCameraPTZCapable = NO;
            streamingVC.isShowPTZView = NO;
            [self.navigationController pushViewController:streamingVC animated:YES];
        }
    }
}

#pragma mark - TableView Delegate and Methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAlertTableCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allAlertList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AlertTableViewCell";
    AlertTableViewCell *cell = (AlertTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AlertTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //---Check LiveStatus and set Status-Image---//
    Notification *notiAlert = [_allAlertList objectAtIndex:indexPath.row];

    if([Common isNullObject:notiAlert.link]) {
        [cell.liveImageView setImage:[UIImage imageNamed:@"tick_off"]];
    } else {
        [cell.liveImageView setImage:[UIImage imageNamed:@"tick_on"]];
    }
    //---check alertType and set type image
    @try {
        if([notiAlert.alertType isEqualToString:kAlert_type_panic] || [notiAlert.alertType isEqualToString:kAlert_type_stop]) {
            [cell.alertIcon setImage:[UIImage imageNamed:@"notificationIcon"]];
        }else if([notiAlert.alertType isEqualToString:kAlert_type_audioStreaming]) {
            [cell.alertIcon setImage:[UIImage imageNamed:@"AudioStreamIcon"]];
        }else if([notiAlert.alertType isEqualToString:kAlert_type_videoStreaming]) {
            [cell.alertIcon setImage:[UIImage imageNamed:@"VideoStreamBtn"]];
        }else if([notiAlert.alertType isEqualToString:kAlert_type_bounday_touched]) {
            [cell.alertIcon setImage:[UIImage imageNamed:@"Boundary-Icon"]];
        }else {
            [cell.alertIcon setImage:[UIImage imageNamed:@"notificationIcon"]];
        }
    } @catch (NSException *exception) {
    }
    //--- set notiAlertTitle ---//
    if ([Common isNullObject:notiAlert.referenceId] ||
        notiAlert.referenceId.length < 1) {
        //---Set AlertTitle based on device language---//
        NSString * nameWhoSendAlert = @"";
        NSString * messageTitle = @"";

        //---isolet who set alert---//
        if ([Common isNullObject:notiAlert.messageTitle[_modelManager.defaultLanguage]]) {
            
        } else {
            nameWhoSendAlert = [Common getUserName:notiAlert.createdUser];
        }
        
        //---concate whoSent & msgTitle without epochtime---//
        if ([Common isNullObject:[self getStringFromEpochTime:notiAlert.createdTime]]) {
            @try {
                messageTitle = [NSString stringWithFormat:@"%@ %@",nameWhoSendAlert,notiAlert.messageTitle[_modelManager.defaultLanguage]];
                cell.alertTitle.text = messageTitle;
            } @catch (NSException *exception) {
                cell.alertTitle.text = @"";
            } 
            
        } else {//---concate whoSent & msgTitle with epochtime---//
            @try {
                NSString *atString = NSLocalizedString(@"at", nil);
                messageTitle = [NSString stringWithFormat:@"%@ %@ %@ %@",
                                nameWhoSendAlert,notiAlert.messageTitle[_modelManager.defaultLanguage],
                                atString,
                                [self getStringFromEpochTime:notiAlert.createdTime]];
                cell.alertTitle.text = messageTitle;
            } @catch (NSException *exception) {
                cell.alertTitle.text = @"";
            }
        }
    } else {
        @try {
            if ([Common isNullObject:notiAlert.messageTitle[_modelManager.defaultLanguage]]) {
                cell.alertTitle.text = @"";
            } else {
                if([notiAlert.alertType isEqualToString:kAlert_type_audioStreamingStop]) {
                    NSString *nameWhoSendAlert = @"";
                    nameWhoSendAlert = [Common getUserName:notiAlert.createdUser];
                    cell.alertTitle.text = [NSString stringWithFormat:@"%@ %@",nameWhoSendAlert,notiAlert.messageTitle[_modelManager.defaultLanguage]];
                } else {
                cell.alertTitle.text = notiAlert.messageTitle[_modelManager.defaultLanguage];
                }
                
            }
        } @catch (NSException *exception) {
            cell.alertTitle.text = @"";
        }
    }
    
    //---set notiAlert read/unread---//
    if([notiAlert.isSeen integerValue] != 1) {
        cell.backgroundColor = [HexToRGB colorForHex:UNSEEN_ROW_BACKGROUND];
    }else {
        cell.backgroundColor = [HexToRGB colorForHex:SEEN_ROW_BACKGROUND];//
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Notification *notiAlert = (Notification*)[_allAlertList objectAtIndex:indexPath.row];
    //--- Call UpdateService for ReadStatus ---//
    if ([notiAlert.isSeen integerValue] != 1) {
        notiAlert.isSeen = [NSNumber numberWithInt:1];
        [[GlobalServiceManager sharedInstance] acknowledgedReadAlertService:notiAlert.identifier];
    }
    //---Playable check---//
    if ([Common isNullObject:notiAlert.link] ||
        notiAlert.link.length <= 0) {
        if ([Common isNullObject:notiAlert.messageTitle[_modelManager.defaultLanguage]]) {
            
        }else {
//            [Common displayToast:notiAlert.messageTitle[_modelManager.defaultLanguage] title:@"" duration:2.0];
        }
        
    }else if ([notiAlert.alertType isEqualToString:kAlert_type_panic] ||
            [notiAlert.alertType isEqualToString:kAlert_type_videoStreaming] ||
            [notiAlert.alertType isEqualToString:kAlert_type_audioStreaming]) {
        //Check Streaming contentType---//
        NSString *contentType = notiAlert.link;
        contentType = [contentType substringToIndex:4];
        if ([contentType isEqualToString:@"http"]) {
            //---Play audio---
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AudioPlayerVC *audioStreamingVC = [sb instantiateViewControllerWithIdentifier:@"AudioPlayerVC"];
            audioStreamingVC.url = [NSURL URLWithString:(NSString* )notiAlert.link];
            audioStreamingVC.alertId = notiAlert.identifier;
            [self.navigationController pushViewController:audioStreamingVC animated:YES];
        }else {
            //--Play Video ---//
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
            StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
            streamingVC.myTagValue = 0;
            streamingVC.url = [NSURL URLWithString:(NSString* )notiAlert.link];
            streamingVC.isONVIFPlayer = NO;
            streamingVC.xAddr = @"";
            streamingVC.username = @"";
            streamingVC.password = @"";
            streamingVC.ptzProfileToken = @"";
            streamingVC.isCameraPTZCapable = NO;
            streamingVC.isShowPTZView = NO;
            [self.navigationController pushViewController:streamingVC animated:YES];
        }
    }
    [_tView reloadData];
}

#pragma mark - MNMBottomPullToRefreshManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([FamilyTrackerReachibility isReachable]) {
        [_pullToRefreshManager tableViewScrolled];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if([FamilyTrackerReachibility isReachable]) {
        [_pullToRefreshManager tableViewReleased];
    }
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    //[self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
    if ([FamilyTrackerReachibility isReachable]) {
        if (_modelManager.nextPageForAlert.length > 0) {
            [self performSelector:@selector(loadAlertsServiceWithPaging:) withObject:_modelManager.nextPageForAlert afterDelay:0.5];
        } else {
            [self performSelector:@selector(hideBottomRefreshBar) withObject:nil afterDelay:0.5];
        }
    } else {
        [self performSelector:@selector(hideBottomRefreshBar) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - Service Call Methods -
- (void)initService {
    //---Initialize Service CallBack Handler---//
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
                               saveAlertUpdate:nil
                               getAlertUpdate:(id)self
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}

-(void)hideBottomRefreshBar{
    [refreshControl endRefreshing];
    [self.tView reloadData];
    [_pullToRefreshManager tableViewReloadFinished];
}

- (void)loadAlertsServiceWithPaging:(NSString *)nextPage {
    NSString *guardianId = [NSString new];
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestHeader = @{kFamily_id_key:guardianId,
                          kUser_id_key:_modelManager.user.identifier,
                          kTokenKey:_modelManager.user.sessionToken,
                          kNextPage_key:_modelManager.nextPageForAlert};
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_ALERTS],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestHeader
                                     };
    [_serviceHandler onOperate:requestBodyDic];
    guardianId = nil;
    requestHeader = nil;
    requestBodyDic = nil;
}

- (void)loadAlertsServiceWithoutPaging {
    NSString *guardianId = [NSString new];
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestHeader = @{kFamily_id_key:guardianId,
                          kUser_id_key:_modelManager.user.identifier,
                          kTokenKey:_modelManager.user.sessionToken};
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_ALERTS],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestHeader
                                     };
    [_serviceHandler onOperate:requestBodyDic];
    guardianId = nil;
    requestHeader = nil;
    requestBodyDic = nil;
}

#pragma mark - Service Response -
- (void)refreshUI:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sourceType == GET_ALERTS_SUCCEEDED) {
            [self setFilteredAlerts];
            //---processt stop Streaming alert---//
            [self updatePanicAlertTitle];//
            [refreshControl endRefreshing];
            [self.tView reloadData];
            [_pullToRefreshManager tableViewReloadFinished];
//            [_pullToRefreshManager relocatePullToRefreshView];
            [alertsHud hide:YES];
        } else if (sourceType == GET_ALERTS_FAILED) {
            [_pullToRefreshManager tableViewReloadFinished];
//            [_pullToRefreshManager relocatePullToRefreshView];
            [alertsHud hide:YES];
        } else if (sourceType == ACKNOWLEDGE_READ_ALERT_SUCCCEEDED) {
            [alertsHud hide:YES];
        } else if (sourceType == ACKNOWLEDGE_READ_ALERT_FAILED) {
            [alertsHud hide:YES];
        }
    });
}

- (void)setFilteredAlerts {
    //---Recheck for get alerts ---//
    if (!_allAlertList) {
        _allAlertList = [[NSMutableArray<Notification> alloc] init];
    } else {
        [_allAlertList removeAllObjects];
    }
    //---check to remove alertTypeAcknowledge & listening---//
    for (Notification *noti in _modelManager.notifications.rows) {
        if ([noti.alertType isEqualToString:kAlert_type_acknowledge_alert] ||
            [noti.alertType isEqualToString:kAlert_type_stop_listening] ||
            [noti.alertType isEqualToString:kAlert_type_silent_audio_streaming_on] ||
            [noti.alertType isEqualToString:kAlert_type_silent_audio_streaming_off] ||
            [Common isNullObject:noti.alertType]
            ) {
        } else {
            [_allAlertList addObject:noti];
        }
    }
}

- (void)updatePanicAlertTitle {
    for (Notification *stopNoti in _allAlertList) {
        if ([stopNoti.alertType isEqualToString:kAlert_type_stop]) {
            for (Notification *noti in _allAlertList) {
                if ([stopNoti.referenceId isEqualToString:noti.identifier]) {
                    NSString * title = stopNoti.messageTitle[_modelManager.defaultLanguage];
                    if ([title containsString:NSLocalizedString(@"and", nil)]) {
                        return;
                    }
                    //---Make Alert Title based on device language on startPanic alert---//
                    NSString * nameWhoSendAlert = @"";
                    NSString * messageTitle = @"";
                    nameWhoSendAlert = [Common getUserName:stopNoti.createdUser];
                    if ([Common isNullObject:[self getStringFromEpochTime:noti.createdTime]]) {
                        messageTitle = [NSString stringWithFormat:@"%@ %@",
                                        nameWhoSendAlert,
                                        noti.messageTitle[_modelManager.defaultLanguage]];
                    } else {
                        NSString *atString = NSLocalizedString(@"at", nil);
                        NSString *andString = NSLocalizedString(@"and", nil);
                        messageTitle = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ ",
                                        nameWhoSendAlert,noti.messageTitle[_modelManager.defaultLanguage],
                                        atString,
                                        [self getStringFromEpochTime:noti.createdTime], andString];
                    }
                    //--- get Stop Alert Title---//
                    if ([Common isNullObject:[self getStringFromEpochTime:stopNoti.createdTime]]) {
                        messageTitle = [NSString stringWithFormat:@"%@ %@ %@",messageTitle,
                                        nameWhoSendAlert,
                                        stopNoti.messageTitle[_modelManager.defaultLanguage]];
                    } else {
                        NSString *atString = NSLocalizedString(@"at", nil);
                        messageTitle = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",messageTitle,
                                        nameWhoSendAlert,stopNoti.messageTitle[_modelManager.defaultLanguage],
                                        atString,
                                        [self getStringFromEpochTime:stopNoti.createdTime]];
                    }
                    //---change Stop Panic Alert messageTitle---//
                    stopNoti.messageTitle[_modelManager.defaultLanguage] = messageTitle;
                }
            }
        }
    }
}

- (NSString*)getStringFromEpochTime:(NSString *)epochTime {
    NSTimeInterval seconds = [epochTime doubleValue];
    NSDate *epochNSDate = [NSDate dateWithTimeIntervalSince1970:(seconds / 1000)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:epochNSDate];
    return formattedDate;
}

@end
