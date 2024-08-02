//
//  PhotoFullViewController.h
//  AudioCallKitSampleProject
//
//  Created by Md. Shahanur Rahmann on 11/11/15.
//  Copyright © 2015 Qaium Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFullViewController : UIViewController

@property(nonatomic, strong) NSDictionary *msgDictionary;
@property(nonatomic, strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic,strong) IBOutlet UIButton *btnBack;

@end
