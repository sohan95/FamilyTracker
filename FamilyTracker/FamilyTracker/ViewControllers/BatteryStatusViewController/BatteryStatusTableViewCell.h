//
//  BatteryStatusTableViewCell.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 5/25/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatteryStatusTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *batteryLevelLabel;
@property(nonatomic, weak) IBOutlet UIImageView *userIcon;
@property(nonatomic, weak) IBOutlet UIImageView *BatteryBgImg;
@property(nonatomic, weak) IBOutlet UIImageView *batteryLevelImg;
@property(nonatomic, weak) IBOutlet UIImageView *powerImg;
@property(nonatomic, weak) IBOutlet UISwitch *panicSwitch;
@property(nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *levelConstraint;

@end
