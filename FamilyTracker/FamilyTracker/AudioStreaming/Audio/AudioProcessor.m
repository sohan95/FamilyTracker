//
//  AudioProcessor.m
//  MicInput
//
//  Created by Gstream on 21.09.15.
//  Copyright 2011 http://www.stefanpopp.de/2011/capture-iphone-microphone/ . All rights reserved.
//

#import "AudioProcessor.h"
#import "Constants.h"

static lame_t mLame;
#pragma mark Recording callback

static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
	
	// the data gets rendered here
    AudioBuffer buffer;
    
    // a variable where we check the status
    OSStatus status;
    
    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (__bridge AudioProcessor *) inRefCon;
    
    /**
     on this point we define the number of channels, which is mono
     for the iphone. the number of frames is usally 512 or 1024.
     */
    printf("%d=====\n", (int)inNumberFrames);
    buffer.mDataByteSize = inNumberFrames * sizeof(short int); // sample size
    buffer.mNumberChannels = NUMBER_CHANNEL; // one channel
	buffer.mData = malloc( inNumberFrames * sizeof(short int) ); // buffer size
	
    // we put our buffer into a bufferlist array for rendering
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
    
    // render input and check for error
    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
	
	[audioProcessor hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return status;
    }
    
	// process the bufferlist in the audio processor
    [audioProcessor processBuffer:&bufferList];
	
    // clean up the buffer
	free(bufferList.mBuffers[0].mData);
	
    return noErr;
}

#pragma mark Playback callback

static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {    

    /**
     This is the reference to the object who owns the callback.
     */
    AudioProcessor *audioProcessor = (__bridge AudioProcessor*) inRefCon;
    
    // iterate over incoming stream an copy to output stream
	for (int i=0; i < ioData->mNumberBuffers; i++) { 
		AudioBuffer buffer = ioData->mBuffers[i];
		
        // find minimum size
		UInt32 size = min(buffer.mDataByteSize, [audioProcessor audioBuffer].mDataByteSize);
        
        // copy buffer to audio buffer which gets played after function return
		memcpy(buffer.mData, [audioProcessor audioBuffer].mData, size);
        
        // set data size
		buffer.mDataByteSize = size; 
    }
    return noErr;
}

#pragma mark objective-c class

@implementation AudioProcessor
@synthesize audioUnit, audioBuffer, gain, vcScreen;

-(AudioProcessor*)init
{
    self = [super init];
    if (self) {
        gain = 0;
        [self initializeAudio];
    }
    return self;
}

-(void)initializeAudio
{    
    OSStatus status;
	
	// We define the audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output; // we want to ouput
	desc.componentSubType = kAudioUnitSubType_RemoteIO; // we want in and ouput
	desc.componentFlags = 0; // must be zero
	desc.componentFlagsMask = 0; // must be zero
	desc.componentManufacturer = kAudioUnitManufacturer_Apple; // select provider
	
	// find the AU component by description
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// create audio unit by component
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    
    // define that we want record io on the input bus
    UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Input, // scope to input
								  kInputBus, // select input bus (1)
								  &flag, // set flag
								  sizeof(flag));
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    
	// define that we want play on io on the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, // use io
								  kAudioUnitScope_Output, // scope to output
								  kOutputBus, // select output bus (0)
								  &flag, // set flag
								  sizeof(flag));
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    
	/* 
     We need to specifie our format on which we want to work.
     We use Linear PCM cause its uncompressed and we work on raw data.
     for more informations check.
     
     We want 16 bits, 2 bytes per packet/frames at 44khz 
     */
	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate			= SAMPLE_RATE;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= NUMBER_CHANNEL;
	audioFormat.mBitsPerChannel		= 8 * sizeof(short int);
    audioFormat.mBytesPerFrame		= sizeof(short int) * NUMBER_CHANNEL;//2;
	audioFormat.mBytesPerPacket		= audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
    
    
    
	// set the format on the output stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  kInputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
    
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    
    // set the format on the input stream
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
	
    /**
        We need to define a callback structure which holds
        a pointer to the recordingCallback and a reference to
        the audio processor object
     */
	AURenderCallbackStruct callbackStruct;
    
    // set recording callback
	callbackStruct.inputProc = recordingCallback; // recordingCallback pointer
	callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);

    // set input callback to recording callback on the input bus
	status = AudioUnitSetProperty(audioUnit, 
                                  kAudioOutputUnitProperty_SetInputCallback, 
								  kAudioUnitScope_Global, 
								  kInputBus, 
								  &callbackStruct, 
								  sizeof(callbackStruct));
    
    [self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    
    /*
     We do the same on the output stream to hear what is coming
     from the input stream
    */
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    // set playbackCallback as callback on our renderer for the output bus
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    if (status != noErr) {
        return;
    }
    // reset flag to 0
	flag = 0;
    
    /*
     we need to tell the audio unit to allocate the render buffer,
     that we can directly write into it.
     */
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_ShouldAllocateBuffer,
								  kAudioUnitScope_Output, 
								  kInputBus,
								  &flag, 
								  sizeof(flag));

    /*
     we set the number of channels to mono and allocate our block size to
     1024 bytes.
    */
	audioBuffer.mNumberChannels = 1;
	audioBuffer.mDataByteSize = SAMPLE_RATE * 2;
	audioBuffer.mData = malloc( SAMPLE_RATE * 2 );
	
	// Initialize the Audio Unit and cross fingers =)
	status = AudioUnitInitialize(audioUnit);
	[self hasError:status infile:__FILE__ atline:__LINE__];
    
    NSLog(@"Started");
}

#pragma mark controll stream

-(void)start;
{
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];

    unsigned char *serverIP = (unsigned char *)[(NSString *)[settings valueForKey:kServerIPStorageKey] UTF8String];
    int port = [[settings valueForKey:kServerPortStorageKey] intValue];
    unsigned char *username = (unsigned char *)[(NSString *)[settings valueForKey:kUserNameStorageKey] UTF8String];
    unsigned char *password = (unsigned char *)[(NSString *)[settings valueForKey:kPasswordStorageKey] UTF8String];
    unsigned char *mountpoint = (unsigned char *)[(NSString *)[settings valueForKey:kMountPointStorageKey] UTF8String];
    
    int initStatus = ShoutOutputStream_Init(serverIP, port , mountpoint, username, password, 1);
    
    if (initStatus == -1) {
        NSLog(@"Fail to init stream server.");
        return;
    }
    mLame = lame_init();
    
    int sampleRate = [[settings valueForKey:kSampleRateStorageKey] intValue];
    lame_set_in_samplerate(mLame, sampleRate);
    
    lame_set_mode(mLame, MONO);
    lame_set_quality(mLame, 5);
    lame_init_params(mLame);
    // start the audio unit. You should hear something, hopefully :)
    OSStatus status = AudioOutputUnitStart(audioUnit);
    [self hasError:status infile:__FILE__ atline:__LINE__];
}
-(void)stop;
{
    ShoutOutputStream_Close();
    // stop the audio unit
    OSStatus status = AudioOutputUnitStop(audioUnit);
    [self hasError:status infile:__FILE__ atline:__LINE__];
}


-(void)setGain:(float)gainValue 
{
    gain = gainValue;
}

-(float)getGain
{
    return gain;
}

#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList
{
    @try {
        
    AudioBuffer sourceBuffer = audioBufferList->mBuffers[0];
    
    // we check here if the input data byte size has changed
	if (audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        // clear old buffer
		free(audioBuffer.mData);
        // assing new byte size and allocate them on mData
		audioBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
		audioBuffer.mData = malloc(sourceBuffer.mDataByteSize);
	}
    
    /**
     Here we modify the raw data buffer now. 
     In my example this is a simple input volume gain.
     iOS 5 has this on board now, but as example quite good.
     */
    SInt16 *editBuffer = audioBufferList->mBuffers[0].mData;
    int size = audioBufferList->mBuffers[0].mDataByteSize / 2;
    printf("\nSIZE:::%d",size);
    short int tempBuffer[size];
    
    // loop over every packet
    for (int nb = 0; nb < (size); nb++) {

        // we check if the gain has been modified to save resoures
        if (gain != 0) {
            // we need more accuracy in our calculation so we calculate with doubles
            double gainSample = ((double)editBuffer[nb]) / 32767.0;

            /*
            at this point we multiply with our gain factor
            we dont make a addition to prevent generation of sound where no sound is.
             
             no noise
             0*10=0
             
             noise if zero
             0+10=10 
            */
            gainSample *= gain;
            
            /**
             our signal range cant be higher or lesser -1.0/1.0
             we prevent that the signal got outside our range
             */
            gainSample = (gainSample < -1.0) ? -1.0 : (gainSample > 1.0) ? 1.0 : gainSample;
            
            /*
             This thing here is a little helper to shape our incoming wave.
             The sound gets pretty warm and better and the noise is reduced a lot.
             Feel free to outcomment this line and here again.
             
             You can see here what happens here http://silentmatt.com/javascript-function-plotter/
             Copy this to the command line and hit enter: plot y=(1.5*x)-0.5*x*x*x
             */
             
            gainSample = (1.5 * gainSample) - 0.5 * gainSample * gainSample * gainSample;
            
            // multiply the new signal back to short 
            gainSample = gainSample * 32767.0;
            
            // write calculate sample back to the buffer
            editBuffer[nb] = (SInt16)gainSample;
            tempBuffer[nb] = (short int) gainSample;
        }
    }
    
    unsigned char mp3_buffer[size * 4];
    int mp3_write = lame_encode_buffer(mLame, (short int*) audioBufferList->mBuffers[0].mData, (short int*) audioBufferList->mBuffers[0].mData, size, mp3_buffer, size * 4);

//    int mp3_write = lame_encode_buffer_interleaved(mLame, (short int*) audioBufferList->mBuffers[0].mData, 512, mp3_buffer, size * 4 + 7200);
    printf("\nmp3_write ::: %d\n", mp3_write);
    int status = ShoutOutputStream_Send(mp3_buffer, mp3_write);
    printf("ShoutOutputStream_Send  ---  status----%d",status);
	// copy incoming audio data to the audio buffer
    
    printf("\naudioBufferList->mBuffers[0].mDataByteSize:::%d", audioBufferList->mBuffers[0].mDataByteSize);
	memcpy(audioBuffer.mData, audioBufferList->mBuffers[0].mData, audioBufferList->mBuffers[0].mDataByteSize);
        
        
    } @catch (NSException *exception) {
        NSLog(@"Exception:%@",[exception debugDescription]);
        
        [self.vcScreen showAlert:[exception description]];
        
    } @catch (NSError *error) {
        NSLog(@"Error:%@",[error debugDescription]);
        
        [self.vcScreen showAlert:[error localizedDescription]];
    }
}

- (void)initServer {
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserDefaultKey];
    
    unsigned char *serverIP = (unsigned char *)[(NSString *)[settings valueForKey:kServerIPStorageKey] UTF8String];
    int port = [[settings valueForKey:kServerPortStorageKey] intValue];
    unsigned char *username = (unsigned char *)[(NSString *)[settings valueForKey:kUserNameStorageKey] UTF8String];
    unsigned char *password = (unsigned char *)[(NSString *)[settings valueForKey:kPasswordStorageKey] UTF8String];
    unsigned char *mountpoint = (unsigned char *)[(NSString *)[settings valueForKey:kMountPointStorageKey] UTF8String];
    
    int initStatus = ShoutOutputStream_Init(serverIP, port , mountpoint, username, password, 1);
    
    if (initStatus == -1) {
        NSLog(@"Fail to init stream server.");
        return;
    }
}

- (void)startRecordingAudioBytes:(NSData *)fileData  {
	
	unsigned char *mp3_buffer = (unsigned char *)[fileData bytes];
	
	int mp3_write = fileData.length;
	printf("\nmp3_write ::: %d\n", mp3_write);
	
	int status = [self startRecordingAudioBytes:mp3_buffer withSize:mp3_write];
	printf("\nStatus:%d",status);

}

- (int)startRecordingAudioBytes:(unsigned char *)fileData withSize:(int )mp3_writeValue  {
	
	int status = ShoutOutputStream_Send(fileData, mp3_writeValue);
	
	return status;
}


- (void)streamWavFile:(NSString *)filePath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
            
            fseek(pcm, 4*8192, SEEK_CUR);                               //skip file header
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 44100);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                int status = [self startRecordingAudioBytes:mp3_buffer withSize:write];
                printf("\nStatus:%d",status);
                if (status < 0) {
                    NSLog(@"Error While send data to server");
                    break;
                }
            } while (read != 0);

            lame_close(lame);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
        }
        @catch (NSError *error) {
            NSLog(@"%@",[error description]);
        }
        @finally {
            [self performSelectorOnMainThread:@selector(convertMp3Finish)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    });
}

#pragma mark Error handling

-(void)hasError:(int)statusCode infile:(char*)file atline:(int)line
{
	if (statusCode) {
        [self.vcScreen showAlert:[NSString stringWithFormat:@"Error Code responded %d in file %s on line %d\n", statusCode, file, line]];
		printf("Error Code responded %d in file %s on line %d\n", statusCode, file, line);
	}
}

- (void) convertMp3Finish
{
	[self.vcScreen stopClient];
}

@end
