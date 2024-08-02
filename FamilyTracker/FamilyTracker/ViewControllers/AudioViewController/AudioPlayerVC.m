//
//  AudioPlayerVC.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 1/14/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//
#import "AudioPlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import "FamilyTrackerDefine.h"
#import "HexToRGB.h"
#import "GlobalData.h"
#import "AppDelegate.h"
#import "GlobalServiceManager.h"

@interface AudioPlayerVC ()
@property(strong,nonatomic) AVPlayer *musicPlayer;
@property(strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) IBOutlet UIImageView *audioPlayerGifImageView;
@property (weak, nonatomic) IBOutlet UILabel *acknowledgeLevel;
@end

@implementation AudioPlayerVC {
    BOOL isAudioPlayerRunning;
    BOOL backHomeByError;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    backHomeByError = NO;
    self.title = NSLocalizedString(@"Live Audio Streaming Player",nil);
    [self.playerPlayOutlet setTitle:@"Play" forState:UIControlStateNormal];
        UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"acknowledgeChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(acknowledgeNoti:)
                                                 name:@"acknowledgeChangeNotification"
                                               object:nil];
    
    self.playerPlayOutlet.layer.cornerRadius = 10;
    self.playerPlayOutlet.layer.borderWidth = 1;
    self.playerPlayOutlet.layer.borderColor = [UIColor blueColor].CGColor;
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
    //---Set On Speaker---//
    if ([AVAudioSession sharedInstance].category != AVAudioSessionCategoryPlayback) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback  withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    isAudioPlayerRunning = NO;
    [self newPlayAudioStreaming:[NSString stringWithFormat:@"%@",_url]];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(delegate.listnerLists == nil) {
    _acknowledgeLevel.text = [NSString stringWithFormat:@"Currently listening %@",[ModelManager sharedInstance].user.userName];
    } else {
        NSString *message = @"";
        if([delegate.listnerLists count] == 0) {
           _acknowledgeLevel.text = [NSString stringWithFormat:@"Currently listening %@",[ModelManager sharedInstance].user.userName];
        } else {
            message = @"Currently listening";
            for(int i = 0; i<[delegate.listnerLists count];i++) {
                NSString *name = [delegate.listnerLists objectAtIndex:i];
                if(i == 0) {
                    message = [NSString stringWithFormat:@"%@ %@",message,name];
                } else {
                    message = [NSString stringWithFormat:@"%@,%@",message,name];
                }
            }
            
            _acknowledgeLevel.text = [NSString stringWithFormat:@"%@",message];
            
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    if(_musicPlayer)
    {
        [_musicPlayer pause];
        [_playerItem removeObserver:self forKeyPath:@"status" context:nil];        _musicPlayer = nil;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"panicBackgroundChange"
     object:nil];
    
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.listnerLists = nil;
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark buttonAction Methods -
- (IBAction)playerPlayAction:(id)sender {
    if(isAudioPlayerRunning) {
        isAudioPlayerRunning = NO;
        [self.playerPlayOutlet setTitle:@"Play" forState:UIControlStateNormal];
        [_musicPlayer pause];
        [_audioPlayerGifImageView stopAnimating];
    }
    else {
        isAudioPlayerRunning = YES;
        [self.playerPlayOutlet setTitle:@"Pause" forState:UIControlStateNormal];
        [_audioPlayerGifImageView startAnimating];
        if(_musicPlayer == nil)
        {
            [self newPlayAudioStreaming:[NSString stringWithFormat:@"%@",_url]];
        }
        else{
            [_musicPlayer play];
        }
    }
}



#pragma - mark music player configaration
-(void)playAudioStreaming:(NSString *)url {
    isAudioPlayerRunning = YES;
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:url]];
    self.musicPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.musicPlayer currentItem]];
    [self.musicPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)observeValueForKeyPath1:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.musicPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.musicPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            isAudioPlayerRunning = NO;
        } else if (self.musicPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            isAudioPlayerRunning = YES;
            [self.playerPlayOutlet setTitle:@"Pause" forState:UIControlStateNormal];
            [self.musicPlayer play];
            [_audioPlayerGifImageView startAnimating];
            
        } else if (self.musicPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            isAudioPlayerRunning = NO;
        }
    }
}


#pragma mark - UserDefined Methods -
- (void)backToHome {
    if(backHomeByError == NO) {
        [[GlobalServiceManager sharedInstance] stopListeningalertService:_alertId];
    }
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -  audio controller -
-(void)newPlayAudioStreaming:(NSString *)url {
    isAudioPlayerRunning = YES;
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    self.musicPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    [self.playerPlayOutlet setTitle:@"Pause" forState:UIControlStateNormal];
    [_audioPlayerGifImageView startAnimating];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_musicPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                            object:[self.musicPlayer currentItem]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == _musicPlayer.currentItem && [keyPath isEqualToString:@"status"]) {
        if (_musicPlayer.currentItem.status == AVPlayerItemStatusFailed) {
            //NSLog(@"------player item failed:%@",_musicPlayer.currentItem.error);
            [_playerPlayOutlet setHidden:YES];
            [self showAlertMessage:nil message:NSLocalizedString(@"This stream no longer available.",nil)];
            [_audioPlayerGifImageView stopAnimating];
            _acknowledgeLevel.text = @"";
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self showAlertMessage:nil message:NSLocalizedString(@"This stream no longer available.",nil)];
    _acknowledgeLevel.text = @"";
}

#pragma - mark User Define Method -
- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   backHomeByError = YES;
                                   [self backToHome];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
