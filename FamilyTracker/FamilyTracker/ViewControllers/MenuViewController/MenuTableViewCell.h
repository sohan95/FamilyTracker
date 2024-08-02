//
//  MenuTableViewCell.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 3/1/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *iconImage;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subTitleLabel;

@end
