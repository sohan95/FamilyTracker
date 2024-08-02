//
//  MenuViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/15/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak,nonatomic) IBOutlet UIImageView *blurUserProfileImageView;
@property (weak,nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak,nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak,nonatomic) IBOutlet UILabel *userRoleLbl;
@property (weak,nonatomic) IBOutlet UITableView *menuTableView;
@end
