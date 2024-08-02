//
//  ChatViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/11/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "HexToRGB.h"
#import "ModelManager.h"
#import "Common.h"
#import "FamilyTrackerReachibility.h"
#import "DbHelper.h"
#import "GlobalServiceManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
//#import "UIImageView+AFNetworking.h"
#import "CacheSlide.h"
#import "PhotoFullViewController.h"
#import "PlayVideoViewController.h"
#import <Photos/Photos.h>
#import "AudioRecordingViewController.h"
//#import <MediaPlayer/MediaPlayer.h>
//#import "AudioPlayBackViewController.h"
#import "Mp3ToBase64String.h"
#import "ModelManager.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"

@import Photos;

@interface ChatViewController ()<NSURLSessionDownloadDelegate>{
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadTask;
}

@property (nonatomic, strong) AudioRecordingViewController *audioRecordVC;
@property (nonatomic, strong) AVPlayer *songPlayer;

- (void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler;

@end

@implementation ChatViewController

@synthesize messageField, chatWithUser, tView;
@synthesize activeUserLabel;
@synthesize onlineParticipants;

@synthesize chatManager = _chatManager;

//typedef struct {
//    CGFloat top, left, bottom, right;
//} UIEdgeInsets;

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    globalData = [GlobalData sharedInstance];
    //---Set textFieldBgImageView---//
    
    @try {
        UIImage *fieldBgImage = [[UIImage imageNamed:TEXT_FIELD_INACTIVE] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 135, 25, 135)];
        _chatFieldImageView.image = fieldBgImage;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
//    self.chatFieldImageView.layer.cornerRadius = 30;
//    self.chatFieldImageView.layer.masksToBounds = YES;
    self.tView.delegate = self;
    self.tView.dataSource = self;
    [self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SendAudioNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendAudioNotification:)
                                                 name:@"SendAudioNotification"
                                               object:nil];
    isPlayBackFinished = YES;
    [self initService];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                            delegate:self
                                       delegateQueue:[NSOperationQueue mainQueue]
               ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    globalData.currentVC = self;
    self.chatManager = [ChatManager instance];
    _chatManager._messageDelegate = self;

    [_chatManager addTrunkToChatUser:chatWithUser];
    if (delegate.isConference == 1) {
        self.chatWithUser = [[self.chatWithUser stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        delegate.activeGroupName = self.chatWithUser;
    }

    delegate.isActiveChatView = 1;
    self.title = chatWithUser;
    delegate.currentViewController = self;

    //---goto current chat cell---//
    [self reloadTableData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    delegate.isActiveChatView = 0;
    if (delegate.isConference==1) {
        //delegate.isConference = 0;
        delegate.activeGroupName = @"";
        //[chatManager.xmppRoom leaveRoom];
    }
    [self.songPlayer pause];
    [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableData {
    if (globalData.messages.count > 1) {
        [self.tView reloadData];
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                       inSection:0];
        [self.tView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
    }
}

- (CGSize)getStringSize:(NSString *)string {
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:string
     attributes:@
     {
     NSFontAttributeName: [UIFont boldSystemFontOfSize:13]
     }];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int textViewWidh = screenSize.width/2;
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){textViewWidh, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size;
}

#pragma mark - All Documets Send Methods
//- (void)sendPhotoMessageAfterUpload {
//    self.messageType = kMsgResourcePhoto;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        [self sendMultimadiaMsg];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tView reloadData];
//            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
//                                                           inSection:0];
//            [self.tView scrollToRowAtIndexPath:topIndexPath
//                              atScrollPosition:UITableViewScrollPositionMiddle
//                                      animated:YES];
//        });
//    });
//}

- (void)convertMultimediaMessage:(NSURL *)url {
    //---show hud---//
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [hud setLabelText:NSLocalizedString(@"Uploading to server.",nil)];
    [self.view addSubview:hud];
    [hud show:YES];
    
    [[Mp3ToBase64String sharedInstance] musicConvert:url withFileType:@".m4v" WithCompletionBlock:^(id object, NSError *error) {
        
        if (object) {
            [self uploadMultimedia:object withType:@".m4v"];
        } else {
            // MBProgressHUD hide
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
//            [self showAlert:@"Error" andMessage:error.localizedDescription];
        }
    }];
}

- (void)sendVideoMessageAfterUpload {
    self.messageType = kMsgResourceVideo;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self sendMultimadiaMsg];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tView reloadData];
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                           inSection:0];
            [self.tView scrollToRowAtIndexPath:topIndexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
        });
    });
}

#pragma mark - NotificationCenter Methods -
- (void)sendAudioNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"SendAudioNotification"]) {
        [self.audioRecordVC dismissViewControllerAnimated:YES completion:nil];
        self.messageType = kMsgResourceAudio;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _recordedLocalAudioUrlStr = [prefs URLForKey:@"recordedAudioFile"].absoluteString;
         
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self sendMultimadiaMsg];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tView reloadData];
                NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                               inSection:0];
                [self.tView scrollToRowAtIndexPath:topIndexPath
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:YES];
            });
        });
    }
}

#pragma mark - User Define Methods
- (void)pickPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.navigationBar.tintColor = [UIColor whiteColor];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
}

- (void)pickVideo {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.navigationBar.tintColor = [UIColor whiteColor];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:videoPicker animated:YES completion:nil];
}

- (void)takeVideo {
    UIImagePickerController * videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.navigationBar.tintColor = [UIColor whiteColor];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
        videoPicker.mediaTypes =  [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.showsCameraControls = YES;
        videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        videoPicker.delegate = self;
        videoPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:videoPicker animated:YES completion:nil];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    }
}

- (void)RecordAudio {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    _audioRecordVC = (AudioRecordingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AudioRecordingViewController"];
    [self.navigationController presentViewController:_audioRecordVC animated:YES completion:nil];
}


#pragma mark - Image Picker Controller delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block PHFetchResult *photosAsset;
    __block PHAssetCollection *collection;
    __block PHObjectPlaceholder *placeholder;
    //    NSLog(@"Media Info: %@", info);
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        self.messageType = kMsgResourcePhoto;
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
                NSURL *imageUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
                self.selectedLocalImageUrlStr = imageUrl.absoluteString;
                UIImage *image = (UIImage*)[info objectForKey:@"UIImagePickerControllerOriginalImage"];
                [self uploadImageToServer:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", info);
            }
        } else {
             //---Find the album---//
             PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
             fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"SurroundComms"];
             collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
             subtype:PHAssetCollectionSubtypeAny
             options:fetchOptions].firstObject;
             //---Create the album---//
             if (!collection) {
                 [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                     PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"SurroundComms"];
                     placeholder = [createAlbum placeholderForCreatedAssetCollection];
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (success) {
                            PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                                        options:nil];
                            collection = collectionFetchResult.firstObject;
                        }
                    }];
             }
             //---Save to the album---//
             [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                 UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
                 PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                 placeholder = [assetRequest placeholderForCreatedAsset];
                 photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                 PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection
                                                                                                                               assets:photosAsset];
                 [albumChangeRequest addAssets:@[placeholder]];
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        NSString *UUID = [placeholder.localIdentifier substringToIndex:36];
                        NSString *imageRef = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
                        self.selectedLocalImageUrlStr = imageRef;
                        UIImage *image = (UIImage*)[info objectForKey:@"UIImagePickerControllerOriginalImage"];
                        [self uploadImageToServer:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [picker dismissViewControllerAnimated:YES completion:^{
                            }];
                        });
                    } else {
                        NSLog(@"%@", error);
                    }
             }];
        }
    } else if ([mediaType isEqualToString:@"public.movie"]) {
        self.messageType = kMsgResourceVideo;
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            NSURL *pickVideoURL= [info objectForKey:UIImagePickerControllerReferenceURL];
            NSString *imageRef = pickVideoURL.absoluteString;
            self.selectedLocalVideoUrlStr = imageRef;
            [[NSUserDefaults standardUserDefaults] setObject:imageRef forKey:@"localVideoLink"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [picker dismissViewControllerAnimated:YES completion:^{
                }];
            });
            [self convertMultimediaMessage:pickVideoURL];
        } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Find the album
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"SurroundComms"];
            collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                  subtype:PHAssetCollectionSubtypeAny
                                                                  options:fetchOptions].firstObject;
            // Create the album
            if (!collection) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"SurroundComms"];
                    placeholder = [createAlbum placeholderForCreatedAssetCollection];
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                                    options:nil];
                        collection = collectionFetchResult.firstObject;
                    }
                }];
            }
            // Save to the album
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                NSURL *recordedVideoURL= [info objectForKey:UIImagePickerControllerMediaURL];
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:recordedVideoURL];
                placeholder = [assetRequest placeholderForCreatedAsset];
                photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection
                                                                                                                              assets:photosAsset];
                [albumChangeRequest addAssets:@[placeholder]];
                
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSString *UUID = [placeholder.localIdentifier substringToIndex:36];
                    NSString *videoRef = [NSString stringWithFormat:@"assets-library://asset/asset.MOV?id=%@&ext=MOV", UUID];
                    self.selectedLocalVideoUrlStr = videoRef;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [picker dismissViewControllerAnimated:YES completion:^{
                        }];
                    });
                    [self convertMultimediaMessage:[NSURL URLWithString:videoRef]];
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Button Actions
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showResourceOption:(UIButton*)sender {
    [self.songPlayer pause];
    [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:@"Choose Type"
                                   message:@""
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* menuItem1 = [UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self pickPhoto];
                                                      }];
    UIAlertAction* menuItem2 = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self takePhoto];
                                                      }];
    UIAlertAction *menuItem3 = [UIAlertAction actionWithTitle:@"Select Video" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self pickVideo];
                                                      }];
    UIAlertAction *menuItem4 = [UIAlertAction actionWithTitle:@"Capture Video" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self takeVideo];
                                                      }];
    UIAlertAction *menuItem5 = [UIAlertAction actionWithTitle:@"Record Audio" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self RecordAudio];
                                                      }];
    [alert addAction:menuItem1];
    [alert addAction:menuItem2];
    [alert addAction:menuItem3];
    [alert addAction:menuItem4];
    [alert addAction:menuItem5];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancel];
    }
    
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert
                                                     popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)sendMSG:(id)sender {
    self.messageType = kMsgResourceText;
    [self sendMultimadiaMsg];
}

- (void)sendMultimadiaMsg {
    NSString *videoUrlRemote = @"http://techslides.com/demos/sample-videos/small.mp4";
    NSString *photoUrlRemote = @"https://s-media-cache-ak0.pinimg.com/736x/f2/36/99/f23699a9050848894a92155a5519a2ee.jpg";
    NSString *audioUrlRemote = @"http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3";
    
    [self.messageField resignFirstResponder];
    self.messageField.text = [self.messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([FamilyTrackerReachibility isUnreachable]) {
        NSString *messageStr = self.messageField.text;
        if (messageStr.length > 0 ) {
            [self insertIntoSqliteDb:messageStr];
            //--->Message Element-2---//
            self.messageField.text = @"";
            NSString *currentDateStr = [Common getEpochTimeFromDate:[NSDate date]];
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:@"you" forKey:kSenderKey];
            [m setObject:@"you" forKey:kSenderNameKey];
            [m setObject:self.messageType forKey:kMsgResourceTypeKey];
            [m setObject:[messageStr substituteEmoticons] forKey:kMsgKey];

            [m setObject:currentDateStr forKey:kTimeStampKey];
            
            [globalData.messages addObject:m];
            ///<---Message Element-2---//
            [self.tView reloadData];
        }
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                       inSection:0];
        [self.tView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
    } else {
        NSString *messageStr = self.messageField.text;
        //--->Message Element-2---//
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:@"you" forKey:kSenderKey];
        [m setObject:@"you" forKey:kSenderNameKey];
        
        [m setObject:self.messageType forKey:kMsgResourceTypeKey];
        //---Message Element-1---//
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        //---Message Element-1---//
        [message addAttributeWithName:kMsgTypeKey stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        if ([self.messageType isEqualToString:kMsgResourceText]) {
            if ([messageStr length] <= 0) return;
            [body setStringValue:messageStr];
            [m setObject:[messageStr substituteEmoticons] forKey:kMsgKey];
        } else if ([self.messageType isEqualToString:kMsgResourcePhoto]) {
            [body setStringValue:photoUrlRemote];
            [m setObject:photoUrlRemote forKey:kMsgKey];
        } else if ([self.messageType isEqualToString:kMsgResourceAudio]) {
            [body setStringValue:audioUrlRemote];
            [m setObject:audioUrlRemote forKey:kMsgKey];
        } else if ([self.messageType isEqualToString:kMsgResourceVideo]) {
            [body setStringValue:videoUrlRemote];
            [m setObject:videoUrlRemote forKey:kMsgKey];
        }
        
        [message addChild:body];
        //---Set Time---//
        NSString *currentDateStr = [Common getEpochTimeFromDate:[NSDate date]];
        NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        [properties addAttributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        //---Property for timeStamp---//
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        
        NSXMLElement *resourceType = [NSXMLElement elementWithName:@"name"];
        [resourceType setStringValue:kMsgResourceTypeKey];
        [property addChild:resourceType];
        
        NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
        [value addAttributeWithName:kMsgTypeKey stringValue:@"string"];
        [value setStringValue:self.messageType];
        [property addChild:value];
        [properties addChild:property];
        //---End property for TimeStamp
        
        //---Property for timeStamp---//
        NSXMLElement *property1 = [NSXMLElement elementWithName:@"property"];
        NSXMLElement *time = [NSXMLElement elementWithName:@"name"];
        [time setStringValue:kTimeStampKey];
        [property1 addChild:time];
        
        NSXMLElement *value1 = [NSXMLElement elementWithName:@"value"];
        [value1 addAttributeWithName:kMsgTypeKey stringValue:@"long"];
        [value1 setStringValue:currentDateStr];
        [property1 addChild:value1];
        [properties addChild:property1];
        //---End property for TimeStamp
        [message addChild:properties];
        //---End set Time---//
        
        //---End Message Element-1---//
        [m setObject:currentDateStr forKey:kTimeStampKey];
        //---End Message Element-2---//
        [globalData.messages addObject:m];
        [_chatManager sendMessage:message];
        self.messageField.text = @"";
        
        if ([self.messageType isEqualToString:kMsgResourceText]) {
            [self.tView reloadData];
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                           inSection:0];
            [self.tView scrollToRowAtIndexPath:topIndexPath 
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];
        }
    }
}

#pragma mark - TextField Delegates -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self sendMSG:nil];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextView *)textView {
    [self animateTextView: YES];
}

- (void)textFieldDidEndEditing:(UITextView *)textView {
    [self animateTextView:NO];
}

- (void) animateTextView:(BOOL) up {
    int keyboardHeight;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        NSLog(@"ipad");
        keyboardHeight = 323;
    } else {
        keyboardHeight = 263;
    }
    const int movementDistance = keyboardHeight; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

#pragma mark - Table view delegates
static CGFloat padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *s = (NSDictionary *) [globalData.messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[SMMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (![s objectForKey:kMsgResourceTypeKey] ) {
        return nil;
    }
    
    NSString *msgResourceType = [s objectForKey:kMsgResourceTypeKey];
    NSString *sender = [s objectForKey:kSenderNameKey];
    NSString *message = [s objectForKey:kMsgKey];
    NSString *time = [s objectForKey:kTimeStampKey];
    time = [Common getStringFromEpochTime:time];
    CGSize size = [self getStringSize:message];
    CGSize timeLabelSize = [self getStringSize:time];
    CGSize senderLabelSize = [self getStringSize:sender];
    
    int imageWidth = 25;// for buddies
    int imageHeight = 25;
    int verticalMargin = 20;
    int horizontalMargin = 20;
    int senderNameLabelWidth = 300;
    int senderNameLabelHeight = 20;
    int senderAndTimeLabelWidth = 300;
    int senderAndTimeLabelHeight = 20;
    
    CGSize standardWidth = CGSizeMake(100, 20);
    CGSize biggerWidthSize = senderLabelSize.width > standardWidth.width ? senderLabelSize : standardWidth;
    int containerWidth = size.width > biggerWidthSize.width ? size.width : biggerWidthSize.width;
    containerWidth =  containerWidth > timeLabelSize.width ?  containerWidth : timeLabelSize.width;
    cell.backgroundColor = [UIColor clearColor];
    cell.messageContentView.font = [UIFont systemFontOfSize:13.0];
    cell.messageContentView.text = message;
    [cell.messageContentView sizeToFit];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = YES;
    UIImage *bgImage = [UIImage imageNamed:@"PlaceHolder"];
    
    if ([sender isEqualToString:@"you"] || [sender isEqualToString:[ModelManager sharedInstance].user.userName]) {
        //---PlaceHolder Images---//
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        cell.bgImageView.image = bgImage;
        cell.bgImageView.frame = CGRectMake(5, 0, imageWidth, imageHeight);
       if ([msgResourceType isEqualToString:kMsgResourceText]) {
            //--set Disable buttons---//
            [cell.photoShowBtn setEnabled:NO];
            [cell.videoPlayBtn setEnabled:NO];
            [cell.photoThumbnail setHidden:YES];
            [cell.audioPlayBtn setEnabled:NO];
            //---set show relevant button---//
            [cell.messageContentView setHidden:NO];
           
            //---set senderNameLabel frame---//
            cell.senderNameLabel.text = [NSString stringWithFormat:@"Me"];
            cell.senderNameLabel.frame = CGRectMake(10,5,
                                                       senderNameLabelWidth,
                                                    senderNameLabelHeight);
//            cell.senderNameLabel.textColor = [UIColor whiteColor];
            //--set message frame---//
            [cell.messageContentView setFrame:CGRectMake(5,
                                                         senderNameLabelHeight,
                                                         size.width+10,
                                                         size.height+horizontalMargin)];
            //---set TimeLabel frame---//
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
            cell.senderAndTimeLabel.frame = CGRectMake(10,
                                                       cell.messageContentView.frame.size.height+10,
                                                       senderAndTimeLabelWidth,
                                                       senderAndTimeLabelHeight);
//            cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
            //---Set ContainerImageView Frame and image---//
            [cell.containerImageView setFrame:CGRectMake(0,0,
                                                         containerWidth+horizontalMargin+5,
                                                         size.height+senderAndTimeLabelHeight+verticalMargin+20)];
            //---Image with cap insets---//
            UIImage *bgImage = [UIImage imageNamed:@"RightBubble"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
            cell.containerImageView.image = bgImage;
            //---Set ContainerView Frame---//
            int containerX = screenSize.width - (containerWidth + imageWidth + 25);
            [cell.containerView setFrame:CGRectMake(containerX,
                                                    0,
                                                    containerWidth+horizontalMargin+5,
                                                    size.height+senderAndTimeLabelHeight+verticalMargin+20)];
       } else if ([msgResourceType isEqualToString:kMsgResourcePhoto]) {
           CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
           NSURL *imageURL = [NSURL URLWithString:message];
           [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
               if ([type isEqualToString:@"image"]) {
                   cell.photoThumbnail.image = (UIImage *)cachedSlide;
               }
           } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
               //        NSLog(@"Image cache fail");
           }];
           //---Hide MessageContentView---//
           [cell.audioPlayBtn setEnabled:NO];
           [cell.videoPlayBtn setEnabled:NO];
           [cell.messageContentView setHidden:YES];
           //---set show relevant button---//
           [cell.photoShowBtn setEnabled:YES];
           //---set Thumbnail frame---//
           [cell.photoThumbnail setHidden:NO];
           [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
           //---set photoShowBtn frame---//
           [cell.photoShowBtn setFrame:CGRectMake(7,5,kThumbnailWidth-20,kThumbnailHeight-10)];
           cell.photoShowBtn.tag = indexPath.row;
           [cell.photoShowBtn addTarget:self action:@selector(photoFullViewAction:) forControlEvents:UIControlEventTouchUpInside];
           //---set senderNameLabel frame---//
           cell.senderNameLabel.text = [NSString stringWithFormat:@"Me"];
           cell.senderNameLabel.frame = CGRectMake(10,5,
                                                   senderNameLabelWidth,
                                                   senderNameLabelHeight);
//           cell.senderNameLabel.textColor = [UIColor whiteColor];
           //---set TimeLabel frame---//
           cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
           [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
           cell.senderAndTimeLabel.frame = CGRectMake(10,
                                                      kThumbnailWidth-senderAndTimeLabelHeight-10,
                                                      senderAndTimeLabelWidth,
                                                      senderAndTimeLabelHeight);
//           cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
           
           //---Set ContainerImageView Frame and image---//
           [cell.containerImageView setFrame:CGRectMake(0,0,kThumbnailWidth,
                                                        kThumbnailHeight)];
           //---Image with cap insets---//
           UIImage *bgImage = [UIImage imageNamed:@"RightBubble"];
           bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
           cell.containerImageView.image = bgImage;
           //---Set ContainerView Frame---//
           int containerX = screenSize.width - (kThumbnailWidth + imageWidth + 25);
           [cell.containerView setFrame:CGRectMake(containerX,
                                                   0,
                                                   kThumbnailWidth,
                                                   kThumbnailHeight)];
           
       } else if ([msgResourceType isEqualToString:kMsgResourceVideo]) {
           //--->set VideoThumbnail loading---//
           NSString *urlStr = message;//[s objectForKey:kResourceUrlLocalKey];
           if ([globalData._videoThumbnailCache objectForKey:urlStr]) {
               cell.photoThumbnail.image = [globalData._videoThumbnailCache objectForKey:urlStr];
           } else {
               //---Set Placeholder photo---//
               cell.photoThumbnail.image = [UIImage imageNamed:@"photoPlaceholder"];
               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                   AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:urlStr] options:nil];
                   AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                   generator.appliesPreferredTrackTransform = TRUE;
                   CMTime thumbTime = CMTimeMakeWithSeconds(0,10);
                   
                   AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                       if (result != AVAssetImageGeneratorSucceeded) {
                           NSLog(@"couldn't generate thumbnail, error:%@", error);
                       }
                       UIImage *overlayImage = [UIImage imageWithCGImage:im];
                       if (overlayImage != nil) {
                           [globalData._videoThumbnailCache setObject:overlayImage forKey:urlStr];
                           cell.photoThumbnail.image = overlayImage;
                       }
                   };
                   
                   CGSize maxSize = CGSizeMake(320, 180);
                   generator.maximumSize = maxSize;
                   [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
               });
            }
           //--->set VideoThumbnail loading---//
           //---set Message frame---//
           [cell.photoShowBtn setEnabled:NO];
           [cell.audioPlayBtn setEnabled:NO];
           [cell.messageContentView setHidden:YES];
           //---set show relevant button---//
           [cell.videoPlayBtn setEnabled:YES];
           
           //---set Thumbnail frame---//
           [cell.photoThumbnail setHidden:NO];
           [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
           
           //---set videoPlayBtn frame---//
           [cell.videoPlayBtn setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
           cell.videoPlayBtn.tag = indexPath.row;
           [cell.videoPlayBtn addTarget:self action:@selector(videoPlaybackAction:) forControlEvents:UIControlEventTouchUpInside];
           
           //---set senderNameLabel frame---//
           cell.senderNameLabel.text = [NSString stringWithFormat:@"Me"];
           cell.senderNameLabel.frame = CGRectMake(10,5,
                                                   senderNameLabelWidth,
                                                   senderNameLabelHeight);
//           cell.senderNameLabel.textColor = [UIColor whiteColor];
           
           //---set TimeLabel frame---//
           cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
           [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
           cell.senderAndTimeLabel.numberOfLines = 2;
           cell.senderAndTimeLabel.frame = CGRectMake(10,kThumbnailWidth-senderAndTimeLabelHeight,
                                                      senderAndTimeLabelWidth/2,
                                                      senderAndTimeLabelHeight);
//           cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
           
           //---Set ContainerImageView Frame and image---//
           [cell.containerImageView setFrame:CGRectMake(0,0,kThumbnailWidth,
                                                        kThumbnailHeight)];
           //---Image with cap insets---//
           UIImage *bgImage = [UIImage imageNamed:@"RightBubble"];
           bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
           cell.containerImageView.image = bgImage;
           
           //---Set ContainerView Frame---//
           int containerX = screenSize.width - (kThumbnailWidth + imageWidth + 25);
           [cell.containerView setFrame:CGRectMake(containerX,0,
                                                   kThumbnailWidth,
                                                   kThumbnailHeight)];
       } else if ([msgResourceType isEqualToString:kMsgResourceAudio]) {
           //--->set VideoThumbnail loading---//
           //---set hide other buttons---//
           [cell.photoShowBtn setEnabled:NO];
           [cell.videoPlayBtn setEnabled:NO];
           [cell.messageContentView setHidden:YES];
           //---set show relevant button---//
           [cell.audioPlayBtn setEnabled:YES];
           
           //---set Thumbnail frame---//
           cell.photoThumbnail.image = [UIImage imageNamed:@"photoPlaceholder"];
           [cell.photoThumbnail setHidden:NO];
           [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
           
           //---set videoPlayBtn frame---//
           [cell.audioPlayBtn setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
           cell.audioPlayBtn.tag = indexPath.row;
           [cell.audioPlayBtn addTarget:self action:@selector(playPauseAudioUrl:) forControlEvents:UIControlEventTouchUpInside];
           //---set senderNameLabel frame---//
           cell.senderNameLabel.text = [NSString stringWithFormat:@"Me"];
           cell.senderNameLabel.frame = CGRectMake(10,5,
                                                   senderNameLabelWidth,
                                                   senderNameLabelHeight);
//           cell.senderNameLabel.textColor = [UIColor whiteColor];
           //---set TimeLabel frame---//
           cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
           [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
           cell.senderAndTimeLabel.numberOfLines = 2;
           cell.senderAndTimeLabel.frame = CGRectMake(10,kThumbnailWidth-senderAndTimeLabelHeight,
                                                      senderAndTimeLabelWidth/2,
                                                      senderAndTimeLabelHeight);
//           cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
           //---Set ContainerImageView Frame and image---//
           [cell.containerImageView setFrame:CGRectMake(0,0,kThumbnailWidth,
                                                        kThumbnailHeight)];
           //---Image with cap insets---//
           UIImage *bgImage = [UIImage imageNamed:@"RightBubble"];
           bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
           cell.containerImageView.image = bgImage;
           //---Set ContainerView Frame---//
           int containerX = screenSize.width - (kThumbnailWidth + imageWidth + 25);
           [cell.containerView setFrame:CGRectMake(containerX,0,
                                                   kThumbnailWidth,
                                                   kThumbnailHeight)];
       }
    }//---Sending Site msg---//
    else { //---msg received---//
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        cell.bgImageView.image = bgImage;
        cell.bgImageView.frame = CGRectMake((screenSize.width - imageWidth) - 5, 0, imageWidth, imageHeight);
        
        if ([msgResourceType isEqualToString:kMsgResourceText]) {
            //--set Disable buttons---//
            [cell.photoShowBtn setEnabled:NO];
            [cell.videoPlayBtn setEnabled:NO];
            [cell.audioPlayBtn setEnabled:NO];
            [cell.photoThumbnail setHidden:YES];
            //---show related button---//
            [cell.messageContentView setHidden:NO];
            
            //---set senderNameLabel frame---//
            cell.senderNameLabel.text = [NSString stringWithFormat:@"%@",sender];
            cell.senderNameLabel.frame = CGRectMake(10,5,
                                                    senderNameLabelWidth,
                                                    senderNameLabelHeight);
            //--set message frame---//
            [cell.messageContentView setFrame:CGRectMake(5,
                                                         senderNameLabelHeight,
                                                         size.width+10,
                                                         size.height+verticalMargin)];
            //---Set Time Frame---//
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
            cell.senderAndTimeLabel.numberOfLines = 1;
            cell.senderAndTimeLabel.frame = CGRectMake(10,
                                                       cell.messageContentView.frame.size.height+10,
                                                       senderAndTimeLabelWidth,
                                                       senderAndTimeLabelHeight);
            //---Set ContainerImageView Frame and image---//
            [cell.containerImageView setFrame:CGRectMake(0,
                                                         0,
                                                         containerWidth+horizontalMargin+5,
                                                         size.height+senderAndTimeLabelHeight+verticalMargin+20)];
            //---Image with cap insets---//
            UIImage *bgImage = [UIImage imageNamed:@"LeftBubble"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
            cell.containerImageView.image = bgImage;
            //---Set ContainerView Frame---//
            [cell.containerView setFrame:CGRectMake(imageWidth+5,0,
                                                    containerWidth+verticalMargin+5,
                                                    size.height+senderAndTimeLabelHeight+horizontalMargin+20)];
        } else if ([msgResourceType isEqualToString:kMsgResourcePhoto]) {
            CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
            NSString *imageRef = message;//[s objectForKey:kResourceUrlRemoteKey];
            NSURL *imageURL = [NSURL URLWithString:imageRef];
            [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
                if ([type isEqualToString:@"image"]) {
                    cell.photoThumbnail.image = (UIImage *)cachedSlide;
                }
            } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
                //        NSLog(@"Image cache fail");
            }];
            //---Hide other views ---//
            [cell.videoPlayBtn setEnabled:NO];
            [cell.audioPlayBtn setEnabled:NO];
            [cell.messageContentView setHidden:YES];
            //---show related button---//
            [cell.photoShowBtn setEnabled:YES];
            //---set Thumbnail frame---//
            [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            //---set Button Thumbnail---//
            [cell.photoShowBtn setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            cell.photoShowBtn.tag = indexPath.row;
            [cell.photoShowBtn addTarget:self action:@selector(photoFullViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            //---set senderNameLabel frame---//
            cell.senderNameLabel.text = [NSString stringWithFormat:@"%@",sender];
            cell.senderNameLabel.frame = CGRectMake(10,5,
                                                    senderNameLabelWidth,
                                                    senderNameLabelHeight);
//            cell.senderNameLabel.textColor = [UIColor whiteColor];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
            cell.senderAndTimeLabel.numberOfLines = 1;
            cell.senderAndTimeLabel.frame = CGRectMake(10,
                                                       cell.messageContentView.frame.size.height+10,
                                                       senderAndTimeLabelWidth,
                                                       senderAndTimeLabelHeight);
            [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
//            cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
            //---Set ContainerImageView Frame and image---//
            [cell.containerImageView setFrame:CGRectMake(0,0,
                                                         kThumbnailWidth,
                                                         kThumbnailHeight)];
            //---Image with cap insets---//
            UIImage *bgImage = [UIImage imageNamed:@"LeftBubble"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
            cell.containerImageView.image = bgImage;
            //---Set ContainerView Frame---//
            [cell.containerView setFrame:CGRectMake(imageWidth+5,0,
                                                    kThumbnailWidth,
                                                    kThumbnailHeight)];
            
        } else if ([msgResourceType isEqualToString:kMsgResourceVideo]) {
            //--->set VideoThumbnail loading---//
            NSString *urlStr = message;//[s objectForKey:kResourceUrlRemoteKey];
            if ([globalData._videoThumbnailCache objectForKey:urlStr]) {
                cell.photoThumbnail.image = [globalData._videoThumbnailCache objectForKey:urlStr];
            } else {
                //---Set Placeholder photo---//
                cell.photoThumbnail.image = [UIImage imageNamed:@"photoPlaceholder"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:urlStr] options:nil];
                    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    generator.appliesPreferredTrackTransform = TRUE;
                    CMTime thumbTime = CMTimeMakeWithSeconds(0,10);
                    
                    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                        if (result != AVAssetImageGeneratorSucceeded) {
                            NSLog(@"couldn't generate thumbnail, error:%@", error);
                        }
                        UIImage *overlayImage = [UIImage imageWithCGImage:im];
                        if (overlayImage != nil) {
                            [globalData._videoThumbnailCache setObject:overlayImage forKey:urlStr];
                            cell.photoThumbnail.image = overlayImage;
                        }
                    };
                    
                    CGSize maxSize = CGSizeMake(320, 180);
                    generator.maximumSize = maxSize;
                    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
                });
            }
            //--- set VideoThumbnail ---//
            //---message hide---//
            [cell.photoShowBtn setEnabled:NO];
            [cell.audioPlayBtn setEnabled:NO];
            [cell.messageContentView setHidden:YES];
            //---show related button---//
            [cell.videoPlayBtn setEnabled:YES];
            //---set Thumbnail frame---//
            [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            //---set Button on videoPlayBtn---//
            [cell.videoPlayBtn setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            cell.videoPlayBtn.tag = indexPath.row;
            [cell.videoPlayBtn addTarget:self action:@selector(videoPlaybackAction:) forControlEvents:UIControlEventTouchUpInside];
            //---set senderNameLabel frame---//
            cell.senderNameLabel.text = [NSString stringWithFormat:@"%@",sender];
            cell.senderNameLabel.frame = CGRectMake(10,5,
                                                    senderNameLabelWidth,
                                                    senderNameLabelHeight);
//            cell.senderNameLabel.textColor = [UIColor whiteColor];
            //---Set Time Frame---//
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
            cell.senderAndTimeLabel.numberOfLines = 2;
            cell.senderAndTimeLabel.frame = CGRectMake(10,kThumbnailWidth-senderAndTimeLabelHeight,
                                                       senderAndTimeLabelWidth/2,
                                                       senderAndTimeLabelHeight);
            [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
//            cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
            //---Set ContainerImageView Frame and image---//
            [cell.containerImageView setFrame:CGRectMake(0,0,
                                                         kThumbnailWidth,
                                                         kThumbnailHeight)];
            //---Image with cap insets---//
            UIImage *bgImage = [UIImage imageNamed:@"LeftBubble"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
            cell.containerImageView.image = bgImage;

            //---Set ContainerView Frame---//
            [cell.containerView setFrame:CGRectMake(imageWidth+5,0,
                                                    kThumbnailWidth,
                                                    kThumbnailHeight)];
        } else if ([msgResourceType isEqualToString:kMsgResourceAudio]) {
            //--->set VideoThumbnail loading---//
            //---set hide other buttons---//
            [cell.photoShowBtn setEnabled:NO];
            [cell.videoPlayBtn setEnabled:NO];
            [cell.messageContentView setHidden:YES];
            //---set show relevant button---//
            [cell.audioPlayBtn setEnabled:YES];
            //---set Thumbnail frame---//
            cell.photoThumbnail.image = [UIImage imageNamed:@"photoPlaceholder"];
            [cell.photoThumbnail setHidden:NO];
            [cell.photoThumbnail setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            
            //---set videoPlayBtn frame---//
            [cell.audioPlayBtn setFrame:CGRectMake(7,5,kThumbnailWidth-16,kThumbnailHeight-10)];
            cell.audioPlayBtn.tag = indexPath.row;
            [cell.audioPlayBtn addTarget:self action:@selector(playPauseAudioUrl:) forControlEvents:UIControlEventTouchUpInside];
            //---set senderNameLabel frame---//
            cell.senderNameLabel.text = [NSString stringWithFormat:@"%@",sender];
            cell.senderNameLabel.frame = CGRectMake(10,5,
                                                    senderNameLabelWidth,
                                                    senderNameLabelHeight);
//            cell.senderNameLabel.textColor = [UIColor whiteColor];
            //---set TimeLabel frame---//
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", time];
            [cell.senderAndTimeLabel setFont:[UIFont systemFontOfSize:10]];
            cell.senderAndTimeLabel.numberOfLines = 2;
            cell.senderAndTimeLabel.frame = CGRectMake(10,kThumbnailWidth-senderAndTimeLabelHeight,
                                                       senderAndTimeLabelWidth/2,
                                                       senderAndTimeLabelHeight);
//            cell.senderAndTimeLabel.textColor = [UIColor whiteColor];
            //---Set ContainerImageView Frame and image---//
            [cell.containerImageView setFrame:CGRectMake(0,0,kThumbnailWidth,kThumbnailHeight)];
            //---Image with cap insets---//
            UIImage *bgImage = [UIImage imageNamed:@"LeftBubble"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 51.0, 20.0, 51.0)];
            cell.containerImageView.image = bgImage;
            //---Set ContainerView Frame---//
            [cell.containerView setFrame:CGRectMake(imageWidth+5,0,
                                                    kThumbnailWidth,
                                                    kThumbnailHeight)];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)[globalData.messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:kMsgKey];
    NSString *senderStr = [dict objectForKey:kSenderKey];
    NSString *timeStr = [dict objectForKey:kTimeStampKey];

    if ([[dict objectForKey:kMsgResourceTypeKey] isEqualToString:kMsgResourceText]) {
        CGFloat totalHeight = [self getStringSize:msg].height +
                                [self getStringSize:senderStr].height +
                                [self getStringSize:timeStr].height;
        totalHeight += padding*2;
        return totalHeight;
    } else {
        CGFloat height = kThumbnailHeight;
        height += padding;
        return height;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [globalData.messages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


#pragma mark - ChatManager Delegate
- (void)newMessageReceived:(NSDictionary *)messageContent {

}

- (void)newRoomMessageReceived:(NSDictionary *)messageContent {
    //NSLog(@"message content=%@",messageContent);
    NSString *msg = [messageContent objectForKey:kMsgKey];
    NSString *senderRoom = [messageContent objectForKey:kSenderKey];
    NSString *room = [[senderRoom componentsSeparatedByString:@"/"]objectAtIndex:0];
    NSString *sender = [[senderRoom componentsSeparatedByString:@"/"]objectAtIndex:1];
    
    NSArray *roomNameParts = [room componentsSeparatedByString:@"@"];
    
    if ([roomNameParts[0] isEqualToString:[self.title stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
        [messageContent setValue:[msg substituteEmoticons] forKey:kMsgKey];
        NSString *currentDateStr = [Common getEpochTimeFromDate:[NSDate date]];
        [messageContent setValue:currentDateStr forKey:kTimeStampKey];
        [messageContent setValue:sender forKey:kSenderKey];
        [globalData.messages addObject:messageContent];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSeenMsgNotification
         object:self userInfo:messageContent];
        
        [self.tView reloadData];
        
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                       inSection:0];
        [self.tView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
    }
}

- (void)newInactiveRoomMessageReceived:(NSDictionary *)messageContent {
    NSLog(@"newInactiveRoomMessageReceived");
}

#pragma - mark SqliteDatabase

- (void)insertIntoSqliteDb:(NSString *) message {
   BOOL isInsertSuccess =  [[DbHelper sharedInstance] insertMessageForOffLine:message andChatWithUser:chatWithUser];
    if(isInsertSuccess) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_OFFLINE_MESSAGE_STORE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else {
        
    }
}

- (UIImage *)makeThumbFromVideoUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CGSize maxSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
    generateImg.maximumSize = maxSize;
    generateImg.appliesPreferredTrackTransform = TRUE;
    NSError *error = NULL;
    CMTime time = CMTimeMake(1, 30);
    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
    //NSLog(@"error==%@, Refimage==%@", error, refImg);
    if (error) {
        return nil;
    }
    UIImage *FrameImage = [[UIImage alloc] initWithCGImage:refImg];
    return FrameImage;
}

#pragma mark - GoTo OtherVC
- (void)photoFullViewAction:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    PhotoFullViewController *photoFullVC = (PhotoFullViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoFullViewController"];
    photoFullVC.msgDictionary = (NSDictionary *) [globalData.messages objectAtIndex:sender.tag];
    [self.navigationController presentViewController:photoFullVC animated:YES completion:nil];
}

- (void)videoPlaybackAction:(UIButton*)sender {
    if (downloadTask == nil) {
        NSURL *url = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
        downloadTask = [session downloadTaskWithURL:url];
        [downloadTask resume];
    } else {
        [downloadTask resume];
    }
}

- (void)gotoVideoPlayback:(NSString *)videoUrl {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
//    PlayVideoViewController *playVideoVC = (PlayVideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
//    playVideoVC.selectedVideoUrl = videoUrl;
//    [self.navigationController presentViewController:playVideoVC animated:YES completion:nil];
    
    NSURL*theurl = [NSURL fileURLWithPath:videoUrl];
    AVPlayer *player9 = [AVPlayer playerWithURL:theurl];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = player9;
    [player play];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSString *videoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *url = [NSURL URLWithString:[videoPath stringByAppendingPathComponent:@"video1.mp4"]];
    
    if ([fileManager fileExistsAtPath:[location path]]) {
        [fileManager replaceItemAtURL:url withItemAtURL:location backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:nil];
        UISaveVideoAtPathToSavedPhotosAlbum([url path], self,  @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float timeDuration = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    NSLog(@"%lld/%lld=%f",totalBytesWritten, totalBytesExpectedToWrite,timeDuration);
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self gotoVideoPlayback:videoPath];
    }
}
#pragma mark - recorded audio playback
/*
- (void)playPauseAudioAction:(UIButton*)btn {
    _audioPlayBtn = btn;
    //---PhotoImage fullscreen show---//
    NSDictionary *audioDic = (NSDictionary *) [globalData.messages objectAtIndex:btn.tag];
//    NSString * sender = [audioDic objectForKey:kSenderNameKey];
//    NSString * urlStringLocal  = [audioDic objectForKey:kResourceUrlLocalKey];
    NSString * urlStringRemote = [audioDic objectForKey:kMsgKey];
    [self playbackRemoteAudioUrl:urlStringRemote];
    
    if ([sender isEqualToString:@"you"] || [sender isEqualToString:[ModelManager sharedInstance].user.userName]) {
        if (player.isPlaying) {
            [player stop];
            [btn setTitle:@"Play" forState:UIControlStateNormal];
        } else {
            [btn setTitle:@"Stop" forState:UIControlStateNormal];
            [self playbackLocalAudioUrl:urlStringLocal];
        }
    } else {
        [self playbackRemoteAudioUrl:urlStringRemote];
    }
}
*/

- (void)playPauseAudioUrl:(UIButton*)btn {
    _audioPlayBtn = btn;
    static BOOL isPlaying = NO;
    if (!isPlaying) {
        isPlaying = YES;
        NSDictionary *audioDic = (NSDictionary *) [globalData.messages objectAtIndex:btn.tag];
        NSString * urlStringRemote = [audioDic objectForKey:kMsgKey];
        NSURL *url = [NSURL URLWithString:urlStringRemote];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        self.songPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.songPlayer = [AVPlayer playerWithURL:url];
        // Register with the notification center after creating the player item.
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playerItemDidReachEnd:)
         name:AVPlayerItemDidPlayToEndTimeNotification
         object:playerItem];
        [self.songPlayer play];
        [_audioPlayBtn setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        isPlaying = NO;
        [self.songPlayer pause];
        [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.songPlayer seekToTime:kCMTimeZero];
    isPlayBackFinished = YES;
    [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playbackLocalAudioUrl:(NSString*)localAudioUrl {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:localAudioUrl] error:&error];
    if (error) {
        [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
        NSLog(@"error =%@",error.description);
        return;
    }
    player.delegate = self;
    [player setNumberOfLoops:0];
    player.volume = 1;
    [player prepareToPlay];
    [player play];
}

#pragma mark - AVAudioPlayerDelegate Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isPlayBackFinished = YES;
    [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playbackRemoteAudioUrl:(NSString*)localAudioUrl {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.stephaniequinn.com/Music/Allegro%20from%20Duet%20in%20C%20Major.mp3"] error:&error];
    if (error) {
        [_audioPlayBtn setTitle:@"Play" forState:UIControlStateNormal];
        NSLog(@"error =%@",error.description);
        return;
    }
    player.delegate = self;
    [player setNumberOfLoops:0];
    player.volume = 1;
    [player prepareToPlay];
    [player play];
}

#pragma mark - UploadMM
- (void)uploadMultimedia:(id) object withType:(NSString*)fileType {
    NSDictionary *dictionary = object;
    NSString * fileTitle = [dictionary objectForKey:@"FileTitle"];
    NSString * fileContent = [dictionary objectForKey:@"FileContent"];
    NSString * fileTypeId = @"3";
    
    NSDictionary *requestBody = @{kFileTitleKey :fileTitle,
                                  kFileContentKey :fileContent,
                                  kFileTypeIdKey :fileTypeId,
                                  kUserIdCamelLetterKey:_modelManager.user.identifier,
                                  kUserNameCamelLetterName:_modelManager.user.userName,
                                  kFileExtensionKey:fileType,
                                  kTokenKey:_modelManager.user.sessionToken
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:UPLOAD_MULTIMEDIA],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

- (void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler {
    // image crop from center
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    //    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    UIImage *imageCrop = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    // image crop end
    CGSize size = CGSizeMake(200,200);
    UIGraphicsBeginImageContext(size);
    [imageCrop drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imageBase64String = [UIImagePNGRepresentation(destImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    completionHandler();
}

- (void)uploadImageToServer:(UIImage *)userImage {
    [self base64ConvertImage:userImage andCompletionHandler:^(void) {
        NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
        NSString *intervalSeconds = [NSString stringWithFormat:@"%0.0f",seconds];

        NSString *fileTitle = [NSString stringWithFormat:@"%@.png",intervalSeconds];
        
        NSString * fileContent = imageBase64String;
        NSString * fileTypeId = @"1";//1==image, 2== video, 3= audio
        
        NSDictionary *requestBody = @{kFileTitleKey :fileTitle,
                                      kFileContentKey :fileContent,
                                      kFileTypeIdKey :fileTypeId,
                                      kUserIdCamelLetterKey:_modelManager.user.identifier,
                                      kUserNameCamelLetterName:_modelManager.user.userName,
                                      kFileExtensionKey:@".png",
                                      kTokenKey:_modelManager.user.sessionToken
                                      };
        NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:UPLOAD_MULTIMEDIA],
                                         WHEN_KEY:[NSDate date],
                                         OBJ_KEY:requestBody
                                         };
        [_serviceHandler onOperate:requestBodyDic];
    }];
}

#pragma mark - Service Call Methods -
- (void)initService {
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"ChatViewController";
    //Initialize Service CallBack Handler
    ReplyHandler *handler = [[ReplyHandler alloc]
                             initWithModelManager:_modelManager
                             operator:nil
                             progress:nil
                             signupUpdate:nil
                             addMemberUpdate:nil
                             updateUserUpdate:nil
                             settingsUpdate:nil
                             loginUpdate:nil
                             trackAppDayNightModeUpdate:(id)self
                             saveLocationUpdate:nil
                             getLocationUpdate:nil
                             getLocationHistoryUpdate:nil
                             saveAlertUpdate:(id)self
                             getAlertUpdate:nil
                             andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
        if (sourceType == UPLOAD_MULTIMEDIA_SUCCCEEDED) {//---Save Alerts
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self sendMultimadiaMsg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tView reloadData];
                    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:globalData.messages.count-1
                                                                   inSection:0];
                    [self.tView scrollToRowAtIndexPath:topIndexPath
                                      atScrollPosition:UITableViewScrollPositionMiddle
                                              animated:YES];
                });
            });
        } else if (sourceType == UPLOAD_MULTIMEDIA_FAILED) {
            NSLog(@"Upload Failed.");
        }
    });
}

- (NSString *)dateString {
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".mov"];
}

@end
