//
//  SwitchCell.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/27/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettingSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *controlSwitch;

@end
