//
//  MemberControlTableViewCell.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/8/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberControlTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *title;
@property(nonatomic, weak) IBOutlet UILabel *subTitle;
@property(nonatomic, weak) IBOutlet UISwitch *controlSwitch;
@property(nonatomic, weak) IBOutlet UILabel *settingValue;

@end
