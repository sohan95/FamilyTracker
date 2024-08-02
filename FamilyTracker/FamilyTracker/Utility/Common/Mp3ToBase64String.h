//
//  Mp3ToBase64String.h
//  WalkieTalkieRadio
//
//  Created by Zeeshan Khan on 12/12/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>


typedef void (^Base64StringConvertBlock)(id object, NSError *error);

@interface Mp3ToBase64String : NSObject{
    Base64StringConvertBlock base64StringBlock;
}

+(id)sharedInstance;

//-(void)musicConvert:(MPMediaItem *)mediaItem WithCompletionBlock:(Base64StringConvertBlock)block;
- (void)musicConvert:(NSURL *)assetURL withFileType:(NSString*)fileType WithCompletionBlock:(Base64StringConvertBlock)block;

//-(void)SignUpWithUser:(MPMediaItem *)mediaItem WithCompletionBlock:(Base64StringConvertBlock)block;

@end
