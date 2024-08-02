//
//  AppDelegate.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/4/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//
//
//  AppDelegate.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 17/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"
#import "Common.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "IQKeyboardManager.h"
#import "StreamerConfiguration.h"
#import "Constant.h"
#import "VLCConstants.h"
#import "FamilyTrackerDefine.h"
#import "GlobalServiceManager.h"
#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "JsonUtil.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "AudioViewController.h"
#include "StreamVideoVC.h"
#include "RemoteMemberControllerManager.h"
#import "AlertViewController.h"
#import "Firebase.h"
#import "Boundary.h"
#import "SubBoundary.h"
#import "PanicAlertStatus.h"
#import "BatteryStatManager.h"
@import FirebaseMessaging;

#define AppVersion @"AppVersion"

@interface AppDelegate ()<AVAudioPlayerDelegate,SWRevealViewControllerDelegate, FIRMessagingDelegate> {
    AVPlayerItem *itemAlert;
    GlobalServiceManager *globalServiceManager;
}
@property (assign) BOOL backgroundMusicInterrupted;
@property (assign) BOOL isInternetStateChange;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    globalServiceManager = [GlobalServiceManager sharedInstance];
    _resourcePath = [[NSBundle mainBundle] resourcePath];
    _resourcePath = [_resourcePath stringByAppendingString:@"/panic_alert.mp3"];
//    NSLog(@"Path to play: %@", _resourcePath);
    // Override point for customization after application launch.
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        [Common displayToast:BACKGROUND_APP_REFRESH_DENIED title:nil];
    } else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        [Common displayToast:BACKGROUND_APP_REFRESH_DISABLED title:nil];
    } else {
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        //Send the best location to server every 60 seconds
        //You may adjust the time interval depends on the need of your app.
        NSTimeInterval time = kSaveLocationInterval;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
    }
    [self setApplicationAppearance];
    [IQKeyboardManager sharedManager].enable = true;
    //---UILocalNotificationSettings---//
    UIMutableUserNotificationAction* dismissAction = [[UIMutableUserNotificationAction alloc] init];
    [dismissAction setIdentifier:@"dismiss_action_id"];
    [dismissAction setTitle:@"Dismiss"];
    [dismissAction setActivationMode:UIUserNotificationActivationModeBackground];
    [dismissAction setDestructive:YES];
    UIMutableUserNotificationAction* openAction = [[UIMutableUserNotificationAction alloc] init];
    [openAction setIdentifier:@"open_action_id"];
    [openAction setTitle:@"Open"];
    [openAction setActivationMode:UIUserNotificationActivationModeForeground];
    [openAction setDestructive:NO];
    UIMutableUserNotificationCategory* deleteReplyCategory = [[UIMutableUserNotificationCategory alloc] init];
    [deleteReplyCategory setIdentifier:@"custom_category_id"];
    [deleteReplyCategory setActions:@[openAction, dismissAction] forContext:UIUserNotificationActionContextDefault];
    NSSet* categories = [NSSet setWithArray:@[deleteReplyCategory]];
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    //---Set Panic Music---//
    [self playPanicInBackground];
    [self.player2 play];
    [self setVolumeZero];
    //---for StreamingConfiguration ---//
    StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
    [streamerConfig setDefaultConfiguration];
    [self saveDeviceInfomation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([defaults valueForKey:AppVersion] != nil) {
        if (![[NSString stringWithFormat:@"%@",[defaults valueForKey:AppVersion]] isEqualToString:version]) {
            [defaults setObject:version forKey:AppVersion];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else {
        [defaults setObject:version forKey:AppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSDictionary *appDefaults = @{kVLCSettingPasscodeKey : @"", kVLCSettingPasscodeOnKey : @(NO), kVLCSettingStretchAudio : @(NO), kVLCSettingTextEncoding : kVLCSettingTextEncodingDefaultValue, kVLCSettingSubtitlesFont : kVLCSettingSubtitlesFontDefaultValue, kVLCSettingSubtitlesFontColor : kVLCSettingSubtitlesFontColorDefaultValue, kVLCSettingSubtitlesFontSize : kVLCSettingSubtitlesFontSizeDefaultValue, kVLCSettingDeinterlace : kVLCSettingDeinterlaceDefaultValue};
    [defaults registerDefaults:appDefaults];
    //---Wowza server settings---//
    [streamerConfig setWowzaServerIP:@"182.16.159.204"];
    [streamerConfig setWowzaServerPort:@"1935"];
    [streamerConfig setWowzaUsername:@"publisher20"];
    [streamerConfig setWowzaPassword:@"12345"];
    [streamerConfig setWowzaApplication:@"FamilyTracker"];
    [streamerConfig setWowzaStreamName:@"myStream"];
    ///
    [streamerConfig setSelectedBitRate:kVideoBitRate500KBPS];
    [streamerConfig setFrameRate:kVideoFrameRate15FTP];
    [streamerConfig setResolution:kVideoResolution640x480];
    [streamerConfig setStreamBehaviorType:kStreamBehaviorTypeClient];
//  [streamerConfig setStreamType:kStreamTypeVideoOnly];
    [streamerConfig setStreamType:kStreamTypeAudioVideo];
    //---End for StreamingConfiguration ---//
    User *offLineUser = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:NSStringFromClass([User class])];
    if ([Common isNullObject:offLineUser.sessionToken]||
        offLineUser.sessionToken.length < 1) {
        //NSLog(@"Goto login");
    } else {
        ModelManager *_modelManager = [ModelManager sharedInstance];
        _modelManager.user = offLineUser;
        [globalServiceManager syncOfflineData];
        [ModelManager sharedInstance].currentVCName = @"AppDelegate";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        HomeViewController *homeViewController = [sb instantiateViewControllerWithIdentifier:HOME_VIEW_CONTROLLER_KEY];
        MenuViewController *menuViewController = [sb instantiateViewControllerWithIdentifier:MENU_VIEW_CONTROLLER_KEY];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:nil frontViewController:frontNavigationController];
        revealController.delegate = self;
        revealController.rightViewController = menuViewController;
        self.window.rootViewController = revealController;
        [self.window makeKeyAndVisible];
    }
    
    //BatteryStatManager---//
    BatteryStatManager *battState = [BatteryStatManager sharedInstance];
    //---Old Try for firebase
    //---firebase configration
     [FIRApp configure];
    // Add an observer for handling a token refresh callback
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];
    // Request Permission for Notification from the user
    UIUserNotificationType allNOtificationType = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings12 = [UIUserNotificationSettings settingsForTypes:allNOtificationType categories:nil];
    [application registerUserNotificationSettings:settings12];
    [application registerForRemoteNotifications];
    //wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval:2.0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[FIRMessaging messaging] disconnect];
//    NSLog(@"Disconnected from FCM");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language isEqual:@"bn-US"] || [language isEqual:@"bn-BD"]) {
        language = BANGLA_LANGUAGE;
    }
    else if([language isEqual:@"en"] || [language isEqual:@"en-US"]) {
        language = ENGLISH_LANGUAGE;
    }
    else {
        language = ENGLISH_LANGUAGE;
    }
    [ModelManager sharedInstance].defaultLanguage = language;
    [self connectToFcm];
    if([[ModelManager sharedInstance].currentVCName isEqualToString:@"HomeViewController"]) {
        if([ModelManager sharedInstance].isPanicRunning) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"panicBackgroundChange"
             object:nil];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark UILocalNotification Delegates
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self openSpacificVC:notification];
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    if([notification.category isEqualToString:@"custom_category_id"]) {
        if([identifier isEqualToString:@"dismiss_action_id"]) {
            //NSLog(@"Dismiss was pressed");
        }else if([identifier isEqualToString:@"open_action_id"]) {
            [self openSpacificVC:notification];
        }
    }
    application.applicationIconBadgeNumber = 0;
    //	Important to call this when finished
    completionHandler();
}

- (void)openSpacificVC:(UILocalNotification *)notification {
    NSString *alertTypeStr = [notification.userInfo valueForKey:kAlert_type];
    if ([alertTypeStr isEqualToString:kAlert_type_chat]) {
        [globalServiceManager gotoChatViewController];
    }else if ([alertTypeStr isEqualToString:kAlert_type_panic]) {
        [self setVolumeZero];
        [globalServiceManager acknowledgeNewAlertService];
        [globalServiceManager acknowledgedReadAlertService:[notification.userInfo valueForKey:kIdentifier]];
        //Check Streaming contentType---//
        NSString *contentType = [notification.userInfo valueForKey:kLink];
        contentType = [contentType substringToIndex:4];
        if ([contentType isEqualToString:@"http"]) {
            [[GlobalServiceManager sharedInstance] gotoPlayAudioStream:[notification.userInfo valueForKey:kLink] andId:[notification.userInfo valueForKey:kIdentifier]];
        }else {
            [[GlobalServiceManager sharedInstance] gotoPlayVideoStream:[notification.userInfo valueForKey:kLink]];
        }
    }else if ([alertTypeStr isEqualToString:kAlert_type_roleChange]) {
        //
    }else if ([alertTypeStr isEqualToString:kAlert_type_videoStreaming]) {
        [globalServiceManager acknowledgeNewAlertService];
        [globalServiceManager acknowledgedReadAlertService:[notification.userInfo valueForKey:kIdentifier]];
        [globalServiceManager gotoPlayVideoStream:[notification.userInfo valueForKey:kLink]];
    }else if ([alertTypeStr isEqualToString:kAlert_type_audioStreaming]) {
        [globalServiceManager acknowledgeNewAlertService];
        [globalServiceManager acknowledgedReadAlertService:[notification.userInfo valueForKey:kIdentifier]];
        [globalServiceManager gotoPlayAudioStream:[notification.userInfo valueForKey:kLink] andId:[notification.userInfo valueForKey:kIdentifier]];
    } else if([alertTypeStr isEqualToString:kAlert_type_bounday_unTouched] || [alertTypeStr isEqualToString:kAlert_type_bounday_touched]) {
        [globalServiceManager acknowledgeNewAlertService];
        [globalServiceManager acknowledgedReadAlertService:[notification.userInfo valueForKey:kIdentifier]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self setVolumeZero];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        AlertViewController *alertSubViewController1 = (AlertViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AlertViewController"];
        [[GlobalData sharedInstance].currentVC.navigationController pushViewController:alertSubViewController1 animated:YES];
        
    }
}

#pragma mark User Defined Methods
- (void)updateLocation {
    [self.locationTracker updateLocationToServer];
}

- (void)setApplicationAppearance {
    [[UINavigationBar appearance] setBarTintColor:[HexToRGB colorForHex:SYSTEM_NAV_COLOR]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

#pragma mark - Local Methods -
- (void)manuallyTerminatingApp {
    //home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    //wait 2 seconds while app is going background
    //    [NSThread sleepForTimeInterval:2.0];
    //exit app when app is in background
    exit(0);
}

#pragma mark - User Defined Methods -
- (void)saveDeviceInfomation {
    NSString* Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    NSString *modelName = [[self getModel] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *hardwearID = [self getMacAddress];
    NSDictionary *deviceData = @{@"modelName":modelName, @"hardwearId": hardwearID, @"deviceUUID":Identifier};
    StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
    [streamerConfig setDefaultDeviceConfiguration:deviceData];
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *code = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    NSDictionary *deviceNamesByCode = @{@"i386"      :@"Simulator",
                                        @"x86_64"    :@"Simulator",
                                        @"iPod1,1"   :@"iPod Touch",      // (Original)
                                        @"iPod2,1"   :@"iPod Touch (2nd gen)",      // (Second Generation)
                                        @"iPod3,1"   :@"iPod Touch (3rd gen)",      // (Third Generation)
                                        @"iPod4,1"   :@"iPod Touch (4th gen)",      // (Fourth Generation)
                                        @"iPod5,1"   :@"iPod Touch (5th gen)",      // (Fifth Generation)
                                        @"iPod7,1"   :@"iPod Touch (6th gen)",      // (6th Generation)
                                        @"iPhone1,1" :@"iPhone",          // (Original)
                                        @"iPhone1,2" :@"iPhone",          // (3G)
                                        @"iPhone2,1" :@"iPhone",          // (3GS)
                                        @"iPhone3,1" :@"iPhone 4 (GSM)",        // (GSM)
                                        @"iPhone3,3" :@"iPhone 4 (CDMA)",        // (CDMA/Verizon/Sprint)
                                        @"iPhone4,1" :@"iPhone 4S",       //
                                        @"iPhone5,1" :@"iPhone 5 (A1428)",        // (model A1428, AT&T/Canada)
                                        @"iPhone5,2" :@"iPhone 5 (A1429)",        // (model A1429, everything else)
                                        @"iPhone5,3" :@"iPhone 5c (A1456/A1532)",       // (model A1456, A1532 | GSM)
                                        @"iPhone5,4" :@"iPhone 5c (A1507/A1516/A1529)",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                                        @"iPhone6,1" :@"iPhone 5s (A1433/A1453)",       // (model A1433, A1533 | GSM)
                                        @"iPhone6,2" :@"iPhone 5s (A1457/A1518/A1530)",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                                        @"iPhone7,1" :@"iPhone 6 Plus",   //
                                        @"iPhone7,2" :@"iPhone 6",        //
                                        @"iPhone8,1" :@"iPhone 6s",       //
                                        @"iPhone8,2" :@"iPhone 6s Plus",  //
                                        
                                        @"iPad1,1"   :@"iPad",            // (Original)
                                        @"iPad2,1"   :@"iPad 2",          //
                                        @"iPad2,5"   :@"iPad Mini",       // (Original)
                                        
                                        @"iPad3,1"   :@"iPad",            // (3rd Generation)
                                        @"iPad3,4"   :@"iPad",            // (4th Generation)
                                        @"iPad4,1"   :@"iPad Air (Wi-Fi)",        // 5th Generation iPad (iPad Air) - Wifi
                                        @"iPad4,2"   :@"iPad Air (Wi-Fi+LTE)",        // 5th Generation iPad (iPad Air) - Cellular
                                        @"iPad4,4"   :@"iPad Mini 2 (Wi-Fi)",       // (2nd Generation iPad Mini - Wifi)
                                        @"iPad4,5"   :@"iPad Mini 2 (Wi-Fi+LTE)",       // (2nd Generation iPad Mini - Cellular)
                                        @"iPad4,7"   :@"iPad mini 3 (Wi-Fi)",        // (3rd Generation iPad Mini - Wifi (model A1599))
                                        @"iPad5,1"   :@"iPad mini 4 (Wi-Fi)",
                                        @"iPad5,2"   :@"iPad mini 4 (Wi-Fi+LTE)",
                                        @"iPad5,3"   :@"iPad Air 2 (Wi-Fi)",
                                        @"iPad5,4"   :@"iPad Air 2 (Wi-Fi+LTE)",
                                        @"iPad6,7"   :@"iPad Pro (Wi-Fi)",
                                        @"iPad6,8"   :@"iPad Pro (Wi-Fi+LTE)"
                                        };
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    return deviceName;
}

- (NSString *)getMacAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}

#pragma mark - PanicAlert - Play/Stop
- (void)playPanicInBackground {
    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
     //Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    itemAlert = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"panic_alert" withExtension:@"mp3"]];
    NSArray *queue = @[itemAlert];
    self.player2 = [[AVQueuePlayer alloc] initWithItems:queue];
    self.player2.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    [self.player2 addObserver:self
                   forKeyPath:@"currentItem"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        //NSString *timeString = [NSString stringWithFormat:@"%02.2f", (float)time.value / (float)time.timescale];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            //self.lblMusicTime.text = timeString;
        }else {
            //NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    self.timeObserver = [self.player2 addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:observerBlock];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([[self.player2 items] count] == 0) {
        [self doReplay:YES];
    }
}

-(void)doReplay:(BOOL)insertLastItem {
    if (insertLastItem) {
        [self.player2 insertItem:itemAlert afterItem:nil];
    }
    [self.player2 seekToTime:kCMTimeZero];
    //NSLog(@"Playing %@",[self.player2.items lastObject]);
    if(![self isPlaying]) {
        //[self.player2 play];
    }
}

- (BOOL)isPlaying {
    return self.player2.rate > 0;
}

- (void)setVolumeUp {
    [_player2 setVolume:1.0f];
    [ModelManager sharedInstance].isPanicRunning = YES;
}

- (void)setVolumeZero {
    [_player2 setVolume:0.0f];
    [ModelManager sharedInstance].isPanicRunning = NO;
}

#pragma mark - Short Notification Sound
- (void)playPanicAlert {
    NSError* err;
    //Initialize our player pointing to the path to our resource
    NSString *notiSound = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/sms-received.wav"];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:
               [NSURL fileURLWithPath:notiSound] error:&err];
    if ( err ) {
        //bail!
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    } else {
        //set our delegate and begin playback
        _player.delegate = self;
        [_player play];
//        _player.numberOfLoops = -1;
        _player.currentTime = 0;
        [_player setVolume:1.0];
    }
    //---To Turn On iPhone Speaker---//
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
}

- (void)stopPanicAlert {
    [_player stop];
    _player = nil;
    //---To Turn Off iPhone Speaker---//
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
}

#pragma mark - AVAudioPlayerDelegate methods -
- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    self.backgroundMusicInterrupted = YES;
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags {
    //[self PlayPanicAlert];
    self.backgroundMusicInterrupted = NO;
}

- (void)showHideIQKeyboard:(BOOL)status {
    [IQKeyboardManager sharedManager].enable = status;
}

#pragma mark - TrialPreriod
-(void)startTrialExpiredTimer:(NSString *)message {
    if(_trialExpiredTimer) {
        [_trialExpiredTimer invalidate];
        _trialExpiredTimer = nil;
    }
    _previousAlertMessagePanding = NO;
    _trialExpiredTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(trialExpireMessage:) userInfo:message repeats:YES];
}

- (void)trialExpireMessage:(NSTimer*)theTimer {
    if(_previousAlertMessagePanding == NO) {
        _previousAlertMessagePanding = YES;
        UIAlertView *trialMessageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:[theTimer userInfo] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [trialMessageAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        _previousAlertMessagePanding = NO;
    }
}

#pragma mark -- Firebase CallBack
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"Message ID: %@",userInfo[@"gcm.message_id"]);
    NSLog(@"%@",userInfo);
    // if user is not login
    User *userModel = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:NSStringFromClass([User class])];
    if ([Common isNullObject:userModel.sessionToken] ||
        userModel.sessionToken.length < 1) {
        return;
    }
    @try {
        NSMutableString * bodyStr = [userInfo valueForKey:@"payload"];
        NSData *bodyNSData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *body = [NSJSONSerialization JSONObjectWithData:bodyNSData options:0 error:&err];
        int pushNotificationType = [[userInfo valueForKey:@"type"] intValue];
        if(pushNotificationType == 1) { //For All Alert
            [self pushNotificationForAlert:body];
        } else if(pushNotificationType == 2) { //For New User Create
            [self pushNotificationTypeForUser:body];
        } else if(pushNotificationType == 3) { // For New Boundary add and Edit on map
            [self pushNotificationForBoudnary:body];
        } else if(pushNotificationType == 4) { // For Others Message
            [self pushNotificationForMessage:body];
        } else if(pushNotificationType == 5) { // For map boundary remove
            [self pushNotificationForRemoveBoundary:body];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - Custom Firebase code
- (void)tokenRefreshNotification:(NSNotification *)notification {
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@",refreshedToken);
    if([Common isNullObject:refreshedToken] || refreshedToken.length ==0) {
    } else {
        NSString *preFirebaseToken = [[NSUserDefaults standardUserDefaults] valueForKey:kFirebaseToken];
        if(![preFirebaseToken isEqualToString:refreshedToken]) {
            [ModelManager sharedInstance].firebaseToken = refreshedToken;
            [[NSUserDefaults standardUserDefaults] setValue:refreshedToken forKey:kFirebaseToken];
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:IsFirebaseTokenRegSuccess];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([Common isNullObject:[ModelManager sharedInstance].user.sessionToken] ||
                [ModelManager sharedInstance].user.sessionToken.length < 1) {
            } else {
                [[GlobalServiceManager sharedInstance] deviceRegistrationForPushNotification];
            }
        }
    }
    // Connect to FCM since connection may have failed when attemped before having a token.
    [self connectToFcm];
}

- (void)connectToFcm {
    /*
     // Won't connect since there is no token
     if (![[FIRInstanceID instanceID] token]) {
     return;
     }
     // Disconnect previous FCM connection if it exists.
     [[FIRMessaging messaging] disconnect];
     */
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// With "FirebaseAppDelegateProxyEnabled": NO
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeSandbox];
//    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
//                                        type:FIRInstanceIDAPNSTokenTypeProd];
}

#pragma mark - pushNotificatin for alert
-(void) pushNotificationForAlert:(NSDictionary *)body {
    @try {
        User *userModel = [JsonUtil loadObject:NSStringFromClass([User class]) withFile:NSStringFromClass([User class])];
        ModelManager * modelManager = [ModelManager sharedInstance];
        NSString *family_id =@"";
        NSString *created_user = @"";
        NSString *link = @"";
        NSString *alertTypeStr = @"";
        NSString *resource_type = @"";
        NSString *alertId = @"";
        NSString *user_id = @"";
        NSString *message_title = @"";
        NSString * ref_id = @"";
        if([body valueForKey:@"family_id"]) {
            family_id = [body valueForKey:@"family_id"];
        }
        if([body valueForKey:@"created_user"]) {
            created_user = [body valueForKey:@"created_user"];
        }
        if([body valueForKey:@"link"]) {
            link = [body valueForKey:@"link"];
        }
        if([body valueForKey:@"alert_type"]) {
            alertTypeStr =[NSString stringWithFormat:@"%@",[body valueForKey:@"alert_type"]];
        }
        if([body valueForKey:@"resource_type"]) {
            resource_type = [body valueForKey:@"resource_type"];
        }
        if([body valueForKey:@"id"]) {
            alertId = [body valueForKey:@"id"];
        }
        if([body valueForKey:@"user_id"]) {
            user_id = [body valueForKey:@"user_id"];
        }
        if([body valueForKey:@"ref_id"]) {
            ref_id = [body valueForKey:@"ref_id"];
        }
        if([body valueForKey:@"message_title"][[ModelManager sharedInstance].defaultLanguage]) {
            message_title = [body valueForKey:@"message_title"][[ModelManager sharedInstance].defaultLanguage];
        }
        // if family id is not same then return
        if(![userModel.guardianId isEqualToString:family_id]) {
            return;
        }
        //alert type Acknowledge
        if([alertTypeStr isEqualToString:kAlert_type_acknowledge_alert]) {
            NSString * listnerUserName = [Common getUserName:created_user];
            if(_listnerLists == nil) {
                _listnerLists = [[NSMutableArray alloc] init];
            }
            // check all add this name
            BOOL foundName = NO;
            for(int i = 0;i<[_listnerLists count]; i++) {
                NSString *name = [_listnerLists objectAtIndex:i];
                if([name isEqualToString:listnerUserName]) {
                    foundName = YES;
                    break;
                }
            }
            if(!foundName) {
                [_listnerLists addObject:listnerUserName];
            }
            NSString *message = @"";
            if([_listnerLists count] == 0) {
                message = @"Currently no one listening";
            } else {
                message = @"Currently listening";
                for(int i = 0; i<[_listnerLists count];i++) {
                    NSString *name = [_listnerLists objectAtIndex:i];
                    if(i == 0) {
                        message = [NSString stringWithFormat:@"%@ %@",message,name];
                    } else {
                     message = [NSString stringWithFormat:@"%@,%@",message,name];
                    }
                }
            }
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  message,
                                  acknowledge_message_key,
                                  nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"acknowledgeChangeNotification"
             object:nil userInfo:dict];
        }
        if([alertTypeStr isEqualToString:kAlert_type_stop_listening]) {
            NSString * listnerUserName = [Common getUserName:created_user];
            for(int i = 0;i<[_listnerLists count]; i++) {
                NSString *name = [_listnerLists objectAtIndex:i];
                if([name isEqualToString:listnerUserName]) {
                    [_listnerLists removeObjectAtIndex:i];
                    break;
                }
            }
            NSString *message = @"";
            if([_listnerLists count] == 0) {
                message = @"Currently no one listening";
            } else {
                message = @"Currently listening";
                for(int i = 0; i<[_listnerLists count];i++) {
                    NSString *name = [_listnerLists objectAtIndex:i];
                    if(i == 0) {
                        message = [NSString stringWithFormat:@"%@ %@",message,name];
                    } else {
                        message = [NSString stringWithFormat:@"%@,%@",message,name];
                    }
                }
            }
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  message,
                                  acknowledge_message_key,
                                  nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"acknowledgeChangeNotification"
             object:nil userInfo:dict];
        }
        // check for silen audio streaming On or Off notification. this logic same for forground and background
        if([alertTypeStr isEqualToString:kAlert_type_silent_audio_streaming_on]){
            if(![ModelManager sharedInstance].isSilentAudioStreamRunning && ![[GlobalData sharedInstance].currentVC isKindOfClass:[AudioViewController class]] && ![[GlobalData sharedInstance].currentVC isKindOfClass:[StreamVideoVC class]]) {
                [[RemoteMemberControllerManager sharedInstance] remoteAudioStreamingStart];
                [ModelManager sharedInstance].silentAudioStreamingIdentifier = alertId;
                [ModelManager sharedInstance].silentAudioStreamingFamilyId = family_id;
                [ModelManager sharedInstance].silentAudioStreamingCreatedUser = user_id;
                return;
            }
        }
        else if([alertTypeStr isEqualToString:kAlert_type_silent_audio_streaming_off]){
            if([ModelManager sharedInstance].isSilentAudioStreamRunning) {
                [[RemoteMemberControllerManager sharedInstance] remoteAudioStreamingStop];
                return;
            }
        }
        // audio or video streaming time out notification
        if ([alertTypeStr isEqualToString:kAlertType_TimeOut]) {
            if ([GlobalData sharedInstance].isInPanic) {
                [GlobalData sharedInstance].isInPanic = NO;
            }
            if([[GlobalData sharedInstance].currentVC isKindOfClass:[AudioViewController class]]) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"stopAudioStreamingNotification"
                 object:nil];
                return;
            }else if([[GlobalData sharedInstance].currentVC isKindOfClass:[StreamVideoVC class]]) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"stopVideoStreamingNotification"
                 object:nil];
                return;
            }
        }
        // here handle forground and background
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
            UILocalNotification * notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
            notification.timeZone = [[NSCalendar currentCalendar] timeZone];
            if ([Common isNullObject:message_title]) {
            }else {
                notification.alertBody = message_title;
            }
            //---check empty link
            NSString *urlLinkStr = @"";
            if ([Common isNullObject:link]) {
                urlLinkStr = @"";
            }else {
                urlLinkStr = link;
            }
            notification.hasAction = YES;
            notification.alertAction = NSLocalizedString(@"View", nil);
            [notification setCategory:@"custom_category_id"];
            //Third part
            if ([alertTypeStr isEqualToString:kAlert_type_panic]) {
                if ([modelManager.user.settings[kPanicAlertPermission] boolValue]) {
                    if(urlLinkStr.length>0) {
                        _listnerLists = nil;
                        [self setVolumeUp];
                    } else {
                        [ModelManager sharedInstance].isPanicStop = YES;
                    }
                    notification.userInfo = @{kAlert_type : kAlert_type_panic,
                                              kLink : urlLinkStr,
                                              kIdentifier :alertId};
                    PanicAlertStatus *panicAlertStatus = [[PanicAlertStatus alloc] init];
                    panicAlertStatus.panicId = alertId;
                    panicAlertStatus.userId = created_user;
                    panicAlertStatus.userName = [Common getUserName:created_user];
                    panicAlertStatus.status = @"1";
                    panicAlertStatus.alreadyRed = @"0";
                    [[ModelManager sharedInstance].runningPanics addObject:panicAlertStatus];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"panicMarkerImageChange"
                     object:nil];
                    
                    //--2nd part of notification
                    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                    int totalNoti = (int) [[ModelManager sharedInstance].totalNewAlerts integerValue]+ 1;
                    [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:totalNoti];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"AlertBatchNotification"
                     object:nil];
                    [ModelManager sharedInstance].currentPanicText = [NSString stringWithFormat:@"%@ %@",[Common getUserName:created_user],message_title];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"panicBackgroundChange"
                     object:nil];
                }
            } else if([alertTypeStr isEqualToString:kAlert_type_bounday_touched] || ([alertTypeStr isEqualToString:kAlert_type_bounday_unTouched])) {
                if ([modelManager.user.settings[kPanicAlertPermission] boolValue]) {
                    [self setVolumeUp];
                    if([alertTypeStr isEqualToString:kAlert_type_bounday_touched]){
                        notification.userInfo = @{kAlert_type : kAlert_type_bounday_touched,
                                                  kLink : urlLinkStr,
                                                  kIdentifier :alertId};
                    } else {
                        notification.userInfo = @{kAlert_type : kAlert_type_bounday_unTouched,
                                                  kLink : urlLinkStr,
                                                  kIdentifier :alertId};
                    }
                    //--2nd part of notification
                    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }
            else {
                if ([alertTypeStr isEqualToString:kAlert_type_videoStreaming]) {
                    notification.soundName = @"ReceivedMessage.wav";
                    notification.userInfo = @{kAlert_type : alertTypeStr,
                                              kLink : urlLinkStr,
                                              kIdentifier : alertId};
                }else if ([alertTypeStr isEqualToString:kAlert_type_audioStreaming]) {
                    _listnerLists = [[NSMutableArray alloc] init];
                    notification.soundName = @"ReceivedMessage.wav";
                    notification.userInfo = @{kAlert_type :alertTypeStr,
                                              kLink : urlLinkStr,
                                              kIdentifier : alertId};
                }else {
                    notification.soundName = @"ReceivedMessage.wav";
                    notification.userInfo = @{kAlert_type : kAlert_type_other,
                                              kLink : urlLinkStr};
                    
                    // murtuza here
                    ModelManager *manager = [ModelManager sharedInstance];
                    for(int j = 0; j<manager.runningPanics.count; j++) {
                        PanicAlertStatus *panicAlertStatus = [manager.runningPanics objectAtIndex:j];
                        if([panicAlertStatus.panicId isEqualToString:ref_id]) {
                            [manager.runningPanics removeObject:panicAlertStatus];
                            break;
                        }
                    }
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"panicMarkerImageChange"
                     object:nil];
                }
                //--2nd part of notification
                notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                
                int notification = (int)[[ModelManager sharedInstance].totalNewAlerts integerValue] + 1;
                [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:notification];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"AlertBatchNotification"
                 object:nil];
            }
        }else {
            if ([alertTypeStr isEqualToString:kAlert_type_panic]) {
                if ([[ModelManager sharedInstance].user.settings[kPanicAlertPermission] boolValue]) {
                    if([ModelManager sharedInstance].isSilentAudioStreamRunning) {
                        [[RemoteMemberControllerManager sharedInstance] remoteAudioStreamingStop];
                    }
                    if(link.length > 0) {
                        _listnerLists = nil;
                        [self setVolumeUp];
                        PanicAlertStatus *panicAlertStatus = [[PanicAlertStatus alloc] init];
                        panicAlertStatus.panicId = alertId;
                        panicAlertStatus.userId = created_user;
                        panicAlertStatus.userName = [Common getUserName:created_user];
                        panicAlertStatus.status = @"1";
                        panicAlertStatus.alreadyRed = @"0";
                        [[ModelManager sharedInstance].runningPanics addObject:panicAlertStatus];
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"panicMarkerImageChange"
                         object:nil];
                    } else {
                        [ModelManager sharedInstance].isPanicStop = YES;
                    }
                    int totalNoti = (int) [[ModelManager sharedInstance].totalNewAlerts integerValue]+ 1;
                    [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:totalNoti];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"AlertBatchNotification"
                     object:nil];
                    [ModelManager sharedInstance].currentPanicText = [NSString stringWithFormat:@"%@ %@",[Common getUserName:created_user],message_title];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"panicBackgroundChange"
                     object:nil];
                }
            }
            else if([alertTypeStr isEqualToString:kAlert_type_bounday_touched] || ([alertTypeStr isEqualToString:kAlert_type_bounday_unTouched])) {
                if ([[ModelManager sharedInstance].user.settings[kPanicAlertPermission] boolValue]) {
                    [self setVolumeUp];
                    int totalNoti = (int)[[ModelManager sharedInstance].totalNewAlerts integerValue] + 1;
                    [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:totalNoti];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"AlertBatchNotification"
                     object:nil];
                }
            } else if ([alertTypeStr isEqualToString:kAlert_type_audioStreaming]) {
                _listnerLists = [[NSMutableArray alloc] init];
                [self playPanicAlert];
                int notification = (int)[[ModelManager sharedInstance].totalNewAlerts integerValue] + 1;
                [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:notification];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"AlertBatchNotification"
                 object:nil];
            } else if([alertTypeStr isEqualToString:kAlert_type_stop]) {
                if ([modelManager.user.settings[kPanicAlertPermission] boolValue]) {
                    [self playPanicAlert];
                    int notification = (int)[[ModelManager sharedInstance].totalNewAlerts integerValue] + 1;
                    [ModelManager sharedInstance].totalNewAlerts = [NSNumber numberWithInt:notification];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"AlertBatchNotification"
                     object:nil];
                    // murtuza here
                    ModelManager *manager = [ModelManager sharedInstance];
                    for(int j = 0; j<manager.runningPanics.count; j++) {
                        PanicAlertStatus *panicAlertStatus = [manager.runningPanics objectAtIndex:j];
                        if([panicAlertStatus.panicId isEqualToString:ref_id]) {
                            [manager.runningPanics removeObject:panicAlertStatus];
                            break;
                        }
                    }
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"panicMarkerImageChange"
                     object:nil];
                }
            }
        }
    }@catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - pushNotificationForUser
-(void)pushNotificationTypeForUser:(NSDictionary *)body{
    @try{
    }@catch(NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
}

#pragma mark - pushNotificationForBoundary
-(void)pushNotificationForBoudnary:(NSDictionary *)body {
    @try{
        NSError *error = nil;
        MemberBoundary * memberBoundary = [[MemberBoundary alloc] initWithDictionary:body error:&error];
        [[ModelManager sharedInstance].user.boundaryArray addObject:memberBoundary];
        NSLog(@"%@",[ModelManager sharedInstance].user.boundaryArray);
    }@catch(NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
}

#pragma mark - pushNotificationForMessage
-(void)pushNotificationForMessage:(NSDictionary *)body {
    @try{
    }@catch(NSException *exception) {
        NSLog(@"%@",exception.reason);
    }
}

#pragma mark - pushNotificationForRemoveBoudnary
-(void)pushNotificationForRemoveBoundary:(NSDictionary *)body {
    @try{
//        NSLog(@"%@",body);
        NSString *boundayId = [body valueForKey:@"boundary_id"];
        for(int i = 0; i<[[ModelManager sharedInstance].user.boundaryArray count]; i++) {
            BOOL isFound = NO;
            Boundary * boundary = [[ModelManager sharedInstance].user.boundaryArray objectAtIndex:i];
            NSString * b_id = boundary.boundary_id;
            if([b_id isEqualToString:boundayId]) {
                [[ModelManager sharedInstance].user.boundaryArray removeObjectAtIndex:i];
                isFound = YES;
                break;
                }
            }
    }@catch(NSException *exceptiohn) {
        NSLog(@"%@",exceptiohn.reason);
    }
}

@end
