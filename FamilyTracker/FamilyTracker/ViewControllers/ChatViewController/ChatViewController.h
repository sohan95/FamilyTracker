//
//  ChatViewController.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/11/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatManager.h"
#import "SMMessageViewTableCell.h"
#import "GlobalData.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@class AppDelegate;

@interface ChatViewController : UIViewController <SMMessageDelegate, UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,AVAudioPlayerDelegate, AVAudioSessionDelegate,UINavigationControllerDelegate> {
    AppDelegate *delegate;
    UITextField		*messageField;
    NSString		*chatWithUser;
    UITableView		*tView;
    GlobalData *globalData;
    AVAudioPlayer *player;
    BOOL isPlayBackFinished;
    MBProgressHUD *hud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    NSString *imageBase64String;
}

@property (nonatomic, strong) IBOutlet UITextField *messageField;
@property (nonatomic, strong) IBOutlet UITableView *tView;
@property (nonatomic, strong) IBOutlet UILabel *activeUserLabel;
@property (nonatomic, strong) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) IBOutlet UIButton *btnBack;
@property (nonatomic, strong) IBOutlet UIImageView *chatFieldImageView;
@property (nonatomic, strong) NSMutableArray *onlineParticipants;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) NSString *chatWithUser;
@property (nonatomic, copy) NSString *messageType;
//@property (nonatomic, copy) NSArray *chosenImages;
@property (nonatomic, readwrite) NSString *selectedLocalVideoUrlStr;
@property (nonatomic, readwrite) NSString *recordedLocalAudioUrlStr;
@property (nonatomic, readwrite) NSString *selectedLocalImageUrlStr;
@property (nonatomic,strong) NSCache *_videoThumbnailCache;
@property (nonatomic, strong) UIButton *audioPlayBtn;


- (void)reloadTableData;

@end
