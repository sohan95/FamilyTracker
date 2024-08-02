//
//  AudioRecordingViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 4/10/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "AudioRecordingViewController.h"
#import "Mp3ToBase64String.h"
#import "FamilyTrackerDefine.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "MBProgressHUD.h"

@interface AudioRecordingViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIImageView *audioPlayerGifImageView;

@end

@implementation AudioRecordingViewController

- (void)viewDidLoad {
    
    //---set GIF anim---//
    _audioPlayerGifImageView.animationImages = [NSArray arrayWithObjects:
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
    _audioPlayerGifImageView.animationDuration = 2.0f;
    _audioPlayerGifImageView.animationRepeatCount = 0;
    [_audioPlayerGifImageView startAnimating];
    [_stopSendButton setEnabled:NO];
//    [_playButton setEnabled:NO];
    
    //--- audio path---//
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath_ = [searchPaths objectAtIndex: 0];
    NSString *pathToSave = [documentPath_ stringByAppendingPathComponent:[self dateString]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:pathToSave];//FILEPATH];

    //---Set AudioSession---//
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        return;
    }
    
    //--- Set Recording property---//
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    //Save recording path to preferences
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setURL:outputFileURL forKey:@"recordedAudioFile"];
    [prefs synchronize];
    
    // Initiate and prepare the recorder
    NSError *error2;
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error2];
    if (!recorder) {
        NSLog(@"Error establishing recorder: %@", error.localizedFailureReason);
        return;
    }
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    if (![recorder prepareToRecord]) {
        NSLog(@"Error: Prepare to record failed");
        return;
    }
    
    [super viewDidLoad];
    [self initService];
    [self recordPauseTapped:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Call Methods -
- (void)initService {
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"AudioRecordingViewController";
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

#pragma mark - Actions
- (IBAction)backTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *) dateString {
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".m4a"];
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        if (![recorder record]) {
            NSLog(@"Error: Record failed");
            return;
        }
        [_audioPlayerGifImageView startAnimating];
        [_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [recorder pause];
         [_audioPlayerGifImageView stopAnimating];
        [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [_stopSendButton setEnabled:YES];
//    [_playButton setEnabled:NO];
}

- (IBAction)stopSendTapped:(id)sender {
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
//    NSData *data = [NSData dataWithContentsOfURL:avrecorder.url];
//    [self sendAudioToServer:data];
    
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [_stopSendButton setEnabled:NO];
    
    //---show hud---//
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [hud setLabelText:NSLocalizedString(@"Uploading to server.",nil)];
    [self.view addSubview:hud];
    [hud show:YES];

    
    [[Mp3ToBase64String sharedInstance]musicConvert:avrecorder.url withFileType:@".m4a" WithCompletionBlock:^(id object, NSError *error){
        
        if (object) {
            [self uploadMusic:object];
        } else {
            // MBProgressHUD hide
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            [self showAlert:nil andMessage:error.localizedDescription];
        }
    }];
}

//- (BOOL)sendAudioToServer :(NSData *)data {
//    NSData *d = [NSData dataWithData:data];
//    return YES;
//}

- (void)uploadMusic:(id) object {
    NSDictionary *dictionary = object;
    NSString * fileTitle = [dictionary objectForKey:@"FileTitle"];
    NSString * fileContent = [dictionary objectForKey:@"FileContent"];
    NSString * fileTypeId = @"3";

    NSDictionary *requestBody = @{kFileTitleKey :fileTitle,
                                  kFileContentKey :fileContent,
                                  kFileTypeIdKey :fileTypeId,
                                  kUserIdCamelLetterKey:_modelManager.user.identifier,
                                  kUserNameCamelLetterName:_modelManager.user.userName,
                                  kFileExtensionKey:@".m4a",
                                  kTokenKey:_modelManager.user.sessionToken
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:UPLOAD_MULTIMEDIA],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma - mark showAlert

- (void)showAlert:(NSString *)title andMessage:(NSString *)message{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Service Callback Method -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
        if (sourceType == UPLOAD_MULTIMEDIA_SUCCCEEDED) {//---Save Alerts
            NSDictionary *dic = [NSDictionary new];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SendAudioNotification"
             object:dic];
        } else if (sourceType == UPLOAD_MULTIMEDIA_FAILED) {

        }
    });
}


@end
