//
//  StreamRecordedVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 23/11/15.
//  Copyright © 2015 AHMLPT0406. All rights reserved.
//

#import "StreamRecordedVC.h"
#include <CoreMedia/CoreMedia.h>
//#include <AVFoundation/AVFoundation.h>

#import "RecordedStreamController.h"

#import "Constant.h"
#import "AppDelegate.h"

@interface StreamRecordedVC () <RecordedStreamControllerDelegate>
{
    IBOutlet UILabel *fileNameLabel;
    IBOutlet UILabel *fileTypeNameLabel;
    IBOutlet UILabel *fileSizeLabel;
    IBOutlet UILabel *fileDurationLabel;
    IBOutlet UILabel *filePathLabel;
    
    IBOutlet UILabel *streamingStatusCaptionLabel;
    IBOutlet UILabel *streamingStatusLabel;
    
    IBOutlet UIButton *startStopStreamingButton;
    
    BOOL isStartFileStreamming;
    
    RecordedStreamController *streamRecordedControllerObj;
}
@end

@implementation StreamRecordedVC

@synthesize streamFileDetails;
//@synthesize isNetworkAvilable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self restrictRotation:YES];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    [fileNameLabel setText:[self.streamFileDetails valueForKey:@"recordFileName"]];
    
    NSString *extension = [[self.streamFileDetails valueForKey:@"recordFileName"] substringFromIndex:[[self.streamFileDetails valueForKey:@"recordFileName"] rangeOfString:@"."].location];
    if ([extension isEqualToString:@"aac"]) {
        [fileTypeNameLabel setText:@"Audio"];
    }
    else {
        [fileTypeNameLabel setText:@"Video"];
    }
    
    long double fileSize = [[self.streamFileDetails valueForKey:@"fileSize"] doubleValue];
    NSString *sufix = @"KB";
    while (fileSize >= 1024) {
        fileSize /= (float)1024;
        sufix = @"MB";
    }
    
    NSString *fileSizeString = [NSString stringWithFormat:@"%.2Lf%@", fileSize, sufix];
    
    [fileSizeLabel setText:fileSizeString];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),[self.streamFileDetails valueForKey:@"recordFileName"]];
    [filePathLabel setText:filePath];
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 130, FLT_MAX);
    
    CGSize expectedLabelSize = [filePath sizeWithFont:filePathLabel.font constrainedToSize:maximumLabelSize lineBreakMode:filePathLabel.lineBreakMode];
    
    
//    CGSize expectedLabelSize = [filePath boundingRectWithSize:<#(CGSize)#> options:<#(NSStringDrawingOptions)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#> context:<#(nullable NSStringDrawingContext *)#>]
//    CGSize size = [label.text boundingRectWithSize: maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{ NSFontAttributeName: label.font, NSParagraphStyleAttributeName: paragraph } context: nil].size;
    //adjust the label the the new height.
    CGRect newFrame = filePathLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    filePathLabel.frame = newFrame;
    
    CGRect newFrameCaption = streamingStatusCaptionLabel.frame;
    newFrameCaption.origin.y = newFrame.origin.y + newFrame.size.height + 8;
    streamingStatusCaptionLabel.frame = newFrameCaption;
    
    newFrameCaption = streamingStatusLabel.frame;
    newFrameCaption.origin.y = newFrame.origin.y + newFrame.size.height + 8;
    streamingStatusLabel.frame = newFrameCaption;
    
    CGRect newFrameButton = startStopStreamingButton.frame;
    newFrameButton.origin.y = newFrameCaption.origin.y + newFrameCaption.size.height + 15;
    startStopStreamingButton.frame = newFrameButton;
    
    
    [fileDurationLabel setText:[self remaningTime]];
    
    [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:kStreamFilePathUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [startStopStreamingButton setTitle:@"Stop Streaming" forState:UIControlStateNormal];
    
    streamRecordedControllerObj = [[RecordedStreamController alloc]init];
    streamRecordedControllerObj.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    isStartFileStreamming = YES;
    [self notifyStatusUpdate:kStreamingStatusConnecting];
    
    [streamRecordedControllerObj startClientFile];
    
    [streamRecordedControllerObj screenAppear];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (isStartFileStreamming) {
        [streamRecordedControllerObj stopStreamingRecordedFile];
    }
    
    [streamRecordedControllerObj screenDisapper];
    [self restrictRotation:NO];
    [super viewWillDisappear:animated];
}

- (void) restrictRotation:(BOOL)restriction
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString*)remaningTime
{
    NSDate *startDate = [self.streamFileDetails valueForKey:@"startTime"];
    NSDate *endDate = [self.streamFileDetails valueForKey:@"endTime"];
    
    if (startDate == nil || endDate == nil) {
        return @"";
    }
    
    NSDateComponents *components;
    NSInteger days;
    NSInteger hour;
    NSInteger minutes;
    NSInteger seconds;
    NSString *durationString;
    
    components = [[NSCalendar currentCalendar] components:
                  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                 fromDate:startDate
                                                   toDate:endDate
                                                  options:0];
    days = [components day];
    hour = [components hour];
    minutes = [components minute];
    seconds = [components second];
    
    if(days>0){
        
        if(days>1){
            durationString=[NSString stringWithFormat:@"%d days",days];
        }
        else{
            durationString=[NSString stringWithFormat:@"%d day",days];
        }
        return durationString;
    }
    
    if(hour>0){
        
        if(hour>1){
            durationString=[NSString stringWithFormat:@"%d hours",hour];
        }
        else{
            durationString=[NSString stringWithFormat:@"%d hour",hour];
            
        }
        return durationString;
    }
    
    if(minutes>0){
        
        if(minutes>1){
            durationString=[NSString stringWithFormat:@"%d minutes",minutes];
        }
        else{
            durationString=[NSString stringWithFormat:@"%d minute",minutes];
            
        }
        return durationString;
    }
    
    if(seconds>0){
        
        if(seconds>1){
            durationString=[NSString stringWithFormat:@"%d seconds",seconds];
        }
        else{
            durationString=[NSString stringWithFormat:@"%d second",seconds];
            
        }
        return durationString;
    }
    
    return @"";
}

#pragma  mark - Button Action
- (IBAction)tappedStratStopStreaming:(id)sender {
    
    NSLog(@"IN tappedStratStopStreaming *************************");
    if (!isStartFileStreamming) {
        
        [streamRecordedControllerObj startStreamingRecordedFile];
    }
    else {
        [streamRecordedControllerObj stopStreamingRecordedFile];
    }
}

- (void)startStreaming {
    
    isStartFileStreamming = YES;

    [startStopStreamingButton setTitle:@"Stop Streaming" forState:UIControlStateNormal];

    [startStopStreamingButton setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];

}

- (void)stopStreaming {
    isStartFileStreamming = NO;
    
    [startStopStreamingButton setTitle:@"Start Streaming" forState:UIControlStateNormal];
    NSLog(@"CLIENT STOP");
}

- (void)updateStatusLabel:(NSString *)status {
    dispatch_async (dispatch_get_main_queue(), ^{
        [streamingStatusLabel setText:status];
        [self.view setNeedsDisplay];
    });
}

- (void)showAlertPopup:(NSString *)message {
    
    UIAlertController *alertVC =   [UIAlertController
                 alertControllerWithTitle:@"Error Connection Failed"
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOk = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertVC dismissViewControllerAnimated:YES completion:nil];
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    
    [alertVC addAction:btnOk];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - RecordedStreamControllerDelegate 

- (void)notifyOnError:(NSString *)status {
    [self showAlertPopup:status];
}

- (void)notifyStatusUpdate:(NSString *)status {
    
    NSLog(@"updateStreamStatus message:%@",status);
    
    if ([status isEqualToString:kStreamingStatusStream]) {
        //start streaming
        [startStopStreamingButton setEnabled:YES];
        [self updateStatusLabel:status];
    }
    else if ([status isEqualToString:kStreamingStatusConnecting]) {
        [self updateStatusLabel:status];
    }
    else if ([status isEqualToString:kStreamingStatusDone]) {
        [self updateStatusLabel:status];
    }
    else if ([status isEqualToString:kStartStreaming]) {
        [self startStreaming];
    }
    else if ([status isEqualToString:kStopStreaming]) {
        [self stopStreaming];
        
        [self updateStatusLabel:kStreamingStatusDone];
    }
}

@end
