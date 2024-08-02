 //
//  UpdateProfileViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/4/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//
#import "UpdateProfileViewController.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "HexToRGB.h"
#import "ModelManager.h"
#import <QuartzCore/QuartzCore.h>
#import "CacheSlide.h"
#import "libPhoneNumberiOS.h"
#import "LoginViewController.h"
#import "JsonUtil.h"
#import "PECropViewController.h"

#define NORMAL_BACKGROUND @"#F2F8F1"
#define EDIT_BACKGROUND @"6FB67D"
#define BORDER_SHEDU @"#3CB978"

@interface UpdateProfileViewController ()<DataUpdater,Updater,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,PECropViewControllerDelegate> {
    MBProgressHUD *profileUpdateHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    UIDatePicker *datePicker;
    UIImage *destImage;
    UIImage * selectedImageToCrop;
}
@property (strong,nonatomic) IBOutlet UITextField *userNameField;
@property (strong,nonatomic) IBOutlet UITextField *firstNameField;
@property (strong,nonatomic) IBOutlet UITextField *lastNameField;
@property (strong,nonatomic) IBOutlet UIButton *genderBtn;
@property (weak, nonatomic) IBOutlet UIButton *genderBtnArrow;
@property (strong,nonatomic) IBOutlet UITextField *contactField;
@property (strong,nonatomic) IBOutlet UITextField *DOBField;
@property (strong,nonatomic) IBOutlet UITextField *emailField;
@property (strong,nonatomic) IBOutlet UITextField *addressField;
@property (assign,nonatomic) BOOL isEditBtnTapped;
@property (strong, nonatomic) IBOutlet UILabel *memberName;
@property (strong, nonatomic) IBOutlet UILabel *memberRoleName;
@property (strong, nonatomic) IBOutlet UILabel *totalMember;
@property (strong, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (strong, nonatomic) IBOutlet UIButton *profileEditBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *editProfileImageOutlet;
@property (strong, nonatomic) IBOutlet UIView *userInputView;
@property (strong, nonatomic) IBOutlet UIView *firstNameView;
@property (strong, nonatomic) IBOutlet UIView *lastNameView;
@property (strong, nonatomic) IBOutlet UIView *genderView;
@property (strong, nonatomic) IBOutlet UIView *mobileView;
@property (strong, nonatomic) IBOutlet UIView *emailView;
@property (strong, nonatomic) IBOutlet UIView *dobView;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UIView *dropDownView;
// update ui
@property (weak, nonatomic) IBOutlet UIView *updateTypePopUpView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordField;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
- (IBAction)chooseTypeEditProfileAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ChangePasswordView;
- (IBAction)chooseTypeChangePasswordAction:(id)sender;
- (IBAction)changePasswordCancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
- (IBAction)changePasswordButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordCancelButtonOutlet;
// update ui
@property (nonatomic,strong) NSString * defaultLanguage;
typedef void(^convertBase65String)(NSString *);

- (void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler;
- (IBAction)profileEditBtn:(id)sender;
- (IBAction)dropDownMaleSelectBtn:(id)sender;
- (IBAction)dropDownFemaleSelectBtn:(id)sender;
- (IBAction)editProfileImageBtn:(id)sender;
@end

@implementation UpdateProfileViewController {
    BOOL isEditProfile;
    BOOL keyBoradOpen;
    int textFieldIndex;
    NSString * imageBase64String;
    int updateType;
    User *tempUserData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //---show nevigationbar---//
    [self.navigationController setNavigationBarHidden:NO];
    self.title = NSLocalizedString(@"Member Profile",nil);
    _modelManager = [ModelManager sharedInstance];
    //---Gesture Recognizer For Hiding Keyboard---//
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard2:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    imageBase64String = @"";
    [self setDefaultView];
    [self initService];
    //---Set Date Of Birth Picker---//
    [self setDateOffBirthPicker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [GlobalData sharedInstance].currentVC = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark User Defined Methods -
- (void)setDefaultView {
    //---new add ui---//
    _ChangePasswordView.layer.cornerRadius = 10.0;
    _ChangePasswordView.layer.borderWidth = 3.0;
    _ChangePasswordView.layer.borderColor = [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255 alpha:1].CGColor;
    [[self view] bringSubviewToFront:_scrollView];
    _updateTypePopUpView.hidden = YES;
    _ChangePasswordView.hidden = YES;
    _oldPasswordField.text = @"";
    _changePasswordField.text = @"";
    updateType = 0;
    if ([self.oldPasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        //UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.oldPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(OLD_PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    if ([self.changePasswordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        //UIColor *color = [HexToRGB colorForHex:SYSTEM_NAV_COLOR];
        self.changePasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(NEW_PASSWORD_PLACEHOLDER_TEXT,nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
    _changePasswordButtonOutlet.layer.cornerRadius = 15; // this value vary as per your desire
    _changePasswordButtonOutlet.clipsToBounds = YES;
    _changePasswordCancelButtonOutlet.layer.cornerRadius = 15; // this value vary as per your desire
    _changePasswordCancelButtonOutlet.clipsToBounds = YES;
    //---end new ui---//
    isEditProfile = NO;
    keyBoradOpen = NO;
    textFieldIndex = 0;
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2;
    self.userProfileImageView.layer.masksToBounds = YES;
    if ([GlobalData sharedInstance].profilePicture) {
        [_userProfileImageView setImage:[GlobalData sharedInstance].profilePicture];
    } else {
            NSString * gender = _modelManager.user.gender;
            if([Common isNullObject:gender] || [gender isEqualToString:@""]) {
                [_userProfileImageView setImage:[UIImage imageNamed:@"Men"]];
            } else {
                if([gender isEqualToString:@"Male"] || [gender isEqualToString:@"পুরুষ"]) {
                    [_userProfileImageView setImage:[UIImage imageNamed:@"Men"]];
                } else if([gender isEqualToString:@"Female"] || [gender isEqualToString:@"মহিলা"]) {
                    [_userProfileImageView setImage:[UIImage imageNamed:@"Women"]];
                }
            }
    }
    self.editProfileImageOutlet.layer.cornerRadius = self.editProfileImageOutlet.frame.size.width / 2;
    self.editProfileImageOutlet.layer.masksToBounds = YES;
    self.profileEditBtnOutlet.layer.cornerRadius =self.profileEditBtnOutlet.frame.size.width / 2;
    self.profileEditBtnOutlet.layer.masksToBounds = YES;
    self.userInputView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.firstNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.lastNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.genderView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.mobileView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.emailView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.dobView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    self.addressView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
    [self.dropDownView setHidden:YES];
    [self.userNameField setEnabled:NO];
    [self.emailField setEnabled:YES];
    [self editPermission:NO];
    
    self.firstNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.lastNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.contactField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.DOBField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.addressField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No information provided",nil) attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    //---Set UserName or fullName---//
    if(([Common isNullObject:_modelManager.user.firstName] || _modelManager.user.firstName.length<1) && ([Common isNullObject:_modelManager.user.lastName] || _modelManager.user.lastName.length<1)) {
        _memberName.text = _modelManager.user.userName;
    } else {
        if ([Common isNullObject:_modelManager.user.lastName] || _modelManager.user.lastName.length<1) {
            _memberName.text = [NSString stringWithFormat:@"%@",_modelManager.user.firstName];
        } else {
            _memberName.text = [NSString stringWithFormat:@"%@ %@",_modelManager.user.firstName, _modelManager.user.lastName];
        }
    }
    //---Set Total User Role Name in Profile Page
    if ([_modelManager.user.role intValue] == 1) {
        _memberRoleName.text = NSLocalizedString(@"Guardian",nil);//@"Guardian";
    } else {
        _memberRoleName.text = NSLocalizedString(@"Member",nil);//@"Member";
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber:@(_modelManager.members.rows.count)];
    NSString * totalNumber = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), numberString];
    if (_modelManager.members.rows.count > 1) {
        NSString * persons = NSLocalizedString(@"persons", nil);
        _totalMember.text = [NSString stringWithFormat:@"%@ %@",totalNumber,persons];
    }else {
        NSString * persons = NSLocalizedString(@"person", nil);
        _totalMember.text = [NSString stringWithFormat:@"%@ %@",totalNumber,persons];
    }
    self.userNameField.text = _modelManager.user.userName;
    self.firstNameField.text = _modelManager.user.firstName;
    self.lastNameField.text = _modelManager.user.lastName;
    [self.genderBtn setTitle:_modelManager.user.gender forState:UIControlStateNormal];
    self.contactField.text = _modelManager.user.contact;
    if([Common isNullObject:_modelManager.user.email]) {
       self.emailField.text = @"";
    } else {
        self.emailField.text = _modelManager.user.email;
    }
    self.addressField.text = _modelManager.user.address;
    //---check not mandatory field---//
    if ([Common isNullObject:_modelManager.user.firstName]) {
        self.firstNameField.text = @"";
    }
    if ([Common isNullObject:_modelManager.user.lastName]) {
        self.lastNameField.text = @"";
    }
    if ( [Common isNullObject:_modelManager.user.contact]) {
        self.contactField.text = @"";
    }
    if ([Common isNullObject:_modelManager.user.dob]) {
        self.DOBField.text = @"";
    }
    if ([Common isNullObject:_modelManager.user.address]) {
        self.addressField.text = @"";
    }
    if ( [_modelManager.user.gender isEqualToString:GENDER_PLACEHOLDER_TEXT] || [Common isNullObject:_modelManager.user.gender] || _modelManager.user.gender.length == 0) {
        [_genderBtn setTitle:NSLocalizedString(@"Select",nil) forState:UIControlStateNormal];
    }
    NSString *dateStr = @"";
    if([Common isNullObject:_modelManager.user.dob] || _modelManager.user.dob.length == 0) {
    } else{
        dateStr = [self stringFromEpochTime:_modelManager.user.dob];
    }
    self.DOBField.text = dateStr;
}

- (void)editPermission:(BOOL)status {
    //[self.userNameField setEnabled:status];
    [self.firstNameField setEnabled:status];
    [self.lastNameField setEnabled:status];
    [self.genderBtn setEnabled:status];
    [self.genderBtnArrow setEnabled:status];
    [self.contactField setEnabled:status];
    [self.emailField setEnabled:status];
    [self.DOBField setEnabled:status];
    [self.addressField setEnabled:status];
}

- (void)chcekKeyboradOpen {
    if(keyBoradOpen) {
        [self.view endEditing:YES];
        keyBoradOpen = NO;
        if(textFieldIndex == 1){
            self.userInputView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.userNameField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 2){
            self.firstNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.firstNameField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 3){
            self.lastNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.lastNameField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 4){
            self.mobileView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.contactField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 5){
            self.emailView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.emailField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 6){
            self.dobView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.DOBField.textColor = [UIColor blackColor];
        }
        else if(textFieldIndex == 7) {
            self.addressView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
            self.addressField.textColor = [UIColor blackColor];
        }
    }
}

- (void)setDateOffBirthPicker{
    _DOBField.delegate = self;
    // alloc/init your date picker, and (optional) set its initial date
    datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]]; //this returns today's date
    // theMinimumDate (which signifies the oldest a person can be) and theMaximumDate (defines the youngest a person can be) are the dates you need to define according to your requirements, declare them:
    // the date string for the minimum age required (change according to your needs)
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MMM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    
    NSString *maxDateString = dateString;/*@"01-Jan-2017*/
    // the date string for the minimum age required (change according to your needs)
    NSString *minDateString = @"01-Dec-1951";
    // the date formatter used to convert string to date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // the specific format to use
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    // converting string to date
    NSDate *theMaximumDate = [dateFormatter dateFromString: maxDateString];
    NSDate *theMinimumDate = [dateFormatter dateFromString: minDateString];
    // repeat the same logic for theMinimumDate if needed
    // here you can assign the max and min dates to your datePicker
    [datePicker setMaximumDate:theMaximumDate]; //the min age restriction
    [datePicker setMinimumDate:theMinimumDate]; //the max age restriction (if needed, or else dont use this line)
    // set the mode
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // update the textfield with the date everytime it changes with selector defined below
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    // and finally set the datePicker as the input mode of your textfield
    [_DOBField setInputView:datePicker];
}

- (void)updateTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.DOBField.inputView;
    _DOBField.text = [self formatDate:picker.date];
}

- (NSString*)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

- (NSString *)epochTimeFromString:(NSString*)dateStr {
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    NSTimeInterval nowEpochSeconds = [date timeIntervalSince1970];
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:nowEpochSeconds];
    NSString *epochTimeStr = [myDoubleNumber stringValue];
    return epochTimeStr;
}

- (NSString*)stringFromEpochTime:(NSString *)epochTime {
    //NSString *epochTime = @"1352716800";
    // (Step 1) Convert epoch time to SECONDS since 1970
    NSTimeInterval seconds = [epochTime doubleValue];
    //NSLog (@"Epoch time %@ equates to %qi seconds since 1970", epochTime, (long long) seconds);
    // (Step 2) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    NSLog (@"Epoch time %@ equates to UTC %@", epochTime, epochNSDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:epochNSDate];
    return formattedDate;
}

- (BOOL)checkInput {
    NSString *alertMessage = nil;
    if (_contactField.text.length > 0) {
        //check number Validation
        NSString *mobileNumber = _contactField.text;
        NSError *anError = nil;
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NBPhoneNumber *myNumber = [phoneUtil parse:mobileNumber defaultRegion:@"BD" error:&anError];
        if (anError == nil) {
            if ([phoneUtil isValidNumber:myNumber]) {
                mobileNumber = [phoneUtil format:myNumber
                                    numberFormat:NBEPhoneNumberFormatE164
                                           error:&anError];
                NSString *nationalNumber = nil;
                NSNumber *countryCode = [phoneUtil extractCountryCode:mobileNumber nationalNumber:&nationalNumber];
                if ([countryCode stringValue].length == 3 && [[countryCode stringValue] isEqualToString:@"880"]) {
                    _contactField.text = mobileNumber;
                }else {
                    alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
                }
            }else {
                alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
            }
        }else {
            alertMessage = NSLocalizedString(@"Invalid Phone number!",nil);
        }
    }
    
    if(_emailField.text.length > 0 && alertMessage == nil) {
        if(![self validEmail:_emailField.text]) {
            alertMessage = NSLocalizedString(@"Incorrect email formate!",nil);
        }
    }
    
    if(_emailField.text.length == 0 && _contactField.text.length == 0 && alertMessage == nil) {
        alertMessage = NSLocalizedString(@"Please fill up at least one them (email/mobile)",nil);
    }
    //---check again---//
    if (alertMessage == nil) {
        return YES;
    }else {
        [self showAlertMessage:nil message:alertMessage];
        return NO;
    }
}

- (BOOL)checkInputForChangePassword {
    NSString *alertMessage = nil;
    self.oldPasswordField.text = [self.oldPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.changePasswordField.text = [self.changePasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.oldPasswordField.text isEqualToString:@""] || [self.oldPasswordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"Old Password cannot be empty",nil);
    }else if ([self.changePasswordField.text isEqualToString:@""] || [self.changePasswordField.text isEqual:nil]) {
        alertMessage = NSLocalizedString(@"New Password cannot be empty",nil);
    }
    if (alertMessage == nil) {
        return YES;
    }else {
        [self showAlertMessage:nil message:alertMessage];
        return NO;
    }
}

- (void)uploadUserImage:(UIImage *)userImage {
    [self base64ConvertImage:userImage andCompletionHandler:^(void) {
    if ([FamilyTrackerReachibility isUnreachable]) {
            [GlobalData sharedInstance].profilePicture = destImage;
            [[NSUserDefaults standardUserDefaults] setValue:imageBase64String forKey:OFFLINE_IMAGE_64_STRING];
        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(destImage) forKey:OFFLINE_IMAGE_DATA];
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_OFFLINE_IMAGE_CHANGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        [_userProfileImageView setImage:destImage];
        } else {
            [self uploadProfilePictureService:imageBase64String];
        }
    }];
}

- (void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler {
    // image crop from center
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
//    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    UIImage *imageCrop = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(imageRef);
    // image crop end
   CGSize size = CGSizeMake(200,200);
        UIGraphicsBeginImageContext(size);
        [imageCrop drawInRect:CGRectMake(0, 0, size.width, size.height)];
       destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
   imageBase64String = [UIImagePNGRepresentation(destImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    completionHandler();
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(OK_BUTTON_TITLE_KEY,nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hideDropDownView {
    [_dropDownView setHidden:YES];
}

-(void)changePassword {
    if([self checkInputForChangePassword]) {
        [self changePasswordService];
    } else {
        [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
    }
}

-(void) showPopUpViewForProfileUpdateOrChangePassword {
    [[self view] bringSubviewToFront:_updateTypePopUpView];
    _ChangePasswordView.hidden = YES;
    _updateTypePopUpView.hidden = NO;
    _popUpView.hidden = NO;
}

#pragma mark - Email Validation Checker -
- (BOOL)validEmail:(NSString *)checkString {
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark Gesture Recognizer Delegate
- (void)hideKeyboard2:(UITapGestureRecognizer*)sender {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.addressField resignFirstResponder];
    [self.contactField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self hideDropDownView];
    if(!_popUpView.isHidden) {
        _updateTypePopUpView.hidden = YES;
        _popUpView.hidden = YES;
    }
}

#pragma mark Button Action Methods
- (IBAction)setGenderAction:(UIButton *)sender {
    [self chcekKeyboradOpen];
    [self.dropDownView setHidden:NO];
}

- (IBAction)profileEditBtn:(id)sender {
    if(updateType == 0) {
        [self profileUpdateTypeAction:sender];
    }else {
        if(updateType == 1 ) {
            isEditProfile = NO;
            [self editPermission:NO];
            [self updateUserProfileService];
        }
    }
}

- (IBAction)dropDownMaleSelectBtn:(id)sender {
    [self.dropDownView setHidden:YES];
    [self.genderBtn setTitle:NSLocalizedString(GENDER_MALE,nil) forState: UIControlStateNormal];
}

- (IBAction)dropDownFemaleSelectBtn:(id)sender {
    [self.dropDownView setHidden:YES];
    [self.genderBtn setTitle:NSLocalizedString(GENDER_FAMEL,nil) forState: UIControlStateNormal];
}

- (IBAction)editProfileImageBtn:(id)sender {
    [self chcekKeyboradOpen];
    [self.dropDownView setHidden:YES];
    [self setDefaultView];
    [self imageChooseTypeAction:sender];
}

- (IBAction)chooseTypeEditProfileAction:(id)sender {
    _updateTypePopUpView.hidden = YES;
    _popUpView.hidden = YES;
    updateType = 1;
    [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
    isEditProfile = YES;
    [self editPermission:YES];
    tempUserData = _modelManager.user;
    [_firstNameField becomeFirstResponder];
}

- (IBAction)chooseTypeChangePasswordAction:(id)sender {
    [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
    _popUpView.hidden = YES;
    _ChangePasswordView.hidden = NO;
    updateType = 2;
}

- (IBAction)changePasswordCancelAction:(id)sender {
    [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
    [self setDefaultView];
}
- (IBAction)changePasswordButtonAction:(id)sender {
    [self changePassword];
}

#pragma mark - Image Convert in Base64String -
- (void)imageConvertInBase64Method:(UIImage *)image andBlock: (convertBase65String) compblock {
    compblock([UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
}

#pragma mark - keyborad -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(![self.dropDownView isHidden]) {
        [self.dropDownView setHidden:YES];
    }
    UITextField *tf = (UITextField *)textField;
    keyBoradOpen = YES;
    textFieldIndex = (int)tf.tag;
    if(tf.tag == 1) {
        self.userInputView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.userNameField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 2) {
        self.firstNameView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.firstNameField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 3) {
        self.lastNameView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.lastNameField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 4) {
        self.mobileView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.contactField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 5) {
        self.emailView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.emailField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 6) {
        self.dobView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.DOBField.textColor = [UIColor whiteColor];
    }
    else if(tf.tag == 7) {
        self.addressView.backgroundColor = [HexToRGB colorForHex:EDIT_BACKGROUND];
        self.addressField.textColor = [UIColor whiteColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITextField *tf = (UITextField *)textField;
    keyBoradOpen = NO;
    if(tf.tag == 1){
        self.userInputView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.userNameField.textColor = [UIColor blackColor];
    }else if(tf.tag == 2) {
        self.firstNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.firstNameField.textColor = [UIColor blackColor];
    }else if(tf.tag == 3) {
        self.lastNameView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.lastNameField.textColor = [UIColor blackColor];
    }else if(tf.tag == 4) {
        self.mobileView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.contactField.textColor = [UIColor blackColor];
    }else if(tf.tag == 5) {
        self.emailView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.emailField.textColor = [UIColor blackColor];
    }else if(tf.tag == 6) {
        self.dobView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.DOBField.textColor = [UIColor blackColor];
    }else if(tf.tag == 7) {
        self.addressView.backgroundColor = [HexToRGB colorForHex:NORMAL_BACKGROUND];
        self.addressField.textColor = [UIColor blackColor];
    }
}

#pragma mark - Service Call Methods -
- (void) initService {
    ReplyHandler * handler = [[ReplyHandler alloc]
                              initWithModelManager:_modelManager
                              operator:nil
                              progress:nil
                              signupUpdate:nil
                              addMemberUpdate:nil
                              updateUserUpdate:(id)self
                              settingsUpdate:nil
                              loginUpdate:(id)self
                              trackAppDayNightModeUpdate:(id)self
                              saveLocationUpdate:nil
                              getLocationUpdate:nil
                              getLocationHistoryUpdate:nil
                              saveAlertUpdate:nil
                              getAlertUpdate:nil
                              andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
    [self getMemberByMemberIdService];
}

- (void)getMemberByMemberIdService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [profileUpdateHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:profileUpdateHud];
        [profileUpdateHud show:YES];
        NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_modelManager.user.identifier,
                                           kTokenKey:_modelManager.user.sessionToken,
                                           kDeviceTypeKey:@"1",
                                           kDeviceNoKey:deviceUUID
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)updateUserProfileService {
    //---Dismiss the keyboard.---//
    [self.firstNameField resignFirstResponder];
    if ([self checkInput]) {
        if(![self checkUserPreviousDataChange]){
            [self setDefaultView];
            return;
        }
        if ([FamilyTrackerReachibility isUnreachable]) {
            _modelManager.user.firstName = _firstNameField.text;
            _modelManager.user.lastName = _lastNameField.text;
            if([_genderBtn.titleLabel.text isEqualToString:NSLocalizedString(@"Select",nil)]) {
                _modelManager.user.gender =@"";
            } else {
            _modelManager.user.gender = _genderBtn.titleLabel.text;
            }
            _modelManager.user.contact = _contactField.text;
            _modelManager.user.address = _addressField.text;
            _modelManager.user.contact = _contactField.text;
            _modelManager.user.email = _emailField.text;
            NSString *epochTime = @"";
            if (_DOBField.text.length > 0 ) {
                epochTime = [self epochTimeFromString:_DOBField.text];
            }
            _modelManager.user.dob = epochTime;
            [JsonUtil saveObject:_modelManager.user withFile:@"OfflineUser"];
            [self showAlertMessage:NSLocalizedString(@"In offline",nil) message:NSLocalizedString(@"Successfully Updated",nil)];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsOfflineUserInfoUpdated];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
            [self setDefaultView];
        } else {
            //---Progress HUD---//
            profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
            [profileUpdateHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
            [self.view addSubview:profileUpdateHud];
            [profileUpdateHud show:YES];
            NSString *guardianId = @"";
            if ([_modelManager.user.role integerValue] == 1) {
                guardianId = _modelManager.user.identifier;
            } else if (_modelManager.user.guardianId)  {
                guardianId = _modelManager.user.guardianId;
            }
            NSString *epochTime = @"";
            if (_DOBField.text.length > 0 ) {
                epochTime = [self epochTimeFromString:_DOBField.text];
            }
            NSMutableDictionary *bodyDic = [NSMutableDictionary new];
            [bodyDic setObject:_modelManager.user.identifier forKey:kIdentifier];
            [bodyDic setObject:guardianId forKey:kGuardianId];
            [bodyDic setObject:_modelManager.user.userName forKey:kUserName];
            [bodyDic setObject:_firstNameField.text forKey:kUserFirstName];
            [bodyDic setObject:_lastNameField.text forKey:kUserLastName];
            if(_genderBtn.titleLabel.text == nil || [_genderBtn.titleLabel.text isEqualToString:NSLocalizedString(@"Select", nil)]) {
                [bodyDic setObject:@"" forKey:kUserGender];
            } else {
                [bodyDic setObject:_genderBtn.titleLabel.text forKey:kUserGender];
            }
            
            
            [bodyDic setObject:_contactField.text forKey:kUserContact];
            [bodyDic setObject:_emailField.text forKey:kUserEmail];
            [bodyDic setObject:epochTime forKey:kDateOfBirth];
            [bodyDic setObject:_addressField.text forKey:kUserAddrress];
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:bodyDic};
            [_serviceHandler onOperate:newMsg];
        }
    } else {
        [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
        isEditProfile = YES;
        [self editPermission:YES];
    }
}

- (void)uploadProfilePictureService:(NSString *)imageData64Bit {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        //---Progress HUD---//
        profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [profileUpdateHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:profileUpdateHud];
        [profileUpdateHud show:YES];
        
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPLOAD_USER_PICTURE],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUser_id_key:_modelManager.user.identifier,
                                           kTokenKey:_modelManager.user.sessionToken,
                                           kFormat_key:@"png",
                                           kImage_data_key:imageData64Bit,
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)changePasswordService {
    profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
    [profileUpdateHud setLabelText:NSLocalizedString(CHANGE_PASSWORD_INFO_TEXT,nil)];
    [self.view addSubview:profileUpdateHud];
    [profileUpdateHud show:YES];
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kUser_id_key: _modelManager.user.identifier,
                                  kOldPassword_key:_oldPasswordField.text,
                                  kNewPassword_key:_changePasswordField.text
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:CHANGE_PASSWORD],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [profileUpdateHud hide:YES];
        profileUpdateHud = nil;
        if (sourceType == UPDATE_MEMBER_SUCCEEDED) {
            [self setDefaultView];
            [self showAlertMessage:nil message:NSLocalizedString(@"Successfully Updated",nil)];
        }else if (sourceType == UPDATE_MEMBER_FAILED) {
            [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey][_defaultLanguage]) {
                    errorMsg = object[kMessageKey][_defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(@"Update Failed!", nil);
                }
            }else {
                errorMsg = NSLocalizedString(@"Update Failed!", nil);
            }
            [self showAlertMessage:nil message:errorMsg];
        }else if (sourceType == UPLOAD_USER_PICTURE_SUCCCEEDED) {
            [self showAlertMessage:nil message:NSLocalizedString(@"Profile picture updated successfully",nil)];
            [_userProfileImageView setImage:destImage];
            if (object[@"profile_pic"]) {
                _modelManager.user.profilePicture = object[@"profile_pic"];
                [self lazyImageLoader:_modelManager.user.profilePicture];
                [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
            }
        }else if (sourceType == UPLOAD_USER_PICTURE_FAILED) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][_defaultLanguage]) {
                    errorMsg = object[kMessageKey][_defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(TRY_AGAIN,nil);
                }
            }else {
                errorMsg = NSLocalizedString(TRY_AGAIN,nil);
            }
            [self showAlertMessage:nil message:errorMsg];
        }else if(sourceType == GET_MEMBER_BY_ID_SUCCEEDED) {
            if([object isKindOfClass:[NSDictionary class]]) {
                NSError *error;
                User *user = [[User alloc] initWithDictionary:(NSDictionary*)object error:&error];
                _modelManager.user.firstName = user.firstName;
                _modelManager.user.lastName = user.lastName;
                _modelManager.user.gender = user.gender;
                _modelManager.user.contact = user.contact;
                _modelManager.user.email = user.email;
                _modelManager.user.dob = user.dob;
                _modelManager.user.address = user.address;
                [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
                [self setDefaultView];
            }
        }else if(sourceType == GET_MEMBER_BY_ID_FAILED) {
            if ([object isKindOfClass:[NSDictionary class]] && [object[kCodeKey] integerValue] == 555) {
                //---LogOut & goto LoginVC ---//
                [[GlobalData sharedInstance] reset];
                [_modelManager logOut];
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginViewController = [sb instantiateViewControllerWithIdentifier:LOGIN_VIEW_CONTROLLER_KEY];
                [self.navigationController pushViewController:loginViewController animated:YES];
                UIAlertView *trialMessageAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:object[kMessageKey][_modelManager.defaultLanguage] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                [trialMessageAlert show];
            }else {
                //[Common displayToast:@"Something wrong" title:nil duration:2];
            }
        }
    });
}

#pragma mark lazy image loader
- (void)lazyImageLoader:(NSString*)imageUrl {
    [_userProfileImageView setImage:[GlobalData sharedInstance].profilePicture];
    CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
    NSURL *imageURL = [NSURL URLWithString:imageUrl];
    [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
        if ([type isEqualToString:@"image"]) {
            _userProfileImageView.image = (UIImage *)cachedSlide;
            [GlobalData sharedInstance].profilePicture = (UIImage *)cachedSlide;
        } else {
            
        }
    } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
//        NSLog(@"Image cache fail");
    }];
}

#pragma - mark Service call back for change password -
- (void)signupSuccess:(id)object isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        [profileUpdateHud hide:YES];
        profileUpdateHud = nil;
       // isChangePasswordSuccess = NO;
        if (success) {
            _modelManager.user.password = _changePasswordField.text;
            [JsonUtil saveObject:_modelManager.user withFile:NSStringFromClass([User class])];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSMutableDictionary *userDic = [[NSMutableDictionary alloc]init];
            [userDic setObject:_modelManager.user.userName forKey:kUserName];
            [userDic setObject:_changePasswordField.text forKey:kPasswordKey];
            [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:USER_DATA];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoginToJabberServerNoti"
             object:nil];
            updateType = 0;
            _ChangePasswordView.hidden = YES;
            _changePasswordField.text = @"";
            _oldPasswordField.text = @"";
            [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
            [self setDefaultView];
            [self showAlertMessage:NSLocalizedString(@"Password change successfully",nil) message:nil];
        }else {
            [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(CHANGE_PASSWORD_ERROR,nil);
                }
            } else {
                errorMsg = NSLocalizedString(CHANGE_PASSWORD_ERROR,nil);
            }
            [self showAlertMessage:errorMsg message:nil];
        }
    });
}

-(BOOL) checkUserPreviousDataChange {
    NSString * gender;
    if(_genderBtn.titleLabel.text == nil || [_genderBtn.titleLabel.text isEqualToString:@""] || [_genderBtn.titleLabel.text isEqualToString:NSLocalizedString(@"Select",nil)]){
        gender = @"";
    } else {
        gender = _genderBtn.titleLabel.text;
    }
    NSString *dob;
    if(_DOBField.text == nil || [_DOBField.text isEqualToString:@""]) {
        dob = @"";
    } else {
        dob = [self epochTimeFromString:_DOBField.text];
    }
    if(![tempUserData.firstName isEqualToString:_firstNameField.text])
        return YES;
    else if(![tempUserData.lastName isEqualToString:_lastNameField.text])
        return YES;
    else if(![NSLocalizedString(tempUserData.gender,nil) isEqualToString:gender])
        return YES;
    else if(![tempUserData.contact isEqualToString:_contactField.text])
        return YES;
    else if(![tempUserData.email isEqualToString:_emailField.text])
        return YES;
    else if(![tempUserData.dob isEqualToString:dob])
        return YES;
    else if(![tempUserData.address isEqualToString:_addressField.text])
        return YES;
    return NO;
}

#pragma mark  - image crop fucntion -

-(void)imageChooseTypeAction:(UIButton *)sender{
    
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraMenu = [UIAlertAction actionWithTitle:NSLocalizedString(kCamera,nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self showCamera];
                                                       }];
    UIAlertAction* photoGalleryMenu = [UIAlertAction actionWithTitle:NSLocalizedString(kPhotoAlbum,nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self openPhotoAlbum];
                                                             }];
    [alert addAction:cameraMenu];
    [alert addAction:photoGalleryMenu];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // only for iphone
    {
        UIAlertAction* cancelMenu = [UIAlertAction actionWithTitle:NSLocalizedString(kCancel,nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
        [alert addAction:cancelMenu];
    }
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - PECropViewControllerDelegate methods
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    if(croppedImage != NULL) {
        [self uploadUserImage:croppedImage];
        croppedImage = nil;
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action methods

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = selectedImageToCrop;
    UIImage *image = selectedImageToCrop;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)cameraButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - Private methods
- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:controller animated:YES completion:NULL];
}

/*
 Open PECropViewController automattically when image selected.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    selectedImageToCrop = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
}

#pragma mark - updateType Style
-(void)profileUpdateTypeAction:(UIButton *)sender{
    
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* profileUpdateMenu = [UIAlertAction actionWithTitle:NSLocalizedString(@"Profile Update",nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self showPopUpViewForProfileUpdateOrChangePassword];
                                                           [self chooseTypeEditProfileAction:nil];
                                                       }];
    UIAlertAction* changePasswordMenu = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Password",nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self showPopUpViewForProfileUpdateOrChangePassword];
                                                                 [self chooseTypeChangePasswordAction:nil];
                                                             }];
    [alert addAction:profileUpdateMenu];
    [alert addAction:changePasswordMenu];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // only for iphone
    {
        UIAlertAction* cancelMenu = [UIAlertAction actionWithTitle:NSLocalizedString(kCancel,nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               _updateTypePopUpView.hidden = YES;
                                                               _popUpView.hidden = YES;
                                                               [self setDefaultView];
                                                           }];
        [alert addAction:cancelMenu];
    }
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}
@end
