//
//  CacheManager.h
//  CiscoIceCastAudioStream
//
//  Created by Apple on 22/12/16.
//  Copyright © 2016 eInfochips. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CacheManager : NSObject

- (id) init;

- (NSString *)cacheMusicPathForKey:(NSString *)url;

- (void)saveMusicFromLibraryToDocumentDir:(MPMediaItem *)musicItem
                          completionBlock:(void (^)(NSString *localSongURL, NSInteger statusCode))completionBlock
                             failureBlock:(void (^)(NSError* error))failure;

- (void)removeAllCachedFiles;

- (void)removeLocalExportedFile:(NSString *)path;
@end
