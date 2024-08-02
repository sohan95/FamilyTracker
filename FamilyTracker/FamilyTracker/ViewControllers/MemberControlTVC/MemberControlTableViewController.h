//
//  MemberControlTableViewController.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 11/23/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemberData.h"

@interface MemberControlTableViewController : UITableViewController

@property(nonatomic, readwrite) MemberData *member;

@end
