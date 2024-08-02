//
//  MapBoundaryViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/22/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@interface MapBoundaryViewController : UIViewController <UITableViewDelegate,CMPopTipViewDelegate>
@property(strong, nonatomic) NSString * memberId;
@property(strong, nonatomic) NSString * memberName;
@property(strong, nonatomic) NSString * memberUserName;
@property(nonatomic) double lat;
@property(nonatomic) double lon;

@end
