//
//  AddDeviceViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 4/11/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "QRCodeReaderDelegate.h"

@interface AddDeviceViewController : BaseViewController<QRCodeReaderDelegate>
- (IBAction)memberSelectAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *memberSelectButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *scannerBtOutlet;
- (IBAction)scannnerBtAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *qrTextField;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceButtonOutlet;
- (IBAction)addButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *dropDownView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite) NSMutableArray *memberList;
@property (nonatomic) BOOL isUnPairVc;
// UnPairView
@property (weak, nonatomic) IBOutlet UIView *unPairView;
@property (weak, nonatomic) IBOutlet UIView *dropDownViewForUnPair;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForUnPair;
- (IBAction)unPairAction:(id)sender;


@end
