//
//  PlayVideoViewController.h
//  AudioCallKitSampleProject
//
//  Created by Md. Shahanur Rahmann on 11/11/15.
//  Copyright © 2015 Qaium Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PlayVideoViewController : UIViewController<MPMediaPickerControllerDelegate>

@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) NSDictionary *msgDictionary;
@property (nonatomic, strong) NSString *selectedVideoUrl;
@property (nonatomic, strong) IBOutlet UIButton *btnBack;

@end
