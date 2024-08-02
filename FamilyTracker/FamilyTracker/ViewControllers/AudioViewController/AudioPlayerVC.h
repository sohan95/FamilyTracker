//
//  AudioPlayerVC.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 1/14/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioPlayerVC : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *alertId;
- (IBAction)playerPlayAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *playerPlayOutlet;

@end
