//
//  MemberListCustomCell.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *guardianStatus;
@property (weak, nonatomic) IBOutlet UIImageView *memberProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *memberName;
@property (weak, nonatomic) IBOutlet UIImageView *activeInactiveStatusImage;

@end
