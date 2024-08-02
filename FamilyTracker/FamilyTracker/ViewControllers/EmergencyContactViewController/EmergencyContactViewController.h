//
//  EmergencyContactViewController.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/6/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface EmergencyContactViewController : BaseViewController <CNContactPickerDelegate>
@property (weak,nonatomic) IBOutlet UIImageView *emergencyContactImageView1;
@property (weak,nonatomic) IBOutlet UIImageView *emergencyContactImageView2;
@property (weak,nonatomic) IBOutlet UIImageView *emergencyContactImageView3;
@property (weak,nonatomic) IBOutlet UILabel *emergencyContactNameLbl1;
@property (weak,nonatomic) IBOutlet UILabel *emergencyContactNameLbl2;
@property (weak,nonatomic) IBOutlet UILabel *emergencyContactNameLbl3;
@property (weak,nonatomic) IBOutlet UIButton *addOrRemoveBtn1;
@property (weak,nonatomic) IBOutlet UIButton *addOrRemoveBtn2;
@property (weak,nonatomic) IBOutlet UIButton *addOrRemoveBtn3;
@property int emergencyContactToBeAddedIndex;

@end
