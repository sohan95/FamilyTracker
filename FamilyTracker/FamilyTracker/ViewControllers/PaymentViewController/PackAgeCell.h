//
//  PackAgeCell.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/21/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackAgeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *packName;
@property (weak, nonatomic) IBOutlet UILabel *offer;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UIButton *upgradeBtn;

@end
