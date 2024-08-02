//
//  CalloutView.h
//  DXCustomCallout-ObjC
//
//  Created by Md. Shahanur Rahmann on 11/21/16.
//  Copyright © 2016 s3lvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutView : UIView
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIButton *SMSBtn;
@property (weak, nonatomic) IBOutlet UIButton *liveVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *detailsBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationBriefBtn;

@end
