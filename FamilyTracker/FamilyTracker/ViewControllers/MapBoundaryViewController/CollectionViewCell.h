//
//  CollectionViewCell.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/22/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *cellEditButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cellDeleteOutlet;
@end
