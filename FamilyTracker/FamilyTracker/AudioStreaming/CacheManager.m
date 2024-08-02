//
//  CacheManager.h
//  CiscoIceCastAudioStream
//
//  Created by Apple on 22/12/16.
//  Copyright © 2016 eInfochips. All rights reserved.
//

#import "CacheManager.h"
#import "Constants.h"

#import <CommonCrypto/CommonHMAC.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

static inline NSString *MusicCacheDirectory() {
    static NSString *_SlideImageCacheDirectory;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = paths[0];
        
        _SlideImageCacheDirectory = [[documentsPath stringByAppendingPathComponent:@"/Music/"] copy];
        
    });
    
    return _SlideImageCacheDirectory;
}

@interface CacheManager()
{

}
@property (strong, nonatomic) NSOperationQueue *diskOperationQueue;

@end

@implementation CacheManager

@synthesize diskOperationQueue = _diskOperationQueue;

- (id) init {
    self = [super init];
    if(!self) return nil;
    
    self.diskOperationQueue = [[NSOperationQueue alloc] init];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *musicDirectoryPath = MusicCacheDirectory();
    
    isDir = NO;
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:musicDirectoryPath isDirectory:&isDir]) {
        NSError *error = nil;
        BOOL status = [[NSFileManager defaultManager] createDirectoryAtPath:musicDirectoryPath
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        NSLog(@"music Dir create :%d\nError:%@",status, [error debugDescription]);
    }
    
    return self;
}

- (void)saveMusicFromLibraryToDocumentDir:(MPMediaItem *)musicItem
                          completionBlock:(void (^)(NSString *localSongURL, NSInteger statusCode))completionBlock
                             failureBlock:(void (^)(NSError* error))failure
{
    AVURLAsset *sset = [AVURLAsset assetWithURL:[musicItem valueForProperty:MPMediaItemPropertyAssetURL]];
    
    NSString *appleFileType = @"com.apple.quicktime-movie";
    
    NSString *fileExtension = [[[sset.URL absoluteString] componentsSeparatedByString:@"?"][0] pathExtension];
    
    NSString *songTitle = [musicItem valueForProperty:MPMediaItemPropertyTitle];
    songTitle = [NSString stringWithFormat:@"%@.%@",songTitle,appleFileType];
    
    NSString *mp3Path = [self cacheMusicPathForKey:songTitle];
    mp3Path = [NSString stringWithFormat:@"%@.%@",mp3Path,fileExtension];
    
    NSLog(@"Search already exist file or not:%@",mp3Path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:mp3Path]) {
        [self exportMusicToApp:sset fileTitle:songTitle completionBlock:completionBlock failureBlock:failure];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(completionBlock)
            completionBlock(mp3Path, 200);
        });
    }
}

- (void)removeAllCachedFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    
    [self emptyDirectory:documentsPath];
}

- (void)emptyDirectory:(NSString *)directoryPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    for (NSString *filePath in files) {
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (isDir) {
                [self emptyDirectory:filePath];
            }
            
            if ([fileManager isDeletableFileAtPath:filePath]) {
                NSError *error = NULL;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    NSLog(@"Error while remove file:%@\nError:%@",filePath, [error debugDescription]);
                    break;
                }
            }
        }
    }
    
    if ([fileManager isDeletableFileAtPath:directoryPath]) {
        NSError *error = NULL;
        [fileManager removeItemAtPath:directoryPath error:&error];
        
        if (error) {
            NSLog(@"Error while remove file:%@\nError:%@",directoryPath, [error debugDescription]);
        }
    }
}

#pragma mark - Private Methods

- (void)exportMusicToApp:(AVURLAsset *)sset
               fileTitle:(NSString *)songTitle
         completionBlock:(void (^)(NSString *localSongURL, NSInteger statusCode))completion
            failureBlock:(void (^)(NSError* error))failure
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get the extension of the file.
        NSString *fileType = [[[sset.URL absoluteString] componentsSeparatedByString:@"?"][0] pathExtension];
        
        //init export, here you must set "presentName" argument to "AVAssetExportPresetPassthrough". If not, you will can't export mp3 correct.
        AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:sset presetName:AVAssetExportPresetPassthrough];
        
        NSLog(@"export.supportedFileTypes : %@",export.supportedFileTypes);
        //export to mov format.
        export.outputFileType = @"com.apple.quicktime-movie";
        
        export.shouldOptimizeForNetworkUse = YES;
        
        NSString *extension = export.outputFileType;
        
        NSLog(@"extension %@",extension);
        NSString *path = [self cacheMusicPathForKey:songTitle];
        path = [path stringByAppendingFormat:@".%@",extension];
        
        CacheManager *cacheObj = [[CacheManager alloc] init];
        
        NSURL *outputURL = [NSURL fileURLWithPath:path];
        export.outputURL = outputURL;
        [export exportAsynchronouslyWithCompletionHandler:^{
            
            NSLog(@"Status:%ld",(long)export.status);
            
            if (export.status == AVAssetExportSessionStatusCompleted)
            {
                //then rename mov format to the original format.
                NSFileManager *manage = [NSFileManager defaultManager];
                NSString *mp3Path = [cacheObj cacheMusicPathForKey:songTitle];
                
                mp3Path = [NSString stringWithFormat:@"%@.%@",mp3Path, fileType];
                
                NSLog(@"CACHE mp3Path --- %@",mp3Path);
                NSError *error = nil;
                [manage moveItemAtPath:path toPath:mp3Path error:&error];
                
                if (error) {
                    NSLog(@"error %@",error);
                    
                    [self removeLocalExportedFile:path];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(failure)
                            failure(error);
                    });
                } else {
                    
                    [self removeLocalExportedFile:path];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(completion)
                            completion(mp3Path, 200);
                    });
                }
            }
            else
            {
                NSLog(@"%@",export.error);
                
                [self removeLocalExportedFile:path];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failure)
                        failure(export.error);
                });
            }
            
        }];
    });
}

- (void)removeLocalExportedFile:(NSString *)path {
    
    NSLog(@"removeLocalExportedFile ::%@",path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = NULL;
        [fileManager removeItemAtPath:path error:&error];
        
        if (error) {
            NSLog(@"Error while remove file:%@\nError:%@",path, [error debugDescription]);
        }
    }
}

- (NSString *)cacheMusicPathForKey:(NSString *)url {
    NSString *fileName = [NSString stringWithFormat:@"Music-%@", [CacheManager SHA1FromString:url]];
    return [MusicCacheDirectory() stringByAppendingPathComponent:fileName];
}

+ (NSString *)SHA1FromString:(NSString *)string
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CC_SHA1([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    return nil;
}

@end
