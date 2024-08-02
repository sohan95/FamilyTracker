#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CacheSlide : NSObject

- (id) init;

- (void)loadImageWithURL:(NSURL *)url type:(NSString *)slideType completionBlock:(void (^)(id slide, NSString *slideType))completionBlock failureBlock:(void (^)(NSURLRequest *request, NSURLResponse *response, NSError* error))failure;
@end
