//
//  AlertViewController.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 10/7/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "MBProgressHUD.h"
#import "Notification.h"

@interface AlertViewController : UIViewController<MNMBottomPullToRefreshManagerClient>{
    NSMutableArray<Notification,Optional> *_allAlertList;
    MBProgressHUD *alertsHud;
    UIRefreshControl *refreshControl;
}

@property (nonatomic, strong) MNMBottomPullToRefreshManager *pullToRefreshManager;

@end
