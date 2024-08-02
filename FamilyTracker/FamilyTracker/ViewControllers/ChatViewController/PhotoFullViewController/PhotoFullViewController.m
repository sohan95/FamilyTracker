//
//  PhotoFullViewController.m
//  AudioCallKitSampleProject
//
//  Created by Md. Shahanur Rahmann on 11/11/15.
//  Copyright © 2015 Qaium Hossain. All rights reserved.
//

#import "PhotoFullViewController.h"
#import "Constants.h"
//#import "UIImageView+AFNetworking.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "FamilyTrackerDefine.h"
#import "ModelManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@import Photos;

@interface PhotoFullViewController ()

@end

@implementation PhotoFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnBack setTitle:@"Back" forState:UIControlStateNormal];
    
    //---PhotoImage fullscreen show---//
//    NSString *sender = [self.msgDictionary objectForKey:kSenderNameKey];
//    
//    NSString *urlStringLocal = [self.msgDictionary objectForKey:kResourceUrlLocalKey];
//    NSString *urlStringRemote = [self.msgDictionary objectForKey:kResourceUrlRemoteKey];
    
    NSString *urlStringRemote = [self.msgDictionary objectForKey:kMsgKey];
     [self loadPhotofromUrl:urlStringRemote];
    
//    if ([sender isEqualToString:@"you"] || [sender isEqualToString:[ModelManager sharedInstance].user.userName]) {
//        [self loadPhotofromLocalUrl:urlStringLocal];
//    } else {
//        [self loadPhotofromUrl:urlStringRemote];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)closeFullScreenPhotoView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark LoadPhotoMethods
- (void)loadPhotofromUrl:(NSString*)photoUrlString {
    //---Need lazy loading----//
    NSURL* url = [NSURL URLWithString:photoUrlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response,
                                               NSData * data,
                                               NSError * error) {
                               if (!error) {
                                   UIImage *tempImage = [UIImage imageWithData:data];
                                   self.photoImageView.image = tempImage;
                                   float widthRatio = self.photoImageView.bounds.size.width / tempImage.size.width;
                                   float heightRatio = self.photoImageView.bounds.size.height / tempImage.size.height;
                                   float scale = MIN(widthRatio, heightRatio);
                                   float resizedWidth = scale * tempImage.size.width;
                                   float resizedHeight = scale * tempImage.size.height;
                                   [self.photoImageView setFrame:CGRectMake(0, 0, resizedWidth, resizedHeight)];
                                   self.photoImageView.center = self.photoImageView.superview.center;
                                   // do whatever you want with image
                                   self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                                   self.photoImageView.clipsToBounds = YES;
                                   [self.photoImageView sizeToFit];
                               }
                           }];
    //---Lazyloading---//
}

- (void)loadPhotofromLocalUrl:(NSString*)localPhotoUrlString {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[NSURL URLWithString:localPhotoUrlString] resultBlock:^(ALAsset *asset) {
        // here we have received the image data, now you can easily display it wherever you like
        UIImage *tempImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        if (tempImage != nil) {
            self.photoImageView.image = tempImage;
            float widthRatio = self.photoImageView.bounds.size.width/tempImage.size.width;
            float heightRatio = self.photoImageView.bounds.size.height/tempImage.size.height;
            float scale = MIN(widthRatio, heightRatio);
            float resizedWidth = scale * tempImage.size.width;
            float resizedHeight = scale * tempImage.size.height;
            [self.photoImageView setFrame:CGRectMake(0, 0, resizedWidth, resizedHeight)];
            self.photoImageView.center = self.photoImageView.superview.center;
            NSLog(@"photoImageView w=%f, h=%f",self.photoImageView.bounds.size.width,self.photoImageView.bounds.size.height);
            self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.photoImageView.clipsToBounds = YES;
            [self.photoImageView sizeToFit];
            NSLog(@"Image loaded successfully!");
        } else {
            self.photoImageView.image = [UIImage imageNamed:@"photoPlaceholder"];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"An error occurred while loading image: %@", error.description);
    }];

    /*
    //---Need lazy loading---//
    PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];
    cachingImageManager.allowsCachingHighQualityImages = NO;
    PHAsset *asset;
    asset = [[PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:[NSURL URLWithString:localPhotoUrlString]] options:nil] lastObject];
    
    NSMutableArray<PHAsset *> *assets = [[NSMutableArray alloc] initWithObjects:asset, nil];
    
    [cachingImageManager startCachingImagesForAssets:assets
                                          targetSize:PHImageManagerMaximumSize
                                         contentMode:PHImageContentModeAspectFit
                                             options:nil];
    assets = nil;
    
    NSInteger retinaScale = [UIScreen mainScreen].scale;
    CGSize retinaSquare = CGSizeMake(100*retinaScale, 100*retinaScale);
    
    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
    CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
    CGRect cropRect = CGRectApplyAffineTransform(square,
                                                 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                            1.0 / asset.pixelHeight));
    
    cropToSquare.normalizedCropRect = cropRect;
    cropToSquare.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:retinaSquare contentMode:PHImageContentModeAspectFill options:cropToSquare resultHandler:^(UIImage *result, NSDictionary *info) {
        //this block will be called synchronously
        if (result != nil) {
            self.photoImageView.image = result;
            UIImage *tempImage = result;
            float widthRatio = self.photoImageView.bounds.size.width / tempImage.size.width;
            float heightRatio = self.photoImageView.bounds.size.height / tempImage.size.height;
            float scale = MIN(widthRatio, heightRatio);
            float resizedWidth = scale * tempImage.size.width;
            float resizedHeight = scale * tempImage.size.height;
            [self.photoImageView setFrame:CGRectMake(0, 0, resizedWidth, resizedHeight)];
            self.photoImageView.center = self.photoImageView.superview.center;
            // do whatever you want with image
            self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.photoImageView.clipsToBounds = YES;
            [self.photoImageView sizeToFit];
        } else {
            self.photoImageView.image = [UIImage imageNamed:@"photoPlaceholder"];
        }
    }];*/
}

@end
