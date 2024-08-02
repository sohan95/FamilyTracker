//
//  HomeViewController.m
//  Family Tracker
//
//  Created by Zeeshan Khan on 11/14/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//
#import "HomeViewController.h"
#import "MKNumberBadgeView.h"
#import <CoreLocation/CoreLocation.h>
#import "CalloutView.h"
#import "DXAnnotation.h"
#import "OCMapViewSampleHelpAnnotation.h"
#import "LocationHistoryViewController.h"
#import "LocationShareModel.h"
#import "ServiceHandler.h"
#import "FamilyTrackerOperate.h"
#import <MessageUI/MessageUI.h>
#import "AlertViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//---For LiveStreaming---//
#import "StreamVideoVC.h"
#import "StreamerConfiguration.h"
#import "AudioViewController.h"
#import "ChatViewController.h"
#import "MemberData.h"
#import "UserDetailsViewController.h"
#import "GlobalServiceManager.h"
#import "TrialExpiredViewController.h"
#import "MBProgressHUD.h"
#import "LocationHistoryViewController.h"
#import "LoginViewController.h"
#import "JsonUtil.h"
#import "DbHelper.h"
#import "Common.h"
#import "MapBoundaryViewController.h"
#import "RemoteMemberControllerManager.h"
#import "SubBoundary.h"
#import "Algorithms.h"
#import "PanicAlertStatus.h"
@import CoreTelephony;

//static NSString *const kTYPE1 = @"Banana";
//static CGFloat kDEFAULTCLUSTERSIZE = 0.2;

@interface HomeViewController ()<TableUpdater,MFMessageComposeViewControllerDelegate,CAAnimationDelegate> {
    AppDelegate *delegate;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    NSDictionary *requestBodyDic;
    AlertViewController *alertSubViewController;
    //---Timer
    NSTimer *panicAlertTimer;
    StreamerConfiguration *streamerConfig;
    BOOL isPanicAlertTypeAudio;
    BOOL isFocusActiveAnnotation;
    MBProgressHUD *updateServiceHud;
    CGFloat annotaionPosition;
}

@property(nonatomic, strong) MKNumberBadgeView *badgeNumber;
@property (nonatomic, assign) int timeCounter;
@property (nonatomic, readwrite) NSString *panicResourceType;
@property (nonatomic,strong) NSTimer *locationUpdateTimer;
@property (nonatomic, weak) IBOutlet UIButton *hideMeButton;
@property (nonatomic, assign) BOOL isLodationHide;
@property (nonatomic, strong) DXAnnotationView *dxAnnotationViewShown;
@property (nonatomic, assign) BOOL isCallOutShown;

// tooltips
@property (nonatomic, strong)	id currentPopTipViewTarget;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end

@implementation HomeViewController

double locationTimerInterval_15 = 15.0;
double locationTimerInterval_20 = 20.0;
double locationTimerInterval_30 = 30.0;
double locationTimerInterval_40 = 40.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    //---mapView settings---//
    self.mapView.delegate = self;
    isFocusActiveAnnotation = NO;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.title = NSLocalizedString(HOME_PAGE_TITLE_KEY,nil);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlertBatchNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alertBatchNotification:)
                                                 name:@"AlertBatchNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginToJabberServerNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginToJabberServerNoti:)
                                                 name:@"LoginToJabberServerNoti"
                                               object:nil];
    //---Remove All Annotations on mapview---//
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClearMapNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMapNotification:)
                                                 name:@"ClearMapNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"panicBackgroundChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(panicBackgroundChangeNoti:)
                                                 name:@"panicBackgroundChange"
                                               object:nil];
     _locationManager =[[CLLocationManager alloc]init];
    [self.locationManager startUpdatingLocation];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                  target:self
                                                selector:@selector(checkStatus)
                                                userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"panicMarkerImageChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(panicMarkerImageNoti:)
                                                 name:@"panicMarkerImageChange"
                                               object:nil];

    _annotationArray = [NSMutableArray array];
    _modelManager = [ModelManager sharedInstance];
    _isCallOutShown = NO;
    //---check initialViewController---//
    if ([_modelManager.currentVCName isEqualToString:@"AppDelegate"] ||
        [_modelManager.currentVCName isEqualToString:@"LoginViewController"]) {
        [[GlobalServiceManager sharedInstance] autoLoginPreLoading];
        //For Chat ---//
        [self initChatManager];
        [self loginToJabberServer];
    }
    _modelManager.currentVCName = @"HomeViewController";
    [self updateUserPermission];
    [self setDefaultView];
    [self initService];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[GlobalData sharedInstance].currentVC isKindOfClass:[AudioViewController class]] || [[GlobalData sharedInstance].currentVC isKindOfClass:[StreamVideoVC class]]) {
        if(delegate.timeObserver){
            delegate.timeObserver = nil;
        }
        if (delegate.player2) {
            [delegate.player2 pause];
            delegate.player2 = nil;
        }
        sleep(1.0);
        [delegate playPanicInBackground];
        [delegate.player2 play];
        [delegate setVolumeZero];
    }
    [GlobalData sharedInstance].currentVC = self;
    _modelManager.currentVCName = @"HomeViewController";
    self.panicAlertViewBg.hidden = YES;
    delegate.isPopUpAtHomeView = NO;
//    [self.footerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:HOME_FOOTER_BACKGROUND_ICON]]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setAnnotations];
    });
    //---Call Settings Service---//
    [self commonServiceFriquentlyCall];
}

- (void)viewWillDisappear:(BOOL)animated {
    _modelManager.currentVCName = @"OthersViewController";
    if (self.locationUpdateTimer) {
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [_panicAlertViewBg setHidden:YES];
    delegate.isPopUpAtHomeView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Defined Methods -
- (void)initChatManager {
    self.chatManager = [ChatManager instance];
    if (!self.chatManager._chatDelegate) {
        //NSLog(@"chat manager delegate nil");
        self.chatManager._chatDelegate = self;
    }else {
        //NSLog(@"delegate not nil");
    }
}

- (void)setDefaultView {
    
    [_nextView setHidden:YES];
    [_popUpPanicInformationButton setHidden:YES];
    if ([_modelManager.user.isLocationHide boolValue]) {
        _isLodationHide = YES;
        [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOn"] forState:UIControlStateNormal];
    }else {
        _isLodationHide = NO;
        [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOff"] forState:UIControlStateNormal];
    }
    //---Initialize NKNumberBadgeView---//
    _badgeNumber = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(10, -10, 30, 30)];
    _badgeNumber.font = [UIFont systemFontOfSize:10];
    _badgeNumber.hideWhenZero = YES;
    _badgeNumber.fillColor = [UIColor yellowColor];
    _badgeNumber.strokeColor = [UIColor yellowColor];
    _badgeNumber.textColor = [UIColor greenColor];
    _badgeNumber.value = 0;
    //---Allocate UIButton---//
    UIButton *btn = [UIButton  buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0f, 5.0f, 30.0f, 30.0f);
    btn.layer.cornerRadius = 8;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(showAlertPopUp) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"Notification-icon.png"] forState:UIControlStateNormal];
    [btn addSubview:_badgeNumber]; //Add NKNumberBadgeView as a subview on UIButton
    UIBarButtonItem *rightBarBtnAlert = [[UIBarButtonItem alloc] initWithCustomView:btn];
    rightBarBtnAlert.style = UIBarButtonItemStylePlain;
    UIBarButtonItem *rightRevealButtonItem = [self.navigationItem rightBarButtonItem];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:rightRevealButtonItem, rightBarBtnAlert, nil]];
    [self.navigationItem setLeftBarButtonItem:nil];
    //---set AutoMenualMode for Resolution---//
    self.navigationItem.rightBarButtonItem.image = [self.navigationItem.rightBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //--- Panic Alert PopUpView ---//
    _panicAlertView.layer.cornerRadius = 5.0;
    _panicAlertHeaderLbl.layer.cornerRadius = 5.0;
    _panicAlertView.layer.borderWidth = 2.0;
    _panicAlertView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.panicAlertCancelActionOutlet.layer.cornerRadius = 20;
    self.panicAlertCancelActionOutlet.clipsToBounds = YES;
    self.panicSendNowOutlet.layer.cornerRadius = 20;
    self.panicSendNowOutlet.clipsToBounds = YES;
    isPanicAlertTypeAudio = YES;
    [self backgroundChangeNotificationIcon];
    self.visiblePopTipViews = [NSMutableArray array];
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

- (NSDictionary *)getMemberSettingsById:(NSString *)memberId {
    for (MemberData *member in _modelManager.members.rows) {
        if ([member.identifier isEqualToString:memberId]) {
            return member.settings;
        }
    }
    return nil;
}

- (BOOL)isLocationHide:(NSString *)memberUserName {
    for (MemberData *member in _modelManager.members.rows) {
        if ([member.userName isEqualToString:memberUserName]) {
            BOOL isLocationHide = [member.isLocationHide boolValue];
            return isLocationHide;
        }
    }
    return NO;
}

- (BOOL)isMemberActive:(NSString *)memberUserName {
    for (MemberData *member in _modelManager.members.rows) {
        if ([member.userName isEqualToString:memberUserName]) {
            BOOL isActive = [member.isActive boolValue];
            return isActive;
        }
    }
    return NO;
}

//---Timer Duration---//
- (void)updatePanicAlertTimer {
    if (_timeCounter == 0) {
        if (panicAlertTimer) {
            [panicAlertTimer invalidate];
            panicAlertTimer = nil;
        }
        [_panicAlertViewBg setHidden:YES];
        if ([_panicResourceType isEqualToString:kPanicResource_audio]) {
            [self gotoAudioStreamVC:kAlert_type_panic];
        } else if ([_panicResourceType isEqualToString:kPanicResource_video]) {
            [self gotoVideoStreamHome:kAlert_type_panic];
        } else if ([_panicResourceType isEqualToString:kPanicResource_sms]) {
            [self sendSMSPanic:kAlert_type_panic];
        } else if ([_panicResourceType isEqualToString:kPanicResource_snapShot]) {
            [self sendSnapShotPanic:kAlert_type_panic];
        } else if ([_panicResourceType isEqualToString:kPanicResource_none]) {
            [[GlobalServiceManager sharedInstance] startNonePanicAlert];
            delegate.isPopUpAtHomeView = NO;
        }
    } else {
        _timeCounter -= 1;
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        NSString *numberString = [numberFormatter stringFromNumber:@(_timeCounter)];
//        NSString * timeCounterLocalized = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), numberString];
        if (_timeCounter > 9 ) {
            [_panicAlertTimerLabel setText:[NSString stringWithFormat:@"00:%d",_timeCounter]];
        } else {
            [_panicAlertTimerLabel setText:[NSString stringWithFormat:@"00:0%d",_timeCounter]];
        }
    }
}

- (void)longPressHideMeAction:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateBegan) {
        [self showAlertTitle:nil withMessage:NSLocalizedString(@"Location tracking on and off option", nil)];
    }
}

-(void)viewSlideInFromRightToLeft:(UIView *)views
{
    CATransition *transition = nil;
    transition = [CATransition animation];
    transition.duration = 0.3;//kAnimationDuration
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    transition.delegate = self;
    [views.layer addAnimation:transition forKey:nil];
}

-(void)viewSlideInFromLeftToRight:(UIView *)views
{
    CATransition *transition = nil;
    transition = [CATransition animation];
    transition.duration = 0.3;//kAnimationDuration
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    [views.layer addAnimation:transition forKey:nil];
}

//- (UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point {
//    UIFont *font = [UIFont boldSystemFontOfSize:12];
//    UIGraphicsBeginImageContext(image.size);
//    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
//    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
//    [[UIColor redColor] set];
//    [text drawInRect:CGRectIntegral(rect) withFont:font];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

#pragma - mark red and blinking notification
- (void)backgroundChangeNotificationIcon {
    UIImageView *btn = [[UIImageView alloc] init];
    btn.frame = CGRectMake(0.0f, 5.0f, 30.0f, 30.0f);
    btn.layer.cornerRadius = 8;
    if ([ModelManager sharedInstance].isPanicRunning) {
        [_popUpPanicInformationButton setHidden:NO];
        [_popUpPanicInformationButton setTitle:_modelManager.currentPanicText forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"redBell"],
                               [UIImage imageNamed:@"Notification-icon.png"], nil];
        btn.animationDuration = 0.50f;
        btn.animationRepeatCount = 0;
        [btn startAnimating];
    } else {
        [_popUpPanicInformationButton setHidden:YES];
        [btn setImage:[UIImage imageNamed:@"Notification-icon.png"]];
    }
    if ([ModelManager sharedInstance].isPanicStop) {
        [_popUpPanicInformationButton setHidden:NO];
        [_popUpPanicInformationButton setTitle:_modelManager.currentPanicText forState:UIControlStateNormal];
    }
    
    [btn addSubview:_badgeNumber]; //Add NKNumberBadgeView as a subview on UIButton
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAlertPopUp)];
    singleTap.numberOfTapsRequired = 1;
    [btn setUserInteractionEnabled:YES];
    [btn addGestureRecognizer:singleTap];
    UIBarButtonItem *rightBarBtnAlert = [[UIBarButtonItem alloc] initWithCustomView:btn];
    rightBarBtnAlert.style = UIBarButtonItemStylePlain;
    UIBarButtonItem *rightRevealButtonItem = [self.navigationItem rightBarButtonItem];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:rightRevealButtonItem, rightBarBtnAlert, nil]];
    //---set AutoMenualMode for Resolution---//
    self.navigationItem.rightBarButtonItem.image = [self.navigationItem.rightBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
}

#pragma mark- Button Action Event
- (IBAction)setMapType:(id)sender {
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

- (IBAction)hideMeToggleBtn:(UIButton *)sender {
    [self dismissAllPopTipViews];
    if (sender == self.currentPopTipViewTarget) {
        self.currentPopTipViewTarget = nil;
    } else {
        NSString *contentMessage = nil;
        contentMessage = NSLocalizedString(@"Location tracking ON and OFF action",nil);
        UIColor *backgroundColor = [UIColor blackColor];
        UIColor *textColor =[UIColor whiteColor];
        CMPopTipView *popTipView;
         popTipView = [[CMPopTipView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"  %@  ",contentMessage]];
        popTipView.delegate = self;
        if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
            popTipView.backgroundColor = backgroundColor;
        }
        if (textColor && ![textColor isEqual:[NSNull null]]) {
            popTipView.textColor = textColor;
            popTipView.textAlignment = NSTextAlignmentCenter;
        }
        popTipView.animation = arc4random() % 2;
        popTipView.has3DStyle = (BOOL)(arc4random() % 2);
        popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self.view animated:YES];
        } else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
        }
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
        [self chooseLocationHideShowOption:sender];
    }

}

//---callBtn---//
- (IBAction)makeCall:(UIButton *)sender {
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if (!carrier.isoCountryCode) {
         [self showAlertTitle:NSLocalizedString(@"ALERT",nil) withMessage:NSLocalizedString(@"No SIM Card Installed!",nil)];
    }else {
        NSString* phoneNumber = @"01722500015";
        NSString *number = [NSString stringWithFormat:@"%@",phoneNumber];
        NSURL* callUrl = [NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
        //--- Check Call Function available only in iphone
        if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
            [[UIApplication sharedApplication] openURL:callUrl];
        }else {
            [self showAlertTitle:NSLocalizedString(@"ALERT",nil) withMessage:NSLocalizedString(@"This function is only available on the iPhone",nil)];
        }
    }
}

//---SMSBtn---//
- (IBAction)makeSMS:(UIButton *)sender {
    NSArray *contactArray = [NSArray arrayWithObjects:@"01722500015", nil];
    [self sendSMS:@"Hi, " recipientList:contactArray];
}
//---DetailsBtn---//
- (IBAction)showDetails:(UIButton *)sender {
    MemberLocation *memberLocation = _modelManager.memberLocations.rows[sender.tag];
    NSString * userId = @"";
    for (MemberData *memberData in _modelManager.members.rows) {
        if ([memberData.userName isEqualToString:memberLocation.userName]) {
            userId = memberData.identifier;
            break;
        }
    }
    if (userId.length > 0) {
        _modelManager.currentVCName = @"UserDetailsViewController";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        UserDetailsViewController *userDetailsViewController= [sb instantiateViewControllerWithIdentifier:USER_DETAILS_VIEW_CONTROLLER_KEY];
        userDetailsViewController.userId = userId;
        if ([_modelManager.user.role intValue] == 1) {
            userDetailsViewController.memberRole = 1;
        }else {
            userDetailsViewController.memberRole = 2;
        }
        [self.navigationController pushViewController:userDetailsViewController animated:YES];
    }
}

//---LocationBriefBtn---//
- (IBAction)showLocationHistory:(UIButton *)sender {
    if (sender.tag < [_modelManager.memberLocations.rows count]) {
        MemberLocation *memberLocation = _modelManager.memberLocations.rows[sender.tag];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LocationHistoryViewController *locHistoryVC = [sb instantiateViewControllerWithIdentifier:@"LocationHistoryViewController"];
        locHistoryVC.currentURL = [NSString stringWithFormat:@"http://35.167.140.127:3300/history/user/%@",memberLocation.userName];
        NSString * locationHistory = NSLocalizedString(@"Location History:",nil);
        locHistoryVC.title = [NSString stringWithFormat:@"%@ %@",locationHistory,memberLocation.userName];
        [self.navigationController pushViewController:locHistoryVC animated:YES];
    }
}

- (IBAction)closeCallOutView:(id)sender {
//    if (_isCallOutShown) {
        [_dxAnnotationViewShown hideCalloutView];
        _dxAnnotationViewShown.layer.zPosition = -1;
//        _dxAnnotationViewShown = nil;
        _isCallOutShown = YES;
//    }
}

//---setBoundaryAction---//
- (IBAction)setBoundaryAction:(UIButton *)sender {
    MemberLocation *memberLocation = _modelManager.memberLocations.rows[sender.tag];
    NSString * memberId = @"";
    NSString * memberName = @"";
    for (MemberData *memberData in _modelManager.members.rows) {
        if ([memberData.userName isEqualToString:memberLocation.userName]) {
            memberId = memberData.identifier;
            if(memberData.firstName.length == 0 && memberData.lastName.length == 0) {
                memberName =[NSString stringWithFormat:@"%@",memberData.userName];
            } else {
                memberName = [NSString stringWithFormat:@"%@ %@",memberData.firstName,memberData.lastName];
            }
            break;
        }
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapBoundaryViewController *mapBoundaryViewController = [sb instantiateViewControllerWithIdentifier:@"MapBoundaryViewController"];
    mapBoundaryViewController.memberId = memberId;
    mapBoundaryViewController.memberName = memberName;
    mapBoundaryViewController.lat = memberLocation.latitude;
    mapBoundaryViewController.lon = memberLocation.longitude;
    [self.navigationController pushViewController:mapBoundaryViewController animated:YES];
}

- (IBAction)createPanicAlert {
    delegate.listnerLists = nil;
    if (!delegate.isPopUpAtHomeView && [ModelManager sharedInstance].members.rows.count > 1) {
        if (![_panicResourceType isEqualToString:kAlertResourceTypeSMS] && [FamilyTrackerReachibility isUnreachable]) {
            [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
            return;
        }
        delegate.isPopUpAtHomeView = YES;
        [_panicAlertViewBg setHidden:NO];
        if (panicAlertTimer) {
            [panicAlertTimer invalidate];
            panicAlertTimer = nil;
        }
        _panicResourceType = _modelManager.user.userSettings[kPanicResourceType];
        _timeCounter =  [_modelManager.user.userSettings[kPanicCountdown] intValue];
        _panicAlertHeaderText.text = NSLocalizedString(_panicResourceType,nil);
        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        NSString *numberString = [numberFormatter stringFromNumber:@(_timeCounter)];
//        NSString * timeCounterLocalized = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), numberString];
        if (_timeCounter > 9 ) {
            [_panicAlertTimerLabel setText:[NSString stringWithFormat:@"00:%d",_timeCounter]];
        } else {
            [_panicAlertTimerLabel setText:[NSString stringWithFormat:@"00:0%d",_timeCounter]];
        }
        panicAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePanicAlertTimer) userInfo:nil repeats:YES];
    } else {
        [Common displayToast:NSLocalizedString(@"You need to add one member at least",nil) title:nil duration:1.0];
    }
}

- (IBAction)goToConferenceRoom {
    if (!delegate.isPopUpAtHomeView && [ModelManager sharedInstance].members.rows.count > 1) {
        if ([_modelManager.user.settings[kChatPostPermission] boolValue]){
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController *chatViewController = [sb instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatViewController.chatWithUser = [GlobalData sharedInstance].roomName;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
    } else {
        [Common displayToast:NSLocalizedString(@"You need to add one member at least",nil) title:nil duration:1.0];
    }
}

- (IBAction)gotoVideoStream:(id)sender {
    if(!delegate.isPopUpAtHomeView && [ModelManager sharedInstance].members.rows.count > 1) {
        [self gotoVideoStreamHome:kAlert_type_videoStreaming];
    }else {
        [Common displayToast:NSLocalizedString(@"You need to add one member at least",nil) title:nil duration:1.0];
    }
}

- (IBAction)gotoAudioStream:(id)sender {
    if (!delegate.isPopUpAtHomeView && [ModelManager sharedInstance].members.rows.count > 1) {
        [self gotoAudioStreamVC:kAlert_type_audioStreaming];
    }else {
        [Common displayToast:NSLocalizedString(@"You need to add one member at least",nil) title:nil duration:1.0];
    }
}

- (IBAction)panicAlertCancelAction:(id)sender {
    if (panicAlertTimer) {
        [panicAlertTimer invalidate];
        panicAlertTimer = nil;
    }
    [_panicAlertViewBg setHidden:YES];
    delegate.isPopUpAtHomeView = NO;
}
- (IBAction)panicSendNowAction:(id)sender {
    _timeCounter = 0;
    [self updatePanicAlertTimer];
}

- (void)showAlertPopUp {
    if(_modelManager.members.rows.count > 1){
        if(!delegate.isPopUpAtHomeView) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [delegate setVolumeZero];
            [ModelManager sharedInstance].isPanicStop = NO;
            [self backgroundChangeNotificationIcon];
            //[delegate StopPanicAlert];
            [[GlobalServiceManager sharedInstance] acknowledgeNewAlertService];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            AlertViewController *alertSubViewController1 = (AlertViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AlertViewController"];
            [self.navigationController pushViewController:alertSubViewController1 animated:YES];
        }
    } else {
        [Common displayToast:NSLocalizedString(@"You need to add one member at least",nil) title:nil duration:1.0];
    }
}

- (IBAction)popUpPanicInformationAction:(id)sender {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [delegate setVolumeZero];
    [ModelManager sharedInstance].isPanicStop = NO;
    [self backgroundChangeNotificationIcon];
    [[GlobalServiceManager sharedInstance] acknowledgeNewAlertService];
}

- (IBAction)callBtnAction:(id)sender {
    [Common displayToast:@"Under Development" title:nil duration:1.0];
}

- (IBAction)nexArrowBtnAction:(id)sender {
    [_nextView setHidden:NO];
    [self viewSlideInFromRightToLeft:_nextView];
    [self viewSlideInFromRightToLeft:_previousView];
    [_previousView setHidden:YES];
}

- (IBAction)previousBtnAction:(id)sender {
    [_previousView setHidden:NO];
    [self viewSlideInFromLeftToRight:_previousView];
    [self viewSlideInFromLeftToRight:_nextView];
    [_nextView setHidden:YES];
}

- (IBAction)videoBtnAction:(id)sender {
    [Common displayToast:@"Under Development" title:nil duration:1.0];
}

- (IBAction)calendarBtnAction:(id)sender {
    [Common displayToast:@"Under Development" title:nil duration:1.0];
}

- (IBAction)memoriesBtnAction:(id)sender {
    [Common displayToast:@"Under Development" title:nil duration:1.0];
}

- (IBAction)musicBtnAction:(id)sender {
    [Common displayToast:@"Under Development" title:nil duration:1.0];
}

#pragma mark - Conferance Chat -
- (void)createChatRoom : (NSString*)chatRoomName {
    delegate.isConference = 1;
    [self.chatManager createRoom:chatRoomName];
}

#pragma mark - Restriction Rotation -
- (void)restrictRotation:(BOOL)restriction {
    delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.restrictRotation = restriction;
    delegate.deviceOrientation = [[UIDevice currentDevice] orientation];
}

#pragma mark - NotificationCenter Methods -
- (void)alertBatchNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"AlertBatchNotification"]){
        _badgeNumber.value = [_modelManager.totalNewAlerts integerValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [_modelManager.totalNewAlerts integerValue];
    }
}

- (void)clearMapNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"ClearMapNotification"]){
        [_mapView removeAnnotations:_mapView.annotations];
    }
}

- (void)loginToJabberServerNoti:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"LoginToJabberServerNoti"]){
        [self loginToJabberServer];
    }
}

- (void)panicBackgroundChangeNoti:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"panicBackgroundChange"]){
        [self backgroundChangeNotificationIcon];
    }
}

- (void)panicMarkerImageNoti:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"panicMarkerImageChange"]){
        [self setAnnotations];
    }
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
                               updateUserUpdate:(id)self
                               settingsUpdate:nil
                               loginUpdate:nil
                               trackAppDayNightModeUpdate:(id)self
                               saveLocationUpdate:nil
                               getLocationUpdate:(id)self
                               getLocationHistoryUpdate:nil
                               saveAlertUpdate:(id)self
                               getAlertUpdate:nil
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
    [self getSettingsService];
    // offline syn
    //[[GlobalServiceManager sharedInstance] synchronizedOffLineToOnLine];
}

- (void)commonServiceFriquentlyCall {
    [self getMemberByMemberIdService];
    [self getAllMemberDataSevice];
    NSString *isFirebaseReg = [[NSUserDefaults standardUserDefaults] valueForKey:IsFirebaseTokenRegSuccess];
    if([isFirebaseReg isEqualToString:@"0"]) {
        [[GlobalServiceManager sharedInstance] deviceRegistrationForPushNotification];
    }
    
    //[self getAlertsService];
    //---Set Timer to Call Repeated Services ---//
    if (self.locationUpdateTimer) {
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
    }
    self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:locationTimerInterval_15 target:self selector:@selector(commonServiceFriquentlyCall) userInfo:nil repeats:YES];
}

- (void)getSettingsService {
    NSDictionary *requestHeader = @{kTokenKey:_modelManager.user.sessionToken
                                  };
    
    requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_SETTINGS],
                       WHEN_KEY:[NSDate date],
                       OBJ_KEY:requestHeader
                       };
    [_serviceHandler onOperate:requestBodyDic];
}

- (void)locationHideByMemberSevice:(NSNumber *)hideStatus {
    if ([_modelManager.currentVCName isEqualToString:@"HomeViewController"]) {
        //---Progress HUD---//
        if (updateServiceHud) {
            [updateServiceHud hide:YES];
            updateServiceHud = nil;
        }
        updateServiceHud = [[MBProgressHUD alloc] initWithView:self.view];
        [updateServiceHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:updateServiceHud];
        [updateServiceHud show:YES];
        NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                      kUser_id_key:_modelManager.user.identifier,
                                      kIsLocationHide_key:hideStatus};
        requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:LOCATION_HIDE],
                           WHEN_KEY:[NSDate date],
                           OBJ_KEY:requestBody
                           };
        [_serviceHandler onOperate:requestBodyDic];
    }
}

- (void)getAllMemberDataSevice {
    if ([_modelManager.currentVCName isEqualToString:@"HomeViewController"]) {
        NSString *guardianId = @"";
        if([_modelManager.user.role integerValue] == 1) {
//            guardianId = _modelManager.user.identifier;
            guardianId = _modelManager.user.guardianId;
        }else {
            guardianId = _modelManager.user.guardianId;
        }
        NSDictionary *requestBody = @{kGuardianId:guardianId,
                                      kTokenKey:_modelManager.user.sessionToken};
        requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_All_MEMBERS],
                           WHEN_KEY:[NSDate date],
                           OBJ_KEY:requestBody
                           };
        [_serviceHandler onOperate:requestBodyDic];
    }
}

- (void)getMemberByMemberIdService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    } else {
        NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_modelManager.user.identifier,
                                           kTokenKey:_modelManager.user.sessionToken,
                                           kDeviceTypeKey:@"1",
                                           kDeviceNoKey:deviceUUID
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)getMemberLocationDataService {
    if ([_modelManager.currentVCName isEqualToString:@"HomeViewController"]) {
        NSMutableArray *userNameArray = [NSMutableArray new];
        for (MemberData *md in _modelManager.members.rows) {
            if (md.userName) {
                [userNameArray addObject:md.userName];
            }
        }
        if (userNameArray.count > 0) {
            NSDictionary *requestBody = @{@"start_absolute": @1,
                                          @"metrics": @[
                                                  @{
                                                      @"group_by": @[
                                                              @{
                                                                  @"name": @"tag",
                                                                  @"tags": @[@"id"]
                                                                  }
                                                              ],
                                                      @"tags": @{
                                                              @"id" : userNameArray
                                                              },
                                                      @"name": @"user",
                                                      @"limit": @1,
                                                      @"order":@"desc"
                                                      }]
                                          };
            requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:GET_LOCATION_DATA],
                               WHEN_KEY:[NSDate date],
                               OBJ_KEY:requestBody
                               };
            [_serviceHandler onOperate:requestBodyDic];
        }
    }
}

- (void)startStreamingService:(NSString*)alertTypeValue andResourceType:(NSString*)resourchType {
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
//        guardianId = _modelManager.user.identifier;
        guardianId = _modelManager.user.guardianId;

    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kAlert_type:alertTypeValue,
                                  kResourceTypeKey:resourchType,//may be sms
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                        }
                                  };
    requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma mark - Service Response -
- (void)refreshUI:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sourceType == GET_LOCATION_DATA_SUCCEEDED) {
                [self setAnnotations];
        } else if (sourceType == GET_LOCATION_DATA_FAILED) {
//            NSLog(@"GET_LOCATION_DATA_FAILED");

        } else if (sourceType == GET_All_MEMBERS_SUCCEEDED) {
            [self getMemberLocationDataService];
            _badgeNumber.value = [_modelManager.totalNewAlerts integerValue];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [_modelManager.totalNewAlerts integerValue];
            //--- Update User Setting Array---//sohan
            if (_modelManager.user.settings == nil) {
                _modelManager.user.settings = [NSDictionary new];
            }
            _modelManager.user.settings =  [self getMemberSettingsById:_modelManager.user.identifier];
            ///---Check User permission to access featurs---//
            [self updateUserPermission];
        } else if (sourceType == GET_All_MEMBERS_FAILED) {
//            NSLog(@"GET_All_MEMBERS_FAILED");
        } else if (sourceType == GET_SETTINGS_SUCCEEDED) {
//            NSLog(@"GET_SETTINGS_SUCCEEDED");
        } else if (sourceType == GET_SETTINGS_FAILED) {
//            NSLog(@"GET_SETTINGS_FAILED");
        } else if (sourceType == ACKNOWLEDGE_NEW_ALERTS_SUCCCEEDED) {
            _badgeNumber.value = 0;
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

        } else if (sourceType == ACKNOWLEDGE_NEW_ALERTS_FAILED) {
//            NSLog(@"ACKNOWLEDGE_NEW_ALERTS_FAILED");
        }
    });
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == GET_MEMBER_BY_ID_SUCCEEDED) {
            if([object isKindOfClass:[NSDictionary class]]) {
                NSError *error;
                User *trialCheckUser = [[User alloc] initWithDictionary:(NSDictionary*)object error:&error];
                trialCheckUser.chatSetting = _modelManager.user.chatSetting;
                trialCheckUser.sessionToken = _modelManager.user.sessionToken;
                _modelManager.user = trialCheckUser;
                if ([Common isNullObject:_modelManager.user.userSettings[@"1004"]]) {
                     _modelManager.user.userSettings[@"1004"] = @"0";
                }
                [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
                [[GlobalServiceManager sharedInstance] lazyImageLoderForProfileImage];
                //                [self updateUserPermission];
                if ([trialCheckUser.paymentStatus isEqualToString:@"trial_expired"]) {
//                    [self gotoContactVC];
                    [self checkboundaryTouch];
                } else if ([trialCheckUser.paymentStatus isEqualToString:@"trial"]){
                    // if boundary touch then generate alert
                    [self checkboundaryTouch];
                    if ([Common isNullObject:trialCheckUser.remainingTrialPerid]) {
                        NSLog(@"its trial but not reach threshold value");
                    } else {
                        NSString * msg = @"";
                        if(trialCheckUser.trialPeriodMsg[_modelManager.defaultLanguage]) {
                            msg = trialCheckUser.trialPeriodMsg[_modelManager.defaultLanguage];
                        } else {
                            msg = @"";
                        }
                        if ([trialCheckUser.remainingTrialPerid intValue] > 1){
                             // show toast
                            [self showAlertTitle:NSLocalizedString(@"Notice", nil) withMessage:msg];
                        } else {
                            [delegate startTrialExpiredTimer:msg];
                        }
                    }
                } else {
                    // if boundary touch then generate alert
                    [self checkboundaryTouch];
                }
            }
        }
        else if(sourceType == GET_MEMBER_BY_ID_FAILED) {
            if ([object isKindOfClass:[NSDictionary class]] && [object[kCodeKey] integerValue] == 555) {
                //---LogOut & goto LoginVC ---//
                _modelManager.user.sessionToken = nil;
                [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
                [[GlobalData sharedInstance] reset];
                [_modelManager logOut];
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginViewController = [sb instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER_KEY];
                [self.navigationController pushViewController:loginViewController animated:YES];
                
                UIAlertView *trialMessageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:object[kMessageKey][_modelManager.defaultLanguage] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                [trialMessageAlert show];
            } else {
                //[Common displayToast:@"Something wrong" title:nil duration:1.0];
            }
        }
        else if(sourceType == LOCATION_HIDE_SUCCCEEDED) {
            [updateServiceHud hide:YES];
            updateServiceHud = nil;
//            _modelManager.user.isLocationHide = [NSNumber numberWithBool:_hideMeSwitch.isOn];
            _modelManager.user.isLocationHide = [NSNumber numberWithBool:_isLodationHide];
            if (_isLodationHide) {
                [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOn"] forState:UIControlStateNormal];
                [Common displayToast:NSLocalizedString(@"User is hidden to all members",nil) title:nil duration:2];
            }else {
                [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOff"] forState:UIControlStateNormal];
                [Common displayToast:NSLocalizedString(@"User visible to all members",nil) title:nil duration:2];
            }
        } else if(sourceType == LOCATION_HIDE_FAILED) {
            [updateServiceHud hide:YES];
            updateServiceHud = nil;
            [Common displayToast:NSLocalizedString(@"Location hide failed!", nil)  title:nil duration:2];
        }
        if(sourceType == SAVE_ALERT_SUCCEEDED) {//---Save Alerts
            //NSError *error = nil;
            //_modelManager.liveStreamingAlert  = [[Notification alloc] initWithDictionary:object error:&error];
            
            if(object[kAlert_type]) {
                if([[NSString stringWithFormat:@"%@",object[kAlert_type]] isEqualToString:kAlert_type_bounday_touched]) {
                    [Common displayToast:NSLocalizedString(@"Boundary touch alert has been sent.", nil)  title:nil duration:1];
                    return;
                } else if([[NSString stringWithFormat:@"%@",object[kAlert_type]] isEqualToString:kAlert_type_bounday_unTouched]) {
                    [Common displayToast:NSLocalizedString(@"Boundary untouched alert has been sent.", nil)  title:nil duration:1];
                    return;
                }
            }
            if ([_modelManager.user.userSettings[kPanicResourceType] isEqualToString:kPanicResource_sms]) {
                [Common displayToast:NSLocalizedString(@"SMS panic alert has been sent.", nil)  title:nil duration:1];
            } else if ([_modelManager.user.userSettings[kPanicResourceType] isEqualToString:kPanicResource_audio]) {
                [Common displayToast:NSLocalizedString(@"Audio panic alert has been sent.", nil)  title:nil duration:1];
            } else if ([_modelManager.user.userSettings[kPanicResourceType] isEqualToString:kPanicResource_video]) {
                [Common displayToast:NSLocalizedString(@"Video panic alert has been sent.", nil)  title:nil duration:1];
            } else {
                [Common displayToast:NSLocalizedString(@"Snapshot panic alert has been sent.", nil)  title:nil duration:1];
            }
        }
        else if(sourceType == SAVE_ALERT_FAILED) {
            [Common displayToast:NSLocalizedString(@"Panic alert failed to send!", nil)  title:nil duration:1];
        }
    });
}

- (void)updateUserPermission {
    //---ChatBtn set Enable/Disable
    if ([GlobalData sharedInstance].isJabberLogedIn) {
        if ([_modelManager.user.settings[kChatPostPermission] boolValue]) {
            [_chatBtn setEnabled:YES];
        } else {
            [_chatBtn setEnabled:NO];
        }
    } else {
        [_chatBtn setEnabled:NO];
    }
    //--Show show/hide settings for user it he got permission---//
    if ([_modelManager.user.settings[kLocationHide] boolValue]) {
//        if (_hideMeBgView.isHidden) {
//            [_hideMeSwitch setOn:[_modelManager.user.isLocationHide boolValue]];
//            [_hideMeBgView setHidden:NO];
//        }
//        ///
        if (_hideMeButton.isHidden) {
            [_hideMeButton setHidden:NO];
            if ([_modelManager.user.isLocationHide boolValue]) {
                _isLodationHide = YES;
                [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOn"] forState:UIControlStateNormal];
            }else {
                _isLodationHide = NO;
                [_hideMeButton setImage:[UIImage imageNamed:@"HideMeOff"] forState:UIControlStateNormal];
            }
        }
    } else {
//         [_hideMeBgView setHidden:YES];
         [_hideMeButton setHidden:YES];
    }
}

#pragma mark - MapView Helper Methods
- (void)setAnnotations {
    _annotationArray = _modelManager.memberLocations.rows;
    if (_annotationArray.count && !isFocusActiveAnnotation) {
//        isFocusActiveAnnotation = YES;
        MemberLocation *memberLocation = [_annotationArray objectAtIndex:0];
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = memberLocation.latitude;
        ctrpoint.longitude = memberLocation.longitude;
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(ctrpoint, 1000, 1000)];
    }
    //MemberLocation *memberLoc1 = _annotationArray.lastObject;
    if ([[self.mapView annotations] count] > 0) {
        for (int index = 0; index < [_annotationArray count]; index++) {
            BOOL isNewAnnotaion = YES;
            for (int annotationIndex = 0; annotationIndex<[[self.mapView annotations] count]; annotationIndex++) {
                id annotation = [[self.mapView annotations] objectAtIndex:annotationIndex];
                if ([annotation isKindOfClass:[DXAnnotation class]]) {
                    //                    OCMapViewSampleHelpAnnotation *item = (OCMapViewSampleHelpAnnotation *)annotation;
                    DXAnnotation *item = (DXAnnotation *)annotation;
                    MemberLocation *memberLocation = (MemberLocation*)_annotationArray[index];
                    if ([item.memberUserName isEqualToString:memberLocation.userName]) {
                        isNewAnnotaion = NO;
                        //--check Client user's annotation--//
                        if ([_modelManager.user.userName isEqualToString:item.memberUserName] && [_modelManager.user.role intValue] == 2) {
                            //---selfUser---//
                            static BOOL isUserMarkerChanged = NO;
                            if ([_modelManager.user.settings[kLocationHide] boolValue]) {
                                isUserMarkerChanged = YES;
                                if ([_modelManager.user.isLocationHide boolValue]) {
                                    DXAnnotationView* anView = (DXAnnotationView*)[self.mapView viewForAnnotation: item];
                                    if (anView) {
                                        DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                        
                                        UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                        [pinImage stopAnimating];
                                        pinImage.animationImages = nil;
                                        UIImage *image = [UIImage imageNamed:@"hideMeOnIcon.png"];
                                        UIImage *image2 = [self imageResize:image];
                                        pinImage.image = image2;
                                        
                                        pinImage.layer.cornerRadius = pinImage.frame.size.width / 2;
                                        pinImage.clipsToBounds = YES;
                                        pinImage.layer.borderWidth = 3.0f;
                                        pinImage.layer.borderColor = [UIColor whiteColor].CGColor;
                                    }
                                } else {
                                    DXAnnotationView* anView = (DXAnnotationView*)[self.mapView viewForAnnotation: item];
                                    if (anView) {
                                        DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                        
                                        if (_isCallOutShown) {
                                            [[dxView superview] bringSubviewToFront:dxView];
                                        }
                                        UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                        //UIImage *image = [self getMarkerImage:item.memberUserName];
                                        UIImage *blink1 = [UIImage imageNamed:@"Men"];
                                        UIImage *blink2 = [UIImage imageNamed:@"GreenBlink"];
                                        
                                        UIImage *imageResized1 = [self imageResize:blink1];
                                        UIImage *imageResized2 = [self imageResize:blink2];
                                        pinImage.backgroundColor = [UIColor clearColor];
                                        pinImage.animationImages = [NSArray arrayWithObjects:
                                                                    imageResized1,imageResized2, nil];
                                        pinImage.animationDuration = 0.80f;
                                        pinImage.animationRepeatCount = 0;
                                        [pinImage startAnimating];
                                    }
                                }
                            } else {
                                if (isUserMarkerChanged) {
                                    isUserMarkerChanged = NO;
                                    DXAnnotationView* anView = (DXAnnotationView*)[self.mapView viewForAnnotation: item];
                                    if (anView) {
                                        DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                        UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                        [pinImage stopAnimating];
                                        pinImage.animationImages = nil;
                                        UIImage *image = [UIImage imageNamed:@"Men.png"];
                                        image = [self imageResize:image];
                                        pinImage.image = image;
                                        
                                        pinImage.layer.cornerRadius = pinImage.frame.size.width / 2;
                                        pinImage.clipsToBounds = YES;
                                        pinImage.layer.borderWidth = 3.0f;
                                        pinImage.layer.borderColor = [UIColor whiteColor].CGColor;
                                    }
                                }
                                if (![item.memberName isEqualToString:memberLocation.name]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        item.memberName = memberLocation.name;
                                        item.coordinate = CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude);
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        item.coordinate = CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude);
                                    });
                                }
                            }
                        } else {//---Other members
                            //---check it it hide location---//
                            if ([self isLocationHide:memberLocation.userName] || ![self isMemberActive:memberLocation.userName]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.mapView removeAnnotation:annotation];
                                });
                            } else {
                                // code now
                                DXAnnotationView* anView = (DXAnnotationView*)[self.mapView viewForAnnotation: item];
                                
                                if (anView) {
                                    BOOL isFound = NO;
                                    for(int j = 0; j<_modelManager.runningPanics.count; j++) {
                                        PanicAlertStatus *panicAlertStatus = [_modelManager.runningPanics objectAtIndex:j];
                                        if([panicAlertStatus.userName isEqualToString:item.memberUserName]) {
                                            isFound = YES;
                                            break;
                                        }
                                    }
                                    if(isFound) {
                                        DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                        
                                        UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                        //UIImage *image = [self getMarkerImage:item.memberUserName];
                                        UIImage *blink1 = [UIImage imageNamed:@"Men"];
                                        UIImage *blink2 = [UIImage imageNamed:@"redImage"];
                                        
                                        UIImage *imageResized1 = [self imageResize:blink1];
                                        UIImage *imageResized2 = [self imageResize:blink2];
                                        pinImage.backgroundColor = [UIColor clearColor];
                                        pinImage.animationImages = [NSArray arrayWithObjects:
                                                                    imageResized1,imageResized2, nil];
                                        pinImage.animationDuration = 0.80f;
                                        pinImage.animationRepeatCount = 0;
                                        [pinImage startAnimating];
                                        dxView.layer.zPosition = 6;
                                    } else {
                                        long long timeStampInt = [@(floor([[NSDate date] timeIntervalSince1970] * 1000))longLongValue];
                                        NSNumber *currentTime = [NSNumber numberWithLongLong:timeStampInt];
                                        long long int getTimeStamp = [memberLocation.timestamp longLongValue];
                                        long long int currentTimeStamp = [currentTime longLongValue];
                                        long long int timeDifferent = (currentTimeStamp - getTimeStamp)/60000;
                                        if(timeDifferent == 0) {
                                            DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                            UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                            [pinImage stopAnimating];
                                            pinImage.animationImages = nil;
                                            UIImage *image = [UIImage imageNamed:@"Men.png"];
                                            image = [self imageResize:image];
                                            pinImage.image = image;
                                            pinImage.layer.cornerRadius = pinImage.frame.size.width / 2;
                                            pinImage.clipsToBounds = YES;
                                            pinImage.layer.borderWidth = 3.0f;
                                            pinImage.layer.borderColor = [UIColor whiteColor].CGColor;
                                            dxView.layer.zPosition = 0;
                                        } else {
                                            DXAnnotationView* dxView = (DXAnnotationView*)anView;
                                            UIImageView *pinImage = (UIImageView*)dxView.pinView;
                                            //UIImage *image = [self getMarkerImage:item.memberUserName];
                                            UIImage *blink1 = [UIImage imageNamed:@"grayImage"];
                                            UIImage *blink2 = [UIImage imageNamed:@"grayImage"];
                                            
                                            UIImage *imageResized1 = [self imageResize:blink1];
                                            UIImage *imageResized2 = [self imageResize:blink2];
                                            pinImage.backgroundColor = [UIColor clearColor];
                                            pinImage.animationImages = [NSArray arrayWithObjects:
                                                                        imageResized1,imageResized2, nil];
                                            pinImage.animationDuration = 0.80f;
                                            pinImage.animationRepeatCount = 0;
                                            [pinImage startAnimating];
                                            dxView.layer.zPosition = 4;
                                        }
                                    }
                                }
                                if (![item.memberName isEqualToString:memberLocation.name]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        item.memberName = memberLocation.name;
                                        item.coordinate = CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude);
                                    });
                                }else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        item.coordinate = CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude);
                                    });
                                }
                            }
                        }
                    }
                }
            }// ---inner forloop---//
            if (isNewAnnotaion) {
                [self addAnnotationOnMapView:index];
            }
        }
    } else {
        for (int index = 0; index<[_annotationArray count]; index++) {
            [self addAnnotationOnMapView:index];
        }
    }
    
    if (_annotationArray.count && !isFocusActiveAnnotation) {
        isFocusActiveAnnotation = YES;
        [_mapView showAnnotations:_mapView.annotations animated:YES];
    }
}

- (void)addAnnotationOnMapView:(int)index {
    MemberLocation *memberLocation = [_annotationArray objectAtIndex:index];
    ///check is it hide location---//
    if (![self isLocationHide:memberLocation.userName] && [self isMemberActive:memberLocation.userName]) {
        //        OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude)];
        DXAnnotation *annotation = [DXAnnotation new];
        annotation.coordinate = CLLocationCoordinate2DMake(memberLocation.latitude, memberLocation.longitude);
        annotation.annotationIndex = index;
        annotation.memberUserName = memberLocation.userName;
        annotation.memberName = memberLocation.name;
        [_mapView addAnnotation:annotation];
    }
}

- (UIImageView*)setImageLayer:(UIImageView *)imageToLayer isSelect:(BOOL)isSelect {
    imageToLayer.layer.cornerRadius = imageToLayer.frame.size.width / 2;
    imageToLayer.clipsToBounds = YES;
    imageToLayer.layer.borderWidth = 3.0f;
    if(isSelect) {
        imageToLayer.layer.borderColor = [UIColor blueColor].CGColor;
    } else {
        imageToLayer.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return imageToLayer;
}

- (UIImage *)imageResize:(UIImage *)oldImage {
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGSize newSize = CGSizeMake(70,70);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [oldImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)getMarkerImage:(NSString *)userName {
    UIImage * profileImage = [UIImage imageNamed:@"Men"];
    for(MemberData *member in _modelManager.members.rows) {
        if([member.userName isEqualToString:userName]) {
            NSString * gender = member.gender;
            if([Common isNullObject:gender] || gender.length<1 || [gender isEqualToString:@""]) {
            } else {
                if([gender isEqualToString:@"Male"] || [gender isEqualToString:@"পুরুষ"]) {
                    profileImage = [UIImage imageNamed:@"Men"];
                } else if([gender isEqualToString:@"Female"] || [gender isEqualToString:@"মহিলা"]) {
                    profileImage = [UIImage imageNamed:@"Men"];
                }
            }
            break;
        }
    }
    return profileImage;
}

#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[DXAnnotation class]]) {
        DXAnnotation *dxAnnotation = (DXAnnotation*)annotation;
        UIImageView *pinView = nil;
        CalloutView *calloutView = nil;
        DXAnnotationView *annotationView = (DXAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];
        UIImage *image = [self getMarkerImage:dxAnnotation.memberUserName];
        if (!annotationView) {
            pinView = [[UIImageView alloc] initWithImage:[self imageResize:image]];
            pinView = [self setImageLayer:pinView isSelect:NO];
            calloutView = (CalloutView*)[[[NSBundle mainBundle] loadNibNamed:@"myView" owner:self options:nil] firstObject];
            calloutView.layer.cornerRadius = 5.0;
            calloutView.layer.borderWidth = 2.0;
            calloutView.layer.borderColor = [HexToRGB colorForHex:@"FFFFFF"].CGColor;
            calloutView.layer.masksToBounds = NO;
            calloutView.layer.shadowRadius = 10;
            calloutView.layer.shadowOpacity = 0.25;
            calloutView.layer.shadowOffset = CGSizeMake(0, 10);
            if ([_modelManager.user.role intValue] == 2) {
                CGRect tempFrame = calloutView.frame;
                tempFrame.size.width = 235.0;
                tempFrame.size.height = 147.0;
                [calloutView setFrame:tempFrame];
                [calloutView.setBoundary setHidden:YES];
            }
            if (![dxAnnotation.memberUserName isEqualToString:_modelManager.user.userName]) {
                //---callBtn---//
                [calloutView.callBtn setHidden:NO];
                //---resize calloutview Height
                CGRect tempFrame = calloutView.frame;
                tempFrame.size.height = 147.0;
                [calloutView setFrame:tempFrame];
                 
                calloutView.callBtn.tag = dxAnnotation.annotationIndex;
                [calloutView.callBtn addTarget:self action:@selector(makeCall:) forControlEvents:UIControlEventTouchUpInside];
                //---SMSBtn---//
                [calloutView.SMSBtn setHidden:NO];
                calloutView.SMSBtn.tag = dxAnnotation.annotationIndex;
                [calloutView.SMSBtn addTarget:self action:@selector(makeSMS:) forControlEvents:UIControlEventTouchUpInside];
                if ([_modelManager.user.role intValue] == 1) {
                    [calloutView.setBoundary setHidden:NO];
                    calloutView.setBoundary.tag = dxAnnotation.annotationIndex;
                    [calloutView.setBoundary addTarget:self action:@selector(setBoundaryAction:) forControlEvents:UIControlEventTouchUpInside];
                }
             } else {
                 //---resize calloutview Height---//
                 CGRect tempFrame = calloutView.frame;
                 tempFrame.size.height = 110.0;
                 [calloutView setFrame:tempFrame];

                 [calloutView.callBtn setHidden:YES];
                 [calloutView.SMSBtn setHidden:YES];
                 [calloutView.setBoundary setHidden:YES];
             }

            //---DetailsBtn---//
            calloutView.detailsBtn.tag = dxAnnotation.annotationIndex;
            [calloutView.detailsBtn addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
            //---LocationBriefBtn---//
            calloutView.locationBriefBtn.tag = dxAnnotation.annotationIndex;
            [calloutView.locationBriefBtn addTarget:self action:@selector(showLocationHistory:) forControlEvents:UIControlEventTouchUpInside];
            //---callOut Close Button---//
            //---LocationBriefBtn---//
            calloutView.closeBtn.tag = dxAnnotation.annotationIndex;
            [calloutView.closeBtn addTarget:self action:@selector(closeCallOutView:) forControlEvents:UIControlEventTouchUpInside];
            //---set memberName---//
            if([Common isNullObject:dxAnnotation.memberName] ||
               [dxAnnotation.memberName isEqualToString:NULL_KEY] ||
               [dxAnnotation.memberName isEqualToString:@""]) {
                calloutView.memberNameLbl.text = dxAnnotation.memberUserName;
            } else {
                calloutView.memberNameLbl.text = dxAnnotation.memberName;
            }
            annotationView = [[DXAnnotationView alloc] initWithAnnotation:dxAnnotation
                                                          reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                  pinView:pinView
                                                              calloutView:calloutView
                                                                 settings:[DXAnnotationSettings defaultSettings]];
        } else {
            //---Changing PinView's image to test the recycle---//
            pinView = (UIImageView *)annotationView.pinView;
            UIImage * image2 = [self imageResize:image];
            pinView.image = image2;
//            pinView = [self setImageLayer:pinView isSelect:YES];
            pinView = [self setImageLayer:pinView isSelect:NO];
        }
        return annotationView;
    }
    return nil;
}

/*
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        OCAnnotation *clusterAnnotation = (OCAnnotation *)annotation;

        MKAnnotationView *annotationView1 = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        if (!annotationView1) {
            annotationView1 = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView1.canShowCallout = YES;
            annotationView1.centerOffset = CGPointMake(0, -20);
        }

        // set title
        clusterAnnotation.title = @"Cluster";
        clusterAnnotation.subtitle = [NSString stringWithFormat:@"Containing annotations: %zd", [clusterAnnotation.annotationsInCluster count]];

        // set its image
        UIImage *img = [self drawText:[NSString stringWithFormat:@"%zd", [clusterAnnotation.annotationsInCluster count]]
                              inImage:[UIImage imageNamed:@"ClusterMarker.png"]
                              atPoint:CGPointMake(17,17)];

        //        annotationView.image = [UIImage imageNamed:@"regular.png"];
        annotationView1.image = img;


        // change pin image for group
        if (self.mapView.clusterByGroupTag) {
            if ([clusterAnnotation.groupTag isEqualToString:kTYPE1]) {
                annotationView1.image = [UIImage imageNamed:@"User-Mark-Icon"];
            }
            //            else if([clusterAnnotation.groupTag isEqualToString:kTYPE2]){
            //                annotationView.image = [UIImage imageNamed:@"oranges.png"];
            //            }
            clusterAnnotation.title = clusterAnnotation.groupTag;
        }
        return annotationView1;
    }

    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]){

        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        UIImageView *pinView = nil;
        CalloutView *calloutView = nil;

        DXAnnotationView *annotationView2 = (DXAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];

        if (!annotationView2) {
            annotationView2.canShowCallout = YES;
            annotationView2.centerOffset = CGPointMake(0, -20);
            pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"User-Mark-Icon"]];
            calloutView = (CalloutView*)[[[NSBundle mainBundle] loadNibNamed:@"myView" owner:self options:nil] firstObject];

            if (![singleAnnotation.memberUserName isEqualToString:_modelManager.user.userName]) {
            //---callBtn---//
                [calloutView.callBtn setEnabled:YES];
                calloutView.callBtn.tag = singleAnnotation.annotationIndex;
                [calloutView.callBtn addTarget:self action:@selector(makeCall:) forControlEvents:UIControlEventTouchUpInside];

                //---SMSBtn---//
                [calloutView.SMSBtn setEnabled:YES];
                calloutView.SMSBtn.tag = singleAnnotation.annotationIndex;
                [calloutView.SMSBtn addTarget:self action:@selector(makeSMS:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [calloutView.callBtn setEnabled:NO];
                [calloutView.SMSBtn setEnabled:NO];
            }

            //---DetailsBtn---//
            calloutView.detailsBtn.tag = singleAnnotation.annotationIndex;
            [calloutView.detailsBtn addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
            //---LocationBriefBtn---//
            calloutView.locationBriefBtn.tag = singleAnnotation.annotationIndex;
            [calloutView.locationBriefBtn addTarget:self action:@selector(showLocationHistory:) forControlEvents:UIControlEventTouchUpInside];
            //---set memberName---//
            calloutView.memberNameLbl.text =[NSString stringWithFormat:@"%@-%d",singleAnnotation.memberName,singleAnnotation.annotationIndex] ;

            annotationView2 = [[DXAnnotationView alloc] initWithAnnotation:singleAnnotation
                                                           reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                   pinView:pinView
                                                               calloutView:calloutView
                                                                  settings:[DXAnnotationSettings defaultSettings]];

        } else {
            //---Changing PinView's image to test the recycle---//
            pinView = (UIImageView *)annotationView2.pinView;
            pinView.image = [UIImage imageNamed:@"User-Mark-Icon"];
        }

        //        singleAnnotation.title = singleAnnotation.groupTag;
        //        if ([singleAnnotation.groupTag isEqualToString:kTYPE1]) {
        //            annotationView.image = [UIImage imageNamed:@"User-Mark-Icon"];
        ////            pinView = (UIImageView *)annotationView.pinView;
        ////            pinView.image = [UIImage imageNamed:@"User-Mark-Icon"];
        //        }
        //        else if([singleAnnotation.groupTag isEqualToString:kTYPE2]){
        //            annotationView.image = [UIImage imageNamed:@"orange.png"];
        //        }
        return annotationView2;
    }
    // Error
    else{
        MKPinAnnotationView *annotationView3 = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView3) {
            annotationView3 = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView3.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView3).pinColor = MKPinAnnotationColorRed;
        }
        return annotationView3;
    }
    
}


- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView doClustering];
}
*/

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        DXAnnotationView* dxView = (DXAnnotationView*)view;
        DXAnnotation *dxAnnotation = (DXAnnotation *)dxView.annotation;
//        if ([_modelManager.user.userName isEqualToString:dxAnnotation.memberUserName]) {
//
//        } else {
            for (id<MKAnnotation> annotation in mapView.annotations) {
                DXAnnotationView* anView = (DXAnnotationView*)[mapView viewForAnnotation: annotation];
                if (anView) {
                    DXAnnotationView* dxView = (DXAnnotationView*)anView;
                    UIImageView *pinImage = (UIImageView*)dxView.pinView;
                    // temp block by murtuza
                    //pinImage.image = [UIImage imageNamed:@"User-Mark-Icon"];
                    DXAnnotation *dxAnnotation = (DXAnnotation *)dxView.annotation;
                    
                    if (![_modelManager.user.userName isEqualToString:dxAnnotation.memberUserName]) {
                        UIImage *image = [self getMarkerImage:dxAnnotation.memberUserName];
                        UIImage * image2 = [self imageResize:image];
                        pinImage.image = image2;
                        pinImage = [self setImageLayer:pinImage isSelect:NO];
                    }
                }
            }
            UIImageView *pinImage = (UIImageView*)dxView.pinView;
            UIImage *image = [self getMarkerImage:dxAnnotation.memberUserName];
            UIImage * image2 = [self imageResize:image];
            pinImage.image = image2;
            pinImage = [self setImageLayer:pinImage isSelect:YES];
//        }
        //---reset fullname---//
        CalloutView *callOutView = (CalloutView*)dxView.calloutView;
        if ([Common isNullObject:dxAnnotation.memberName] ||
            [dxAnnotation.memberName isEqualToString:NULL_KEY] ||
            [dxAnnotation.memberName isEqualToString:@""]) {
            callOutView.memberNameLbl.text = dxAnnotation.memberUserName;
        } else {
            callOutView.memberNameLbl.text = dxAnnotation.memberName;
        }
        [self.mapView setCenterCoordinate:dxAnnotation.coordinate animated:YES];
        _dxAnnotationViewShown = (DXAnnotationView *)view;
        _isCallOutShown = YES;
        [((DXAnnotationView *)view)showCalloutView];
        annotaionPosition = view.layer.zPosition;
        view.layer.zPosition = 10;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[DXAnnotationView class]]) {
        DXAnnotationView* dxView = (DXAnnotationView*)view;
        UIImageView *pinImage = (UIImageView*)dxView.pinView;
        DXAnnotation *dxAnnotation = (DXAnnotation *)dxView.annotation;
//        if ([_modelManager.user.userName isEqualToString:dxAnnotation.memberUserName]) {
//        } else {
//            DXAnnotation *dxAnnotation = (DXAnnotation *)dxView.annotation;
            UIImage *image = [self getMarkerImage:dxAnnotation.memberUserName];
            UIImage * image2 = [self imageResize:image];
            pinImage.image = image2;
            pinImage = [self setImageLayer:pinImage isSelect:NO];
//        }
        _isCallOutShown = NO;
        [((DXAnnotationView *)view)hideCalloutView];
//        view.layer.zPosition = -1;
        view.layer.zPosition = annotaionPosition;
    }
}

#pragma mark - jabber login
- (void)loginToJabberServer {
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *userName = [NSString stringWithFormat:@"%@@%@",[userData objectForKey:kUserName],[ModelManager sharedInstance].user.chatSetting.hostName];
    NSString *password = [userData objectForKey:kPasswordKey];
    [ChatLogin storeUser:userName pass:password];
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID_FULL_KEY_SMALL];
    if (login) {
        if ([self.chatManager connect]) {//Trying to connect to jabber server
            NSLog(@"show buddy list");
        }
    } else {
        NSLog(@"Can't Login to Jabber now");
    }
}

#pragma mark - Chat delegate
- (void)newBuddyOnline:(NSString *)buddyName {
   
}

- (void)buddyWentOffline:(NSString *)buddyName {
    
}

- (void)didDisconnect {
    [GlobalData sharedInstance].isJabberLogedIn = NO;
    [GlobalData sharedInstance].roomName = @"";
    [self.chatBtn setEnabled:NO];
}

- (void)didAuthenticate {
    [GlobalData sharedInstance].isJabberLogedIn = YES;
    [GlobalData sharedInstance].roomName = _modelManager.user.chatSetting.roomName; //@"sohan_g_room";
    delegate.isConference = 1;
    [self createChatRoom:[[GlobalData sharedInstance].roomName stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [self.chatBtn setEnabled:YES];
    [[GlobalServiceManager sharedInstance] sendOffLineMessage];
}

#pragma mark -
#pragma mark Sending SMS by iPhoneSDK
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients {
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if (!carrier.isoCountryCode) {
        [self showAlertTitle:NSLocalizedString(@"ALERT",nil) withMessage:NSLocalizedString(@"No SIM Card Installed!",nil)];
    } else {
        if(![MFMessageComposeViewController canSendText]) {
            [self showAlertTitle:@"Error" withMessage:@"Your device doesn't support SMS!"];
            return;
        }
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]) {
            controller.body = bodyOfMessage;
            controller.recipients = recipients;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed: {
                [self showAlertTitle:@"Error" withMessage:@"Failed to send SMS!"];
                break;
            }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Goto anotherVC methods
- (int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
} 

- (void)setStreamNameToWowza {
    streamerConfig = [StreamerConfiguration sharedInstance];
    NSInteger epocTime = (NSInteger)floor([[NSDate date] timeIntervalSince1970] * 1000);
    int randomNumber1 = [self getRandomNumberBetween:0 to:999];
    int randomNumber2 = [self getRandomNumberBetween:0 to:randomNumber1];
    int randomNumber3 = [self getRandomNumberBetween:99 to:999]+randomNumber2;
    NSString *streamName = [NSString stringWithFormat:@"%@_%ld_%d",_modelManager.user.userName,(long)epocTime,randomNumber3];
    [streamerConfig setWowzaStreamName:streamName];
}

- (void)sendSMSPanic:(NSString *)alertTypeStr {
    delegate.isPopUpAtHomeView = NO;
    NSMutableArray *contactArray = [NSMutableArray new];
    if (_modelManager.emergencyContacts.count > 0) {
        for (EmergencyContactModel *contactModel in _modelManager.emergencyContacts) {
            [contactArray addObject:contactModel.contactArray[0]];
        }
    }
    for (MemberData *member in _modelManager.members.rows) {
        if ([Common isNullObject:member.contact]|| [member.contact isEqualToString:@""]) {
            
        } else {
            [contactArray addObject:member.contact];
        }
    }
    if (contactArray.count > 0) {
        NSString *msgStr = @"I am in trouble, Please help me!";
        if ([FamilyTrackerReachibility isUnreachable]) {
            [self sendSMS:msgStr recipientList:contactArray];
            //---Post offlineMsg to local-server---//
            NSMutableDictionary * offlinePanicSMS = [[NSMutableDictionary alloc] init];
            [offlinePanicSMS setValue:kAlert_type_OfflinePanic forKey:kAlert_type];
            [offlinePanicSMS setValue:kAlertResourceTypeOffline forKey:kResourceTypeKey];
            [offlinePanicSMS setValue:[Common getEpochTimeFromDate:[NSDate date]] forKey:Kcreated_at];
            [offlinePanicSMS setValue:[NSString stringWithFormat:@"%f",[GlobalData sharedInstance].userLocation.latitude] forKey:klatitudeKey];
            [offlinePanicSMS setValue:[NSString stringWithFormat:@"%f",[GlobalData sharedInstance].userLocation.longitude] forKey:kLongitudeKey];
            [[DbHelper sharedInstance] insertPanicService:offlinePanicSMS];
        }else {
            [self sendSMS:msgStr recipientList:contactArray];
            [self startStreamingService:alertTypeStr andResourceType:kAlertResourceTypeSMS];
        }
    } else {
        [Common displayToast:NSLocalizedString(@"Please add at leat one contact number!",nil) title:nil duration:1];
    }
}

- (void)sendSnapShotPanic:(NSString *)alertTypeStr {
    NSLog(@"Send SnapShot Panic");
    delegate.isPopUpAtHomeView = NO;
}

- (void)gotoAudioStreamVC:(NSString *)alertTypeStr {
    if(_modelManager.isSilentAudioStreamRunning) {
        [[RemoteMemberControllerManager sharedInstance] remoteAudioStreamingStop];
    }
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    } else {
        if ([AVAudioSession sharedInstance].category != AVAudioSessionCategoryRecord) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord  withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];

            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AudioViewController *audioStreamVC = [sb instantiateViewControllerWithIdentifier:@"AudioViewController"];
        audioStreamVC.alertType = alertTypeStr;
        [self.navigationController pushViewController:audioStreamVC animated:YES];
    }
}

- (void)gotoVideoStreamHome:(NSString *)alertTypeStr {
    if(_modelManager.isSilentAudioStreamRunning) {
        [[RemoteMemberControllerManager sharedInstance] remoteAudioStreamingStop];
    }
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    } else {
        [self setStreamNameToWowza];
        [GlobalData sharedInstance].isLiveStreamingView = YES;
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StreamVideoVC *streamVideoVC = [sb instantiateViewControllerWithIdentifier:@"StreamVideoVC"];
         streamVideoVC.alertType = alertTypeStr;
        [self.navigationController pushViewController:streamVideoVC animated:YES];
    }
}

- (void)gotoContactVC {
    self.title = @"";
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TrialExpiredViewController *trialExpiredVC = [sb instantiateViewControllerWithIdentifier:@"TrialExpiredViewController"];
    [self.navigationController pushViewController:trialExpiredVC animated:YES];
}

-(void)checkboundaryTouch{
    double lat = 0.0,log = 0.0;
    for(MemberLocation *row in _modelManager.memberLocations.rows) {
        if([row.userName isEqualToString:_modelManager.user.userName]) {
            lat = row.latitude;
            log = row.longitude;
            break;
        }
    }
    for(Boundary *row in _modelManager.user.boundaryArray) {
        NSMutableArray * subBounaryAllPoints = [[NSMutableArray alloc] init];
        for(SubBoundary *subBoundary in row.subBoundaryArray) {
            BoundaryLocation * location = subBoundary.location;
            [subBounaryAllPoints addObject:[NSValue valueWithCGPoint:CGPointMake(location.lat,location.log)]];
        }
        CGPoint userPosition = CGPointMake(lat,log);
        BOOL inside = [Algorithms isInsidePolyGon:subBounaryAllPoints andCheckPoint:userPosition];
        if(inside) {
        NSMutableArray * data = [[NSUserDefaults standardUserDefaults] valueForKey:BOUNDARY_TOUCH_DATA];
        if(data.count !=0) {
            NSString *previousBoundayId = [data valueForKey:@"boundaryId"];
            if([previousBoundayId isEqualToString:row.boundary_id]) {
                    // do nothing here
            } else {
                NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                [data setObject:row.boundary_id forKey:@"boundaryId"];
                [data setObject:@"1" forKey:@"boundayTouchFlag"];
                [data setObject:row.boundary_name forKey:@"boundaryName"];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:BOUNDARY_TOUCH_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // alert generate for inside bounday
                [self boundaryAlertService:kAlert_type_bounday_touched andResourceType:kAlertResourceTypeBoundary andBoundayName:row.boundary_name];
            }
        } else {
                NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                [data setObject:row.boundary_id forKey:@"boundaryId"];
                [data setObject:@"1" forKey:@"boundayTouchFlag"];
                [data setObject:row.boundary_name forKey:@"boundaryName"];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:BOUNDARY_TOUCH_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            // alert generate for inside bounday
             [self boundaryAlertService:kAlert_type_bounday_touched andResourceType:kAlertResourceTypeBoundary andBoundayName:row.boundary_name];
        }
            break;
        } else {
            
            NSMutableArray * preData = [[NSUserDefaults standardUserDefaults] valueForKey:BOUNDARY_TOUCH_DATA];
            if(preData.count != 0){
//                NSString *previousBoundayId = [preData valueForKey:@"boundaryId"];
//                NSString *boundayTouchFlag = [preData valueForKey:@"boundayTouchFlag"];
                NSString * boundaryName = [preData valueForKey:@"boundaryName"];
                // alert generate for outside bounday
                 [self boundaryAlertService:kAlert_type_bounday_unTouched andResourceType:kAlertResourceTypeBoundary andBoundayName:boundaryName];
                NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:BOUNDARY_TOUCH_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

-(void)boundaryAlertService :(NSString*)alertTypeValue andResourceType:(NSString*)resourchType andBoundayName:(NSString *)boundayName{
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.guardianId;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kAlert_type:alertTypeValue,
                                  kResourceTypeKey:resourchType,//may be sms
                                  kothersKey: boundayName,
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                       WHEN_KEY:[NSDate date],
                       OBJ_KEY:requestBody
                       };
    [_serviceHandler onOperate:requestBodyDic];
}


#pragma - mark toolTips start
- (void)dismissAllPopTipViews {
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}

#pragma mark - CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}

#pragma mark - UIViewController methods
- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
    for (CMPopTipView *popTipView in self.visiblePopTipViews) {
        id targetObject = popTipView.targetObject;
        [popTipView dismissAnimated:NO];
        
        if ([targetObject isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)targetObject;
            [popTipView presentPointingAtView:button inView:self.view animated:NO];
        }
        else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
        }
    }
}

-(void)chooseLocationHideShowOption:(UIButton *)sender{
    NSString * buttonText = @"";
     if (_isLodationHide) {
         buttonText = NSLocalizedString(@"Show location",nil);
     } else {
         buttonText = NSLocalizedString(@"Hide location",nil);
     }
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* profileUpdateMenu = [UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                           if (_isLodationHide) {
                                           _isLodationHide = NO;
                                           [self locationHideByMemberSevice:[NSNumber numberWithBool:false]];
                                           } else {
                                           _isLodationHide = YES;
                                           [self locationHideByMemberSevice:[NSNumber numberWithBool:true]];
                                           }
                                                              }];
    [alert addAction:profileUpdateMenu];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // only for iphone
    {
        UIAlertAction* cancelMenu = [UIAlertAction actionWithTitle:NSLocalizedString(kCancel,nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                           }];
        [alert addAction:cancelMenu];
    }
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma - mark toolTips end
- (void)checkStatus {
    NSString *_status = @"";
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status==kCLAuthorizationStatusNotDetermined) {
        _status = @"Not Determined";
        [self requestAlwaysAuth];
    }
    if (status==kCLAuthorizationStatusDenied) {
        _status = @"Denied";
        [self requestAlwaysAuth];
    }
    if (status==kCLAuthorizationStatusRestricted) {
        _status = @"Restricted";
        [self requestAlwaysAuth];
    }
    if (status==kCLAuthorizationStatusAuthorizedAlways) {
        _status = @"Always Allowed";
    }
    if (status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        _status = @"When In Use Allowed";
    }
}

//if location updates are denied or set to only when in use
//the user has to explictly change permissions in SETTINGS
- (void)requestAlwaysAuth {
    static BOOL isLocationServiceSettingShown = NO;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status==kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString*title;
        title=(status == kCLAuthorizationStatusDenied) ? @"Location Services Are Off" : @"Background use is not enabled";
        UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:@"Go to settings" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settingAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Settings",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       isLocationServiceSettingShown = NO;
                                       NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                       [[UIApplication sharedApplication]openURL:settingsURL];
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                          isLocationServiceSettingShown = NO;
                                        }];
        [alertController addAction:cancelAction];
        [alertController addAction:settingAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (status==kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

@end
