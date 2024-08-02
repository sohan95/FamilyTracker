//
//  AlertTableViewCell.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 10/7/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *alertIcon;
@property (weak, nonatomic) IBOutlet UIImageView *liveImageView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UILabel *alertDate;

@end
