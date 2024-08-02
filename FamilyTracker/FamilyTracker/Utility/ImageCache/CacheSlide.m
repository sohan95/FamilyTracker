
#import "CacheSlide.h"

#import <CommonCrypto/CommonHMAC.h>

static inline NSString *SlideCacheDirectory() {
    static NSString *_SlideImageCacheDirectory;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        
        _SlideImageCacheDirectory = [[documentsPath stringByAppendingPathComponent:@"/FamilyTracker_User_Profile_Image/"] copy];
        
    });
    
    return _SlideImageCacheDirectory;
}

@interface CacheSlide()

@property (strong, nonatomic) NSOperationQueue *diskOperationQueue;

@end

@implementation CacheSlide

@synthesize diskOperationQueue = _diskOperationQueue;

- (id) init {
    self = [super init];
    if(!self) return nil;
    
    self.diskOperationQueue = [[NSOperationQueue alloc] init];
    
    BOOL isDir = NO;
    
    NSString *directoryPath = SlideCacheDirectory();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDir]) {
//        if (isDir) {
        NSError *error = nil;
            BOOL status = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            NSLog(@"cearte:%d\nError:%@",status, [error debugDescription]);
//        }
    }
    
    return self;
}

- (void)loadImageWithURL:(NSURL *)url
                    type:(NSString *)slideType
         completionBlock:(void (^)(id slide, NSString *slideType))completionBlock
            failureBlock:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError* error))failure {
    
    NSString *slideFilePath = [self cachePathForKey:[url absoluteString]];
    
    if ([slideType isEqualToString:@"video"]) {
        NSRange rang = [[url absoluteString] rangeOfString:@"." options:NSBackwardsSearch];
        slideFilePath = [NSString stringWithFormat:@"%@%.@",slideFilePath,[[url absoluteString] substringFromIndex:rang.location]];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:slideFilePath]) {
        // Not Exist, Download and save
        
        // add by murtuza start
        // remove previous image from dir if exist dir
        NSError * error;
        BOOL success = [fileManager removeItemAtPath:SlideCacheDirectory() error:&error];
        if(success) {
            NSLog(@"remove successfully");
        }else {
            NSLog(@"file not exist");
        }
        // create file start
        BOOL isDir = NO;
        if (![fileManager fileExistsAtPath:slideFilePath isDirectory:&isDir]) {
            //        if (isDir) {
            NSError *error = nil;
            BOOL status = [[NSFileManager defaultManager] createDirectoryAtPath:SlideCacheDirectory()
                                                    withIntermediateDirectories:YES
                                                                     attributes:nil
                                                                          error:&error];
            NSLog(@"cearte:%d\nError:%@",status, [error debugDescription]);
            //        }
            slideFilePath = [self cachePathForKey:[url absoluteString]];
        }
         // add by murtuza end
        // create file end
        
        if ([slideType isEqualToString:@"image"]) {
            //Download Image
            [self _downloadAndWriteImageForURL:url cachePath:slideFilePath completionBlock:completionBlock failureBlock:failure];
        }
        else {
            //Download Video
            [self _downloadAndWriteVideoForURL:url cachePath:slideFilePath completionBlock:completionBlock failureBlock:failure];
        }
    }
    else {
        if ([slideType isEqualToString:@"image"]) {
            UIImage *image = [self imageFromDiskForKey:slideFilePath];
            
            if (image) {
                completionBlock(image, slideType);
            }
        }
        else {
            
            // Send video local URL to sender
            completionBlock(slideFilePath, slideType);
        }
    }
}

- (void) _downloadAndWriteImageForURL:(NSURL *)url
                            cachePath:(NSString *)cachePath
                      completionBlock:(void (^)(UIImage *image, NSString *slideType))completion
                         failureBlock:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError* error))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(failure)
                    failure(request, response, error);
            });
            return;
        }
        
        UIImage *i = [[UIImage alloc] initWithData:data];
        if (!i)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Failed to init image with data from for URL: %@", url] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"AlertErrorDomain" code:1 userInfo:errorDetail];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(failure) failure(request, response, error);
            });
        }
        else
        {
            NSInvocation *writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
            
            [writeInvocation setTarget:self];
            [writeInvocation setSelector:@selector(writeData:toPath:)];
            [writeInvocation setArgument:&data atIndex:2];
            [writeInvocation setArgument:&cachePath atIndex:3];
            
            [self performDiskWriteOperation:writeInvocation];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completion)
                    completion(i, @"image");
                
            });
        }
    });
}

- (void)_downloadAndWriteVideoForURL:(NSURL *)url cachePath:(NSString *)cachePath completionBlock:(void (^)(NSString *cachePath, NSString *slideType))completion failureBlock:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError* error))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failure)
                    failure(request, response, error);
            });
            return;
        }
        
        if (data.length <=0)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:[NSString stringWithFormat:@"Failed to init video with data from for URL: %@", url] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"AlertErrorDomain" code:1 userInfo:errorDetail];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(failure)
                    failure(request, response, error);
            });
        }
        else
        {
            NSInvocation *writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
            
            [writeInvocation setTarget:self];
            [writeInvocation setSelector:@selector(writeData:toPath:)];
            [writeInvocation setArgument:&data atIndex:2];
            [writeInvocation setArgument:&cachePath atIndex:3];
            
            [self performDiskWriteOperation:writeInvocation];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completion)
                    completion(cachePath, @"video");
            });
        }
    });
}

- (void) writeData:(NSData*)data toPath:(NSString *)path {
    [data writeToFile:path atomically:YES];
}

- (void) performDiskWriteOperation:(NSInvocation *)invoction {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invoction];
    
    [self.diskOperationQueue addOperation:operation];
}

-(void)downloadVideoAndSave :(NSString*)videoUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *yourVideoData=[NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
        
        if (yourVideoData) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"video.mp4"];
            
            if([yourVideoData writeToFile:filePath atomically:YES])
            {
                NSLog(@"write successfull");
            }
            else{
                NSLog(@"write failed");
            }
        }
    });
}

- (UIImage *)imageFromDiskForKey:(NSString *)slideFilePath {
    UIImage *i = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:slideFilePath options:0 error:NULL]];
    return i;
}

- (NSString *)cachePathForKey:(NSString *)url {
    NSString *fileName = [NSString stringWithFormat:@"UserProfileImage-%@", [CacheSlide SHA1FromString:url]];
    return [SlideCacheDirectory() stringByAppendingPathComponent:fileName];
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
