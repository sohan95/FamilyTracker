//
//  AudioRecordingViewController.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 4/10/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecordingViewController : UIViewController <AVAudioSessionDelegate,AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopSendButton;
//@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopSendTapped:(id)sender;
//- (IBAction)playTapped:(id)sender;

@end
