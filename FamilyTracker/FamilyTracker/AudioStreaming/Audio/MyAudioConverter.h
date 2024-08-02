//
//  MyAudioConverter.h
//  CiscoIcecastAudioStream
//
//  Created by Apple on 26/12/16.
//  Copyright © 2016 i5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

enum BitDepth{
	BitDepth_8  = 8,
	BitDepth_16 = 16,
	BitDepth_24 = 24,
	BitDepth_32 = 32
};

//TODO:Add delegate

@interface MyAudioConverter : NSObject

//Must set
@property(nonatomic,retain)NSString* inputFile;//Absolute path
@property(nonatomic,retain)NSString* outputFile;//Absolute path

//optional
@property(nonatomic,assign)int outputSampleRate;//Default 44100.0
@property(nonatomic,assign)int outputNumberChannels;//Default 2
@property(nonatomic,assign)enum BitDepth outputBitDepth;//Default BitDepth_16
@property(nonatomic,assign)AudioFormatID outputFormatID;//Default Linear PCM
@property(nonatomic,assign)AudioFileTypeID outputFileType;//Default kAudioFileCAFType
//TODO:add bit rate parameter

-(BOOL)convert;
@end
