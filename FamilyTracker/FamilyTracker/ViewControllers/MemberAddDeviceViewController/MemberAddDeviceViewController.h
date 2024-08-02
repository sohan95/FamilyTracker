//
//  MemberAddDeviceViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "QRCodeReaderDelegate.h"

@interface MemberAddDeviceViewController : BaseViewController<QRCodeReaderDelegate>
@property(nonatomic) BOOL isUnPairVc;
- (IBAction)scannerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *qrCodeTextField;
- (IBAction)addCodeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *unPairDeviceView;
- (IBAction)unPairDeviceAction:(id)sender;

@end
