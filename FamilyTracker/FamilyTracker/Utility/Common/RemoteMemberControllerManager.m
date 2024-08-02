//
//  RemoteMemberControllerManager.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/10/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "RemoteMemberControllerManager.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "FamilyTrackerOperate.h"
#import "AudioProcessor.h"
#import "Constants.h"
#import "GlobalServiceManager.h"
#import "Common.h"
#define CHUNK_SIZE  1024

@implementation RemoteMemberControllerManager{
    NSMutableDictionary *settingss;
    ServiceHandler *_serviceHandler;
    AppDelegate *delegate;               
}
@synthesize audioProcessor;
static RemoteMemberControllerManager *instance = nil;
- (instancetype)init {
    if (self = [super init]) {
        _modelManager = [ModelManager sharedInstance];
        sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [self initService];
    }
    return self;
}

+ (RemoteMemberControllerManager *)sharedInstance {
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}

#pragma mark - User Defined Methods -
- (void)initService {
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
                               getAlertUpdate:nil
                               andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:_handler];
}


#pragma mark - Remote Audio Streaming Start - 
- (void)remoteAudioStreamingStart {
    
    if ([AVAudioSession sharedInstance].category != AVAudioSessionCategoryRecord) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord  withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
    
    audioProcessor = nil;
    //Create MountPoint---//
    NSInteger epocTime = (NSInteger)floor([[NSDate date] timeIntervalSince1970] * 1000);
    int randomNumber1 = [self getRandomNumberBetween:0 to:999];
    int randomNumber2 = [self getRandomNumberBetween:0 to:randomNumber1];
    int randomNumber3 = [self getRandomNumberBetween:99 to:999]+randomNumber2;
    NSString *streamName = [NSString stringWithFormat:@"%@_%ld_%d",_modelManager.user.userName,(long)epocTime,randomNumber3];
    settingss = [NSMutableDictionary dictionaryWithCapacity:0];
    [settingss setValue:kIceCast_IpAddressValue forKey:kServerIPStorageKey];
    //local:192.168.102.31
    [settingss setValue:kIceCast_PortValue forKey:kServerPortStorageKey];
    [settingss setValue:kIceCast_UserIdValue forKey:kUserNameStorageKey];
    [settingss setValue:kIceCast_PasswordValue forKey:kPasswordStorageKey];
    [settingss setValue:streamName forKey:kMountPointStorageKey];
    [settingss setValue:kIceCast_CodeStorageValue forKey:kCodecStorageKey];
    [settingss setValue:kIceCast_BitRateValue forKey:kSampleRateStorageKey];
    [settingss setValue:[NSNumber numberWithBool:YES] forKey:kAudioSourceTypeStorageKey];
    [[NSUserDefaults standardUserDefaults] setValue:settingss forKey:kSettingsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2nd part
    
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];
    if (settings == nil || [settings valueForKey:kServerIPStorageKey] == nil || [settings valueForKey:kServerPortStorageKey] == nil || [settings valueForKey:kUserNameStorageKey] == nil || [settings valueForKey:kPasswordStorageKey] == nil || [settings valueForKey:kMountPointStorageKey] == nil) {
        return;
    }
    if (audioProcessor == nil) {
        audioProcessor = [[AudioProcessor alloc] init];
        audioProcessor.vcScreen = nil;
    }
    
    // 3rd part
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(startStreamingForSilent)
                                   userInfo:nil
                                    repeats:NO];
}


- (void)startStreamingForSilent {
    _modelManager.isSilentAudioStreamRunning = YES;
    [audioProcessor start];
    
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSString *sharedUrlLink = [NSString stringWithFormat:@"http://%@:%@/%@",
                               [settingss valueForKey:kServerIPStorageKey],
                               [settingss valueForKey:kServerPortStorageKey],
                               [settingss valueForKey:kMountPointStorageKey]
                               ];
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kUser_id_key:_modelManager.user.guardianId,
                                  kLink:sharedUrlLink,
                                  kAlert_type:kAlert_type_panic,
                                  kResourceTypeKey: kAlertResourceTypeAudio,//Audio
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic1 = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                      WHEN_KEY:[NSDate date],
                                      OBJ_KEY:requestBody
                                      };
    [_serviceHandler onOperate:requestBodyDic1];
}

- (void)remoteAudioStreamingStop {
    _modelManager.isSilentAudioStreamRunning = NO;
    [audioProcessor stop];
    [[GlobalServiceManager sharedInstance] stopStreamingService];
    [Common displayToast:NSLocalizedString(@"Silent Audio Streaming stop", nil)  title:nil duration:1];
    
    sleep(1.0);
    [delegate playPanicInBackground];
    [delegate.player2 play];
    [delegate setVolumeZero];
}

#pragma mark - Live Streaming Action Method -
- (int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}


- (void)startStreamingService {
    NSString *guardianId = @"";
    if([_modelManager.user.role integerValue] == 1) {
        guardianId = _modelManager.user.identifier;
    }else {
        guardianId = _modelManager.user.guardianId;
    }
    NSString *sharedUrlLink = [NSString stringWithFormat:@"http://%@:%@/%@",
                               [settingss valueForKey:kServerIPStorageKey],
                               [settingss valueForKey:kServerPortStorageKey],
                               [settingss valueForKey:kMountPointStorageKey]
                               ];
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kLink:sharedUrlLink,
                                  kAlert_type:kAlert_type_panic,
                                  kResourceTypeKey: kAlertResourceTypeAudio,//Audio
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic1 = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic1];
}

#pragma mark - Service Callback Method -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == SAVE_ALERT_SUCCEEDED) {
            NSLog(@"SAVE_ALERT");
            NSError *error = nil;
            _modelManager.liveStreamingAlert  = [[Notification alloc] initWithDictionary:object error:&error];
            [Common displayToast:NSLocalizedString(@"Silent Audio Streaming start", nil)  title:nil duration:1];
        }
    }
    );
}

@end
