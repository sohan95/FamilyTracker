//
//  Mp3ToBase64String.m
//  WalkieTalkieRadio
//
//  Created by Zeeshan Khan on 12/12/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "Mp3ToBase64String.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Common.h"

@implementation Mp3ToBase64String

+(id)sharedInstance {
    static Mp3ToBase64String *sharedObject = nil;
    @synchronized(self) {
        if (sharedObject == nil)
            sharedObject = [[self alloc] init];
    }
    return sharedObject;
}

- (void)musicConvert:(NSURL *)assetURL withFileType:(NSString*)fileType WithCompletionBlock:(Base64StringConvertBlock)block {
    
    base64StringBlock = block;
//    NSURL *assetURL = [NSURL URLWithString:urlString];
//    NSURL *assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: assetURL options:nil];

    NSString *fileTitle = @"";
    //[mediaItem valueForProperty: MPMediaItemPropertyTitle];
    NSLog (@"%@", fileTitle);
    // duration calculate
    CMTime audioDuration = songAsset.duration;
    NSUInteger durationSeconds = (long)CMTimeGetSeconds(audioDuration);
    NSUInteger hours = floor(durationSeconds / 3600);
    NSUInteger minutes = floor(durationSeconds % 3600 / 60);
    NSUInteger second = floor(durationSeconds % 3600 % 60);
//    NSString *duration = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (unsigned long)hours, (unsigned long)minutes, (unsigned long)second];
    
    NSString *duration = [NSString stringWithFormat:@"%02ld.%02ld",(unsigned long)minutes, (unsigned long)second];
    
    NSLog(@"Time|%@", duration);
    
    AVAssetExportSession *exporter;
    NSString * fileName;
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    NSString *intervalSeconds = [NSString stringWithFormat:@"%0.0f",seconds];
    if ([fileType isEqualToString:@".m4a"]) {
         exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName:AVAssetExportPresetAppleM4A];
        exporter.outputFileType =   @"com.apple.m4a-audio";
         fileName = [NSString stringWithFormat:@"%@.m4a",intervalSeconds];
    } else {
         exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName:AVAssetExportPreset640x480];
        exporter.outputFileType =  AVFileTypeMPEG4;
         fileName = [NSString stringWithFormat:@"%@.m4v",intervalSeconds];
    }

    // size
    CMTime half = CMTimeMultiplyByFloat64(exporter.asset.duration, 1);
    exporter.timeRange = CMTimeRangeMake(kCMTimeZero, half);
    long long size = exporter.estimatedOutputFileLength;
    
    // 41943040 = 5mb
    
    if(size > 41943040){
       NSError * sizeError = [[NSError alloc] initWithDomain:@"com.com" code:-120 userInfo:@{@"msg" : @"Please select less then 5 mb"}];
         base64StringBlock(nil, sizeError);
        return;
    }
    
    
    //exporter.outputFileType =   @"com.apple.mp3";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * myDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *exportFile = [myDocumentsDirectory stringByAppendingPathComponent:fileName];
    
    NSURL *exportURLTry = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURLTry;
    
    
   NSError * error = [[NSError alloc] initWithDomain:@"com.com" code:-120 userInfo:@{@"msg" : @"Error try again"}];
    
    // do the export
    // (completion handler block omitted)
    [exporter exportAsynchronouslyWithCompletionHandler:
     ^{
         int exportStatus = exporter.status;
         switch (exportStatus)
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *exportError = exporter.error;
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 base64StringBlock(nil, exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 
                 NSData *data = [NSData dataWithContentsOfFile: [myDocumentsDirectory stringByAppendingPathComponent:fileName]];
                 
                 // NSLog(@"Data %@",data);
                 
                 NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
                 
                 // NSLog(@"Data %@",base64Encoded);
                 
//                 NSString * title = fileTitle;//[Common trimString:fileTitle];
//                 NSMutableString *tempFileTitle = [NSMutableString new];
//                 [tempFileTitle appendString:fileTitle];
//                 [tempFileTitle appendString:@".m4a"];
                 
                 NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:fileName,@"FileTitle",base64Encoded,@"FileContent",duration,@"Duration",nil];
                 
                 base64StringBlock(dictionary,nil);
                 data = nil;
                 break;
             }
             case AVAssetExportSessionStatusUnknown:
             {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                base64StringBlock(nil, error);
                 break;

             }
             case AVAssetExportSessionStatusExporting:
             {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                  base64StringBlock(nil, error);
                 break;
             }
             case AVAssetExportSessionStatusCancelled:
             {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                  base64StringBlock(nil, error);
                 break;
             }
             case AVAssetExportSessionStatusWaiting:
             {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                  base64StringBlock(nil, error);
                 break;
             }
             default:
             {
                 NSLog (@"didn't get export status");
                  base64StringBlock(nil, error);
                 break;
             }
         }
         
     }];
     
}

@end
