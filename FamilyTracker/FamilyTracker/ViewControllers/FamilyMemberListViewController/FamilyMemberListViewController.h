//
//  FamilyMemberListViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/16/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface FamilyMemberListViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak,nonatomic) IBOutlet UITableView *memberListView;

@end
