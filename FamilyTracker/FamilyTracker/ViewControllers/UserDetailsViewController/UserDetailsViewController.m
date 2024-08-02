//
//  UserDetailsViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 1/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "UserDetailsViewController.h"
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
#define NORMAL_BACKGROUND @"#F2F8F1"
#define EDIT_BACKGROUND @"6FB67D"

@interface UserDetailsViewController ()<DataUpdater,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    MBProgressHUD *profileUpdateHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    UIDatePicker *datePicker;
}
@property (weak,nonatomic) IBOutlet UITextField *userNameField;
@property (weak,nonatomic) IBOutlet UITextField *firstNameField;
@property (weak,nonatomic) IBOutlet UITextField *lastNameField;
@property (weak,nonatomic) IBOutlet UIButton *genderBtn;
@property (weak,nonatomic) IBOutlet UITextField *contactField;
@property (weak,nonatomic) IBOutlet UITextField *DOBField;
@property (weak,nonatomic) IBOutlet UITextField *emailField;
@property (weak,nonatomic) IBOutlet UITextField *addressField;
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
@property (nonatomic, strong) User *memberUser;
@property (nonatomic,strong) NSString * defaultLanguage;
typedef void(^convertBase65String)(NSString *);
-(void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler;
- (IBAction)profileEditBtn:(id)sender;
- (IBAction)dropDownMaleSelectBtn:(id)sender;
- (IBAction)dropDownFemaleSelectBtn:(id)sender;
- (IBAction)editProfileImageBtn:(id)sender;

@end

@implementation UserDetailsViewController {
    BOOL isEditProfile;
    BOOL keyBoradOpen;
    int textFieldIndex;
    NSString * imageBase64String;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //---show nevigationbar---//
    [self.navigationController setNavigationBarHidden:NO];
    self.title = NSLocalizedString(@"Member Profile",nil);
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    _modelManager = [ModelManager sharedInstance];
    UITapGestureRecognizer *viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard2:)];
    [self.view addGestureRecognizer:viewTapRecognizer];
    imageBase64String = @"";
    _memberUser = [[User alloc] init];
    [self initService];
    [self setDefaultView];
    //---Set Date Of Birth Picker---//
    [self setDateOffBirthPicker];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Service Call Methods -
- (void) initService {
    //---Initialize Service Call Back Handler---//
    ReplyHandler * handler = [[ReplyHandler alloc]
                              initWithModelManager:_modelManager
                              operator:nil
                              progress:nil
                              signupUpdate:nil
                              addMemberUpdate:nil
                              updateUserUpdate:(id)self
                              settingsUpdate:nil
                              loginUpdate:nil
                              trackAppDayNightModeUpdate:(id)self
                              saveLocationUpdate:nil
                              getLocationUpdate:nil
                              getLocationHistoryUpdate:nil
                              saveAlertUpdate:nil
                              getAlertUpdate:nil
                              andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

#pragma mark - User Defined Methods -
- (void)setDefaultView {
    isEditProfile = NO;
    keyBoradOpen = NO;
    textFieldIndex = 0;
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2;
    self.userProfileImageView.layer.masksToBounds = YES;
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
    if ([_modelManager.user.role integerValue] != 1) {
        _profileEditBtnOutlet.hidden = true;
        _editProfileImageOutlet.hidden = true;
    }
    if(_memberUser.userName == nil) {
        [self getMemberByMemberIdService];
    }
    else {
        [self lazyImageLoader:_memberUser.profilePicture];
        //---Set UserName in Profile Page
        if(([Common isNullObject:_memberUser.firstName] || _memberUser.firstName.length<1) && ([Common isNullObject:_memberUser.lastName] || _memberUser.lastName.length<1)) {
            _memberName.text = _memberUser.userName;
        }else {
            if ([Common isNullObject:_memberUser.lastName] || _memberUser.lastName.length<1) {
                _memberName.text = [NSString stringWithFormat:@"%@",_memberUser.firstName];
            }else {
                _memberName.text = [NSString stringWithFormat:@"%@ %@",_memberUser.firstName, _memberUser.lastName];
            }
        }
        //---Set Total User Role Name in Profile Page
        if ([_memberUser.role intValue] == 1) {
            _memberRoleName.text = NSLocalizedString(@"Guardian",nil);
        }else {
            _memberRoleName.text = NSLocalizedString(@"Member",nil);
        }
        //---Set Total Member number in Profile Page
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
        self.userNameField.text =_memberUser.userName;
        self.firstNameField.text = _memberUser.firstName;
        self.lastNameField.text = _memberUser.lastName;
        [self.genderBtn setTitle:_memberUser.gender forState:UIControlStateNormal];
        self.contactField.text = _memberUser.contact;
        self.emailField.text = _memberUser.email;
        self.addressField.text = _memberUser.address;
        if ( [Common isNullObject:_memberUser.firstName]) {
            self.firstNameField.text = @"";
        }
        if ([Common isNullObject:_memberUser.lastName]) {
            self.lastNameField.text = @"";
        }
        if ([Common isNullObject:_memberUser.contact]) {
            self.contactField.text = @"";
        }
        if ([Common isNullObject:_memberUser.email]) {
            self.emailField.text = @"";
        }
        if ([Common isNullObject:_memberUser.address]) {
            self.addressField.text = @"";
        }
        if ( [_memberUser.gender isEqualToString:GENDER_PLACEHOLDER_TEXT] || [Common isNullObject:_memberUser.gender]) {
            [_genderBtn setTitle:@"" forState:UIControlStateNormal];
        }
        NSString *dateStr = @"";
        if([Common isNullObject:_memberUser.dob] || _memberUser.dob.length == 0) {
            
        } else{
            dateStr = [self stringFromEpochTime:_memberUser.dob];
        }
        self.DOBField.text = dateStr;
    }
}

- (void)editPermission:(BOOL)status {
    //[self.userNameField setEnabled:status];
    [self.firstNameField setEnabled:status];
    [self.lastNameField setEnabled:status];
    [self.genderBtn setEnabled:status];
    [self.contactField setEnabled:status];
    //[self.emailField setEnabled:status];
    [self.DOBField setEnabled:status];
    [self.addressField setEnabled:status];
}

- (void)chcekKeyboradOpen {
    if(keyBoradOpen){
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

//- (BOOL)checkInput {
//    NSString *alertMessage = nil;
//    if (alertMessage == nil) {
//        return YES;
//    }else {
//        [self showAlertMessage:nil message:alertMessage];
//        return NO;
//    }
//}


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
                    _contactField.text = mobileNumber;//[NSString stringWithFormat:@"%@%@",[countryCode stringValue], nationalNumber];
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


-(void)uploadUserImage:(UIImage *)userImage{
    [self base64ConvertImage:userImage andCompletionHandler:^(void) {
        [self uploadProfilePictureService:imageBase64String];
    }];
}

-(void)base64ConvertImage:(UIImage *)image andCompletionHandler:(void (^)(void))completionHandler{
    
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
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
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

#pragma mark - Email Validation Checker -
- (BOOL)validEmail:(NSString *)checkString {
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark Gesture Recognizer Delegate -
- (void)hideKeyboard2:(UITapGestureRecognizer*)sender {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.addressField resignFirstResponder];
    [self.contactField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self hideDropDownView];
   
    
}

#pragma mark - Button Action Methods -
- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setGenderAction:(UIButton *)sender {
    [self chcekKeyboradOpen];
    [self.dropDownView setHidden:NO];
}

- (IBAction)profileEditBtn:(id)sender {
    if ([_modelManager.user.role integerValue] != 1) {
        return;
    }
    if(isEditProfile == NO){
        [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
        isEditProfile = YES;
        [self editPermission:YES];
    }
    else{
        [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_edit"] forState:UIControlStateNormal];
        isEditProfile = NO;
        [self editPermission:NO];
        [self updateUserProfileService];
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
    if ([_modelManager.user.role integerValue] != 1) {
        return;
    }
    [self chcekKeyboradOpen];
    [self.dropDownView setHidden:YES];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma - mark image chooser delegate -
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *newImage = image;
    if(newImage != NULL) {
        [self uploadUserImage:newImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Image Convert in Base64String -
- (void)imageConvertInBase64Method:(UIImage *)image andBlock: (convertBase65String) compblock {
    compblock([UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
}

#pragma - mark keyborad -
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

#pragma mark - Service methods -
- (void)updateUserProfileService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        //---Dismiss the keyboard.---//
        [self.firstNameField resignFirstResponder];
        if ([self checkInput]) {
            //---Progress HUD---//
            profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
            [profileUpdateHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
            [self.view addSubview:profileUpdateHud];
            [profileUpdateHud show:YES];
            NSString *guardianId = @"";
            if (_memberRole == 1) {
                guardianId = _modelManager.user.identifier;
            }else if (_memberUser.guardianId)  {
                guardianId = _memberUser.guardianId;
            }
        NSString *epochTime = @"";
        if (_DOBField.text.length >0 ) {
            epochTime = [self epochTimeFromString:_DOBField.text];
        }
        NSMutableDictionary *bodyDic = [NSMutableDictionary new];
        [bodyDic setObject:_userId forKey:kIdentifier];
        [bodyDic setObject:guardianId forKey:kGuardianId];
        [bodyDic setObject:_memberUser.userName forKey:kUserName];
        [bodyDic setObject:_firstNameField.text forKey:kUserFirstName];
        [bodyDic setObject:_lastNameField.text forKey:kUserLastName];
        
        if(_genderBtn.titleLabel.text == nil) {
            [bodyDic setObject:@"" forKey:kUserGender];
        } else {
            [bodyDic setObject:_genderBtn.titleLabel.text forKey:kUserGender];
        }
        [bodyDic setObject:_contactField.text forKey:kUserContact];
        [bodyDic setObject:_emailField.text forKey:kUserEmail];
        [bodyDic setObject:epochTime forKey:kDateOfBirth];
        [bodyDic setObject:_addressField.text forKey:kUserAddrress];
            NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_MEMBER_DETAILS],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:bodyDic};
            [_serviceHandler onOperate:newMsg];
        }
        else{
            [self.profileEditBtnOutlet setImage:[UIImage imageNamed:@"profile_update"] forState:UIControlStateNormal];
            isEditProfile = YES;
            [self editPermission:YES];
        }
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
                                 OBJ_KEY:@{kUser_id_key:_userId,
                                           kTokenKey:_modelManager.user.sessionToken,
                                           kFormat_key:@"png",
                                           kImage_data_key:imageData64Bit,
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)getMemberByMemberIdService {
    if ([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2.0];
    }else {
        profileUpdateHud = [[MBProgressHUD alloc] initWithView:self.view];
        [profileUpdateHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:profileUpdateHud];
        [profileUpdateHud show:YES];
        
//        NSString* deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_MEMBER_BY_ID],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:@{kUserid_key:_userId,
                                           kTokenKey:_modelManager.user.sessionToken
                                           }
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Response -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [profileUpdateHud hide:YES];
        profileUpdateHud = nil;
        if (sourceType == UPDATE_MEMBER_DETAILS_SUCCEEDED) {
            [self showAlertMessage:nil message:NSLocalizedString(@"Update is completed",nil)];
        }else if (sourceType == UPDATE_MEMBER_DETAILS_FAILED) {
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
            [self showAlertMessage:nil message:NSLocalizedString(@"Profile updates successfully",nil)];
            if ([object isKindOfClass:[NSDictionary class]] && object[@"profile_pic"]) {
                _modelManager.user.profilePicture = object[@"profile_pic"];
                [self lazyImageLoader:_modelManager.user.profilePicture];
            }
        }else if (sourceType == UPLOAD_USER_PICTURE_FAILED) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]){
                if (object[kMessageKey][_defaultLanguage]) {
                    errorMsg = object[kMessageKey][_defaultLanguage];
                }else {
                    errorMsg = NSLocalizedString(PROFILE_UPDATE_ERROR,nil);
                }
            }else {
                errorMsg = NSLocalizedString(PROFILE_UPDATE_ERROR,nil);
            }
            [self showAlertMessage:nil message:errorMsg];
            
        }else if(sourceType == GET_MEMBER_BY_ID_SUCCEEDED) {
            if([object isKindOfClass:[NSDictionary class]]){
                NSError *error;
                _memberUser = [[User alloc] initWithDictionary:(NSDictionary*)object error:&error];
                [self setDefaultView];
            }
        }else if(sourceType == GET_MEMBER_BY_ID_FAILED) {
        }
    });
}

#pragma  - mark lazy image loder -
- (void)lazyImageLoader:(NSString*)imageUrl {
    if(imageUrl == nil) {
        return;
    }
    if([_memberUser.role intValue] == 1 && [_memberUser.userName isEqualToString:_modelManager.user.userName]) {
        CacheSlide *imageCacheObje = [[CacheSlide alloc] init];
        NSURL *imageURL = [NSURL URLWithString:imageUrl];
        [imageCacheObje loadImageWithURL:imageURL type:@"image" completionBlock:^(id cachedSlide, NSString *type) {
            if ([type isEqualToString:@"image"]) {
                UIImage *image = (UIImage *)cachedSlide;
                _userProfileImageView.image = image;
                [GlobalData sharedInstance].profilePicture = image;
            } else {
                
            }
        } failureBlock:^(NSURLRequest *request, NSURLResponse *response, NSError *error) {
            NSLog(@"Image cache fail");
        }];
    } else {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
             NSURL *imageURL = [NSURL URLWithString:imageUrl];
             NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
             dispatch_sync(dispatch_get_main_queue(), ^{
                 _userProfileImageView.image = [UIImage imageWithData:imageData];
             });
         });
    }
}

@end
