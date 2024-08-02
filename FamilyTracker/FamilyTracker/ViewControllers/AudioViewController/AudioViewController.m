//
//  ViewController.m
//  CiscoIcecastAudioStream
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 i5. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioProcessor.h"
#import "Constants.h"
#import "MyAudioConverter.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalServiceManager.h"
#define CHUNK_SIZE  1024

@interface AudioViewController () <NSStreamDelegate> {
    __weak IBOutlet UIButton *startStopStreamingButton;
    BOOL isStreaming;
    BOOL isServiceCall;
	int fileCurrentByteSize;
	NSNumber *bytesRead;
    NSInputStream *iStream;
	NSMutableData *fileData;
    NSMutableDictionary *settingss;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
}
@property (retain, nonatomic) AudioProcessor *audioProcessor;
@property (strong, nonatomic) IBOutlet UIButton *tappedStartStopStreamingOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *liveAudioStreamingAudioGifImage;
@property (weak, nonatomic) IBOutlet UILabel *acknowledgeLevel;
- (void)backToHome:(id)sender;

@end

@implementation AudioViewController
@synthesize audioProcessor;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Audio Streaming",nil);
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome:)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopAudioStreamingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopAudioStreamingNotification:)
                                                 name:@"stopAudioStreamingNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"acknowledgeChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(acknowledgeNoti:)
                                                 name:@"acknowledgeChangeNotification"
                                               object:nil];
    startStopStreamingButton.layer.cornerRadius = 10;
    startStopStreamingButton.layer.borderWidth = 1;
    startStopStreamingButton.layer.borderColor = [UIColor blueColor].CGColor;
        _liveAudioStreamingAudioGifImage.animationImages = [NSArray arrayWithObjects:
                [UIImage imageNamed:@"audio_player_0.gif"],
                [UIImage imageNamed:@"audio_player_1.gif"],
                [UIImage imageNamed:@"audio_player_2.gif"],
                [UIImage imageNamed:@"audio_player_3.gif"],
                [UIImage imageNamed:@"audio_player_4.gif"],
                [UIImage imageNamed:@"audio_player_5.gif"],
                [UIImage imageNamed:@"audio_player_6.gif"],
                [UIImage imageNamed:@"audio_player_7.gif"],
                [UIImage imageNamed:@"audio_player_8.gif"],
                [UIImage imageNamed:@"audio_player_9.gif"],
                [UIImage imageNamed:@"audio_player_10.gif"],
                [UIImage imageNamed:@"audio_player_11.gif"],
                [UIImage imageNamed:@"audio_player_12.gif"],
                [UIImage imageNamed:@"audio_player_13.gif"],
                [UIImage imageNamed:@"audio_player_14.gif"],
                [UIImage imageNamed:@"audio_player_15.gif"],
                [UIImage imageNamed:@"audio_player_16.gif"],
                [UIImage imageNamed:@"audio_player_17.gif"],
                [UIImage imageNamed:@"audio_player_18.gif"],
                [UIImage imageNamed:@"audio_player_19.gif"],
                [UIImage imageNamed:@"audio_player_20.gif"],
                [UIImage imageNamed:@"audio_player_21.gif"],
                [UIImage imageNamed:@"audio_player_22.gif"],
                [UIImage imageNamed:@"audio_player_23.gif"], nil];
    _liveAudioStreamingAudioGifImage.animationDuration = 2.0f;
    _liveAudioStreamingAudioGifImage.animationRepeatCount = 0;
    isStreaming = NO;
    audioProcessor = nil;
    isServiceCall = NO;
     [self initService];
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
    [self tappedStartStopStreamingButton:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
    if ([_alertType isEqualToString:kAlert_type_panic]) {
        [GlobalData sharedInstance].isInPanic = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [GlobalData sharedInstance].isInPanic = NO;
    if(isStreaming) {
      [self tappedStartStopStreamingButton:nil];
    }
    
//   AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.listnerLists = nil;
    
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NotificationCenter Methods -
- (void)stopAudioStreamingNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopAudioStreamingNotification"]) {
        if (isStreaming) {
            [ModelManager sharedInstance].liveStreamingAlert = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)acknowledgeNoti:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"acknowledgeChangeNotification"]){
       NSLog(@"%@ updated", [notification userInfo]);
        NSDictionary * dict = [notification userInfo];
        NSString * message = [dict valueForKey:acknowledge_message_key];
        [_acknowledgeLevel setText:message];
        [_acknowledgeLevel setHidden:NO];
    }
    
}

#pragma mark - Button Actions -
- (IBAction)tappedStartStopStreamingButton:(id)sender {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];
    if (settings == nil || [settings valueForKey:kServerIPStorageKey] == nil || [settings valueForKey:kServerPortStorageKey] == nil || [settings valueForKey:kUserNameStorageKey] == nil || [settings valueForKey:kPasswordStorageKey] == nil || [settings valueForKey:kMountPointStorageKey] == nil) {
        [self showAlert:NSLocalizedString(@"Please save server details in settings.",nil)];
        return;
    }
    if (audioProcessor == nil) {
        audioProcessor = [[AudioProcessor alloc] init];
        audioProcessor.vcScreen = self;
    }
    if (isStreaming) {
		[startStopStreamingButton setTitle:NSLocalizedString(@"Start Live Audio Streaming",nil) forState:UIControlStateNormal];
        isStreaming = NO;
        [audioProcessor stop];
        [_liveAudioStreamingAudioGifImage stopAnimating];
		if (![[settings valueForKey:kAudioSourceTypeStorageKey] boolValue]) {
			// STOP streaming from recorded audio
			if (iStream) {
				[iStream close];
				[iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				iStream = nil; // stream is ivar, so reinit it
                //audioProcessor = nil;//sohan
			}
		}
    } else {
        isStreaming = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
            [startStopStreamingButton setEnabled:NO];
			[startStopStreamingButton setTitle:NSLocalizedString(@"Stop Live Audio Streaming",nil) forState:UIControlStateNormal];
            [_liveAudioStreamingAudioGifImage startAnimating];
			[self.view setNeedsDisplay];
			[self.view setNeedsLayout];
		});
		[NSTimer scheduledTimerWithTimeInterval:0.2
										 target:self
									   selector:@selector(startStreaming)
									   userInfo:nil
										repeats:NO];
    }
}

- (void)startStreaming {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];
    if ([[settings valueForKey:kAudioSourceTypeStorageKey] boolValue]) {
        //---Start AudioStreaming Panic Alert Service call---//
        if(!isServiceCall) {
            [self startStreamingService];
            isServiceCall = YES;
        }
        // Start streaming from live audio
        [audioProcessor start];
        [startStopStreamingButton setEnabled:YES];
    }else {
        // Start streaming from file audio
        [self readAudioFileAndStreaming];
    }
}

#pragma mark - UserDefined Methods -
- (void)backToHome:(id)sender {
    [[GlobalServiceManager sharedInstance] stopStreamingService];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Live Streaming Action Method -
- (int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

#pragma mark - Service Call Methods -
- (void)initService {
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"AudioViewController";
    //Initialize Service CallBack Handler
    ReplyHandler *handler = [[ReplyHandler alloc]
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
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
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
    
    NSString *isSendSms = @"0";
        NSMutableDictionary *settingDic = [NSMutableDictionary dictionaryWithDictionary:_modelManager.user.userSettings];
        if([[settingDic valueForKey:@"1006"] isEqualToString:@"SMS"]) {
            isSendSms = @"1";
        }
    
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kLink:sharedUrlLink,
                                  kAlert_type:_alertType,
                                  kResourceTypeKey: kAlertResourceTypeAudio,
                                  kIsSendSMS: isSendSms,
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma mark - Service Callback Method -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sourceType == SAVE_ALERT_SUCCEEDED) {//---Save Alerts
            NSError *error = nil;
            _modelManager.liveStreamingAlert  = [[Notification alloc] initWithDictionary:object error:&error];
            if ([_alertType isEqualToString:kAlert_type_panic]) {
                [Common displayToast:NSLocalizedString(@"Audio panic alert has been sent.", nil)  title:nil duration:1];
            }else {
                [Common displayToast:NSLocalizedString(@"Audio streaming alert has been sent.", nil)  title:nil duration:1];
            }
        }else if(sourceType == SAVE_ALERT_FAILED) {
            if ([_alertType isEqualToString:kAlert_type_panic]) {
                [Common displayToast:NSLocalizedString(@"Audio panic alert failed to send!", nil)  title:nil duration:1];
            }else {
                [Common displayToast:NSLocalizedString(@"Audio streaming alert failed to send!", nil)  title:nil duration:1];
            }

            /*
             ///
//            [audioProcessor stop];
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                //---Check single logout---//
                
                if ([object[@"code"] integerValue] == 400) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                }else {
                    errorMsg = @"";
                }
            }
            if(errorMsg.length < 1 ) {
                if ([_alertType isEqualToString:kAlert_type_panic]) {
//                    [self showAlertMessage:NSLocalizedString(@"Audio panic alert failed to send!", nil) message:nil];
                                    [Common displayToast:NSLocalizedString(@"Audio panic alert failed to send!", nil)  title:nil duration:1];
                }else {
//                    [self showAlertMessage:NSLocalizedString(@"Audio streaming alert failed to send!", nil) message:nil];
                                    [Common displayToast:NSLocalizedString(@"Audio streaming alert failed to send!", nil)  title:nil duration:1];
                }
            }else {
                [self showAlertMessage:errorMsg message:nil];
            }
            ///*/
        }
    });
}

#pragma mark - Methods -
- (void)readAudioFileAndStreaming {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *musicDir = [[documentsPath stringByAppendingPathComponent:@"/Music/"] copy];
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];
	NSString *file = [musicDir stringByAppendingPathComponent:[[settings valueForKey:kAudioFileNameStorageKey] lastPathComponent]];
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"sampleWAV" ofType:@"wav"];
	NSString *extension = [[file substringFromIndex:[file rangeOfString:@"." options:NSBackwardsSearch].location] lowercaseString];
	NSString *trackName = [[[file substringFromIndex:[file rangeOfString:@"/" options:NSBackwardsSearch].location] lowercaseString].stringByDeletingPathExtension substringFromIndex:1];
	[audioProcessor initServer];
	if ([extension isEqualToString:@".wav"]) {
		[audioProcessor streamWavFile:file];
	}else if ([extension isEqualToString:@".mp3"]) {
        iStream = [[NSInputStream alloc] initWithFileAtPath:file];
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [iStream open];
    }else {
        //if ([extension isEqualToString:@".aac"]||[extension isEqualToString:@".caf"]|| [extension isEqualToString:@".aiff"])
        NSString *convertedTrackName = [NSString stringWithFormat:@"%@.wav", trackName];
        NSString *outputFile = [musicDir stringByAppendingPathComponent:convertedTrackName];
        MyAudioConverter *audioConverter = [[MyAudioConverter alloc] init];
        audioConverter.inputFile =  file;
        audioConverter.outputFile = outputFile;
        BOOL isSuccess = [audioConverter convert];
        if (!isSuccess) {
            NSString *fileNotSupported = [NSString stringWithFormat:@"%@ audio format not supported!", extension];
            
            [self showAlert:fileNotSupported];
            [self tappedStartStopStreamingButton:nil];
            return;
        }
        [audioProcessor streamWavFile:outputFile];
        //  delete temp. wav file created
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if (![fileManager fileExistsAtPath:outputFile]) {
            //NSLog(@"File not present");
            return;
        }else {
            BOOL success = [fileManager removeItemAtPath:outputFile error:&error];
            if (!success) {
                //NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                return;
            }
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            if(!fileData) {
                fileData = [NSMutableData data];
            }
			
            uint8_t buf[CHUNK_SIZE];
            NSInteger len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:CHUNK_SIZE];
            if(len) {
				[fileData appendBytes:(const void *)buf length:len];
				
				// Send data to server
                [audioProcessor startRecordingAudioBytes:fileData];
				fileData = nil;
            
            } else {
                NSLog(@"no buffer!");
            }
			
			break;
        }
        case NSStreamEventNone: {
           break;
        }
        case NSStreamEventOpenCompleted: {
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *theError = [iStream streamError];
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error reading stream!",nil)  message:[NSString stringWithFormat:@"Error %li: %@", (long)[theError code], [theError localizedDescription]]
                                                              delegate:nil
                                                     cancelButtonTitle:@""
                                                     otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
            [theAlert show];
			if(isStreaming) {
				[self tappedStartStopStreamingButton:nil];
			}
            break;
        }
        case NSStreamEventEndEncountered:{
			if(isStreaming) {
				[self tappedStartStopStreamingButton:nil];
			}
			break;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier  isEqual: @"SettingsViewController"]) {
		if(isStreaming) {
			[self tappedStartStopStreamingButton:nil];
		}
	}
}

#pragma mark - Public Methods - 
- (void)stopClient {
    if (isStreaming) {
        [self tappedStartStopStreamingButton:nil];
    }
}

- (void)showAlert:(NSString *)errorMessage {
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@""
                                                       message:errorMessage
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    [theAlert show];
}

//Show alert message for given title and message
- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      
//                                      [self.navigationController popViewControllerAnimated:YES];
                                  });
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
