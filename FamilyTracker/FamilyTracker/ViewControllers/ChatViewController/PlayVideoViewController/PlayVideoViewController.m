//
//  PlayVideoViewController.m
//  AudioCallKitSampleProject
//
//  Created by Md. Shahanur Rahmann on 11/11/15.
//  Copyright © 2015 Qaium Hossain. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "FamilyTrackerDefine.h"
#import "Constants.h"
#import "ModelManager.h"
#import "HexToRGB.h"

@interface PlayVideoViewController ()<NSURLSessionDownloadDelegate>{
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadTask;
}

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setBarTintColor:[HexToRGB colorForHex:SYSTEM_NAV_COLOR]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.view bringSubviewToFront:self.btnBack];
//    NSString *urlStringRemote = [self.msgDictionary objectForKey:kMsgKey];
//    [self playVideoWithServerUrlString:urlStringRemote];
//     NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"localVideoLink"];
//    [self playVideoWithLocalUrlString:_selectedVideoUrl];
    //grab a local URL to our video
//    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
//                                            delegate:self
//                                       delegateQueue:[NSOperationQueue mainQueue]
//               ];
//    [self downloadVideo];
    //---Play Video fullscreen show---//
    [self playLocalUrlString];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.moviePlayerController stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playLocalUrlString {
    NSURL*theurl = [NSURL fileURLWithPath:_selectedVideoUrl];
    AVPlayer *player = [AVPlayer playerWithURL:theurl];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = player;
    [player play];
    [self presentViewController:controller animated:YES completion:nil];
}
#pragma mark -DownloadMethod
- (void)downloadVideo {
    if (downloadTask == nil) {
        NSURL *url = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
        downloadTask = [session downloadTaskWithURL:url];
        [downloadTask resume];
    }else {
        [downloadTask resume];
    }
}

#pragma mark - NSURLSessionDelegate Methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *videoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *url = [NSURL URLWithString:[videoPath stringByAppendingPathComponent:@"video1.mp4"]];
    
    if ([fileManager fileExistsAtPath:[location path]]) {
        [fileManager replaceItemAtURL:url withItemAtURL:location backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:nil];
        UISaveVideoAtPathToSavedPhotosAlbum([url path], self,  @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        [self playVideoWithLocalUrlString:url.absoluteString];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float timeDuration = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    NSLog(@"%lld/%lld=%f",totalBytesWritten, totalBytesExpectedToWrite,timeDuration);
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self playVideoWithLocalUrlString:videoPath];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
#pragma mark -
#pragma mark Button Actions Methods
- (IBAction) closeFullScreenPhotoView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark -
#pragma mark PlayVideo Methods

- (void)playVideoWithServerUrlString:(NSString*)urlString {
    NSURL *fileURL = [NSURL URLWithString:urlString];
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
    [self.moviePlayerController.view setFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height-70)];
    [self.view addSubview:self.moviePlayerController.view];
    self.moviePlayerController.fullscreen = YES;
    [self.moviePlayerController play];
}

- (void)playVideoWithLocalUrlString:(NSString*)localUrlStr {
    NSURL *localURL = [NSURL URLWithString:localUrlStr];
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:localURL];
    [self.moviePlayerController.view setFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height-70)];
    [self.view addSubview:self.moviePlayerController.view];
    self.moviePlayerController.fullscreen = YES;
    [self.moviePlayerController prepareToPlay];
    [self.moviePlayerController play];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //---Return YES for supported orientations---//
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self.moviePlayerController.view setFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height-70)];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.moviePlayerController.view setFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height-70)];
    }
    return YES;
}

@end
