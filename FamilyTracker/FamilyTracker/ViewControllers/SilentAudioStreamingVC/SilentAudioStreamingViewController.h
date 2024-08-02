//
//  SilentAudioStreamingViewController.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 4/13/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SilentAudioStreamingViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *dropDownView;
@property (weak, nonatomic) IBOutlet UITableView *tView;
@property(nonatomic, readwrite) NSMutableArray *memberList;
@property (weak, nonatomic) IBOutlet UIButton *memberSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *startStopSilentBtn;
@property (weak, nonatomic) IBOutlet UILabel *silentStreamingInfo;
- (IBAction)memberSelectAction:(id)sender;
- (IBAction)startStopSilentStreamingAction:(id)sender;

@end
