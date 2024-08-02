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
//@property (weak, nonatomic) IBOutlet UIButton *liveVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *detailsBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationBriefBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottonSpaceConstraintDetails;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *makeCallLeadingValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *setBoundaryLeadingValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendSmsLedaingValue;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *makeCallButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *makeSmsButtonWidth;


@property (weak, nonatomic) IBOutlet UIButton *setBoundary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottonSpaceConstraintHistory;
@end
