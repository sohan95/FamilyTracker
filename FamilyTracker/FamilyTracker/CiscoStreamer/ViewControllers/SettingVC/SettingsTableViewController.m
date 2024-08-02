//
//  SettingsTableViewController.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 17/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Constant.h"
#import "BehaviorConfigVC.h"
#import "FTPServerSettingVC.h"
#import "WowzaSettingVC.h"

#import "AddProfileVC.h"
#import "StreamerConfiguration.h"

#define kVideoResolution    1001
#define kVideoFrameRate     1002
#define kVideoBitRate       1003
#define kRecordingLimit     1004

#define kVideoResotionScreenTag     201
#define kVideoFrameScreenTag        202
#define kVideoBitrateScreenTag      203

#define kRecordingLimitScreenTag    301

@interface SettingsTableViewController ()
{
    NSArray *settingsMenuArr;
    NSArray *videoSettingsMenuArr;
    NSArray *recordingSettingsMenuArr;
    
    NSArray *resolutionArr;
    NSArray *frameRateArr;
    NSArray *bitRateArr;
    NSArray *recordingLimitArr;
    
    NSArray *videoStreamingTypes;
    
    UIPickerView *settingSelectionPicker;
    UITextField *pickerTextfield;
    NSUInteger pickerSettingTag;
    
    UITableViewCell *selectedTableCell;
    
    NSArray *profileResolutions;
    NSArray *profileFrameRates;
    NSArray *profileBitRates;
    
    StreamerConfiguration *stremerConfig;
}

@property (nonatomic, assign) NSUInteger pickerSettingTag;
@end

@implementation SettingsTableViewController

@synthesize screenTag, pickerSettingTag, parentVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    stremerConfig = [StreamerConfiguration sharedInstance];
    
    //set Title
    if (screenTag == 100) {
        self.title = @"Settings";
    }
    else if (screenTag == 101) {
        self.title = @"Video Configuration";
    }
    else if (screenTag == 103) {
        self.title = @"Recording Configuration";
    }
    else if (screenTag == kVideoResotionScreenTag) {
        self.title = @"Video Configuration";
    }
    else if (screenTag == kVideoFrameScreenTag) {
        self.title = @"Video Configuration";
    }
    else if (screenTag == kVideoBitrateScreenTag) {
        self.title = @"Video Configuration";
    }
    else if (screenTag == kRecordingLimitScreenTag) {
        self.title = @"Recording Configuration";
    }
    else if (screenTag == kStreamTypeSettingsScreenTag) {
        self.title = @"Behavior Configuration";
    }
    else if (screenTag == kProfileResolutionSettingsScreenTag) {
        self.title = @"Resolutions";
    }
    else if (screenTag == kProfileFrameRateSettingsScreenTag) {
        self.title = @"Framerates";
    }
    else if (screenTag == kProfileBitRateSettingsScreenTag) {
        self.title = @"Bitrates";
    }
    
    NSString *appBehaviour = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_behavior"];
    if (appBehaviour != nil && [appBehaviour isEqualToString:@"start_streaming"]) {
        settingsMenuArr = @[@{@"title":@"Video Configuration", @"screen_tag":[NSNumber numberWithInteger:101]},
                            //@{@"title":@"Wowza Configuration", @"screen_tag":[NSNumber numberWithInteger:105]},
                            @{@"title":@"Behavior Configuration", @"screen_tag":[NSNumber numberWithInteger:102]},
                            @{@"title":@"Recording Configuration", @"screen_tag":[NSNumber numberWithInteger:103]},
                            ];
    }
    else
    {
        settingsMenuArr = @[@{@"title":@"Video Configuration", @"screen_tag":[NSNumber numberWithInteger:101]},
                            @{@"title":@"Behavior Configuration", @"screen_tag":[NSNumber numberWithInteger:102]},
                            @{@"title":@"Recording Configuration", @"screen_tag":[NSNumber numberWithInteger:103]},
                            @{@"title":@"FPT Server Configuration", @"screen_tag":[NSNumber numberWithInteger:104]}
                            ];
    }
   
    
    videoSettingsMenuArr = @[@{@"title":@"Resolution", @"screen_tag":[NSNumber numberWithInteger:kVideoResotionScreenTag], @"userdefault_tag":kVideoResolutionSettings},
                             @{@"title":@"Framerate", @"screen_tag":[NSNumber numberWithInteger:kVideoFrameScreenTag], @"userdefault_tag":kVideoFrameRateSettings} ,
                             @{@"title":@"Bitrate", @"screen_tag":[NSNumber numberWithInteger:kVideoBitrateScreenTag], @"userdefault_tag":kVideoBitRateSettings}];
    
    recordingSettingsMenuArr = @[@{@"title":@"Recording Limit", @"screen_tag":[NSNumber numberWithInteger:kRecordingLimitScreenTag], @"userdefault_tag": kRecordingLimitSettings}];
    
    [self fetchConstantsValueFromLibrary];
    
    profileResolutions = [NSArray arrayWithArray:resolutionArr];
    profileFrameRates = [NSArray arrayWithArray:frameRateArr];
    profileBitRates = [NSArray arrayWithArray:bitRateArr];
    
    //    [self addPickerView];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

/*
- (void)addPickerView{
    pickerTextfield = [[UITextField alloc]initWithFrame:
                                CGRectMake(10, 100, 300, 30)];
    [pickerTextfield setHidden:YES];
    pickerTextfield.borderStyle = UITextBorderStyleRoundedRect;
//    myTextField.textAlignment = UITextAlignmentCenter;
    pickerTextfield.delegate = self;
    [self.view addSubview:pickerTextfield];

    settingSelectionPicker = [[UIPickerView alloc]init];
    [settingSelectionPicker setHidden:YES];
    settingSelectionPicker.dataSource = self;
    settingSelectionPicker.delegate = self;
    settingSelectionPicker.showsSelectionIndicator = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneSettingSelection:)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-
                                     settingSelectionPicker.frame.size.height-50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    NSArray *toolbarItems = [NSArray arrayWithObjects: doneButton, nil];
    [toolBar setItems:toolbarItems];
    pickerTextfield.inputView = settingSelectionPicker;
    pickerTextfield.inputAccessoryView = toolBar;
    
}*/

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchConstantsValueFromLibrary {
    
    //Resolutions
    NSArray *supportedResolutions = [stremerConfig getAllSupportedResolutions];
    
    NSMutableArray *resolutions = [NSMutableArray arrayWithCapacity:0];
    for (NSString *resolution in supportedResolutions) {
        [resolutions addObject:@{@"title":resolution}];
    }
    
    resolutionArr = [NSArray arrayWithArray:resolutions];
    
    // BitRates
    NSArray *supportedBitRates = [stremerConfig getAllSupportedBitRates];
    
    NSMutableArray *bitRates = [NSMutableArray arrayWithCapacity:0];
    for (NSString *birRate in supportedBitRates) {
        [bitRates addObject:@{@"title":birRate}];
    }
    
    bitRateArr = [NSArray arrayWithArray:bitRates];
    
    //FrameRates
    NSArray *supportedFrameRates = [stremerConfig getAllSupportedFrameRates];
    
    NSMutableArray *frameRates = [NSMutableArray arrayWithCapacity:0];
    for (NSString *frameRate in supportedFrameRates) {
        [frameRates addObject:@{@"title":frameRate}];
    }
    
    frameRateArr = [NSArray arrayWithArray:frameRates];
    
    //Recording Limits
    NSArray *supportedRecordingLimits = [stremerConfig getAllSupportedRecordingMaxLimits];
    
    NSMutableArray *recordingLimits = [NSMutableArray arrayWithCapacity:0];
    for (NSString *recordingLimit in supportedRecordingLimits) {
        [recordingLimits addObject:@{@"title":recordingLimit}];
    }
    
    recordingLimitArr = [NSArray arrayWithArray:recordingLimits];
    
    //Stream Types
    NSArray *supportedStreamTypes = [stremerConfig getAllSupportedStreamTypes];
    
    NSMutableArray *streamTypes = [NSMutableArray arrayWithCapacity:0];
    for (NSString *stremType in supportedStreamTypes) {
        [streamTypes addObject:@{@"title":stremType}];
    }
    
    videoStreamingTypes = [NSArray arrayWithArray:streamTypes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if (screenTag == 100) {
        return [settingsMenuArr count];
    }
    else if (screenTag == 101) {
        return [videoSettingsMenuArr count];
    }
    else if (screenTag == 103) {
        return [recordingSettingsMenuArr count];
    }
    else if (screenTag == kVideoResotionScreenTag) {
        return [resolutionArr count];
    }
    else if (screenTag == kVideoFrameScreenTag) {
        return [frameRateArr count];
    }
    else if (screenTag == kVideoBitrateScreenTag) {
        return [bitRateArr count];
    }
    else if (screenTag == kRecordingLimitScreenTag) {
        return [recordingLimitArr count];
    }
    else if (screenTag == kStreamTypeSettingsScreenTag) {
        return [videoStreamingTypes count];
    }
    else if (screenTag == kProfileResolutionSettingsScreenTag) {
        return [profileResolutions count];
    }
    else if (screenTag == kProfileFrameRateSettingsScreenTag) {
        return [profileFrameRates count];
    }
    else if (screenTag == kProfileBitRateSettingsScreenTag) {
        return [profileBitRates count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (screenTag == 101) {
        return @"VIDEO STREAMING";
    }
    else if (screenTag == 103) {
        return @"RECORDING CONFIGURATION";
    }
    else if (screenTag == kVideoResotionScreenTag) {
        return @"RESOLUTION";
    }
    else if (screenTag == kVideoFrameScreenTag) {
        return @"FRAMERATE";
    }
    else if (screenTag == kVideoBitrateScreenTag) {
        return @"BITRATE";
    }
    else if (screenTag == kRecordingLimitScreenTag) {
        return @"RECORDING LIMIT";
    }
    else if (screenTag == kStreamTypeSettingsScreenTag) {
        return @"STREAM TYPE";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *settingLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *settingValue = (UILabel *)[cell viewWithTag:101];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (screenTag == 100) {
        // Main Setting Rows
        
        [settingLabel setText:[[settingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else if (screenTag == 101) {
        // Video Configuration Rows
        
        [settingLabel setText:[[videoSettingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        
        NSString *userDefaultKey = [[videoSettingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"userdefault_tag"];
        
        
        if ([userDefaultKey isEqualToString:kVideoBitRateSettings]) {
            [settingValue setText:[stremerConfig getSelectedBitRate]];
        }
        else if ([userDefaultKey isEqualToString:kVideoFrameRateSettings]) {
            [settingValue setText:[stremerConfig getFrameRate]];
        }
        else if ([userDefaultKey isEqualToString:kVideoResolutionSettings]) {
            [settingValue setText:[stremerConfig getResolution]];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else if (screenTag == 103) {
        // Record configuration rows
        [settingLabel setText:[[recordingSettingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue setText:[stremerConfig getSelectedVideoRecordLimit]];
    
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else if (screenTag == kVideoResotionScreenTag) {
        [settingLabel setText:[[resolutionArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        NSString *settingSaved = [stremerConfig getResolution];

        if ([settingSaved isEqualToString:[[resolutionArr objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else if (screenTag == kVideoFrameScreenTag) {
        [settingLabel setText:[[frameRateArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        NSString *settingSaved = [stremerConfig getFrameRate];

        if ([settingSaved isEqualToString:[[frameRateArr objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else if (screenTag == kVideoBitrateScreenTag) {
        [settingLabel setText:[[bitRateArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        NSString *settingSaved = [stremerConfig getSelectedBitRate];
        
        if ([settingSaved isEqualToString:[[bitRateArr objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else if (screenTag == kRecordingLimitScreenTag) {
        [settingLabel setText:[[recordingLimitArr objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        NSString *settingSaved = [stremerConfig getSelectedVideoRecordLimit];
        
        if ([settingSaved isEqualToString:[[recordingLimitArr objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else if (screenTag == kStreamTypeSettingsScreenTag) {
        [settingLabel setText:[[videoStreamingTypes objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        NSString *settingSaved = [stremerConfig getStreamType];
        if ([settingSaved isEqualToString:[[videoStreamingTypes objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    else if (screenTag == kProfileResolutionSettingsScreenTag) {
        [settingLabel setText:[[profileResolutions objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        if ([self.profileDetail valueForKey:@"width"] != nil && [self.profileDetail valueForKey:@"height"] != nil) {
            NSString *settingSaved = [NSString stringWithFormat:@"%@x%@",[self.profileDetail valueForKey:@"width"], [self.profileDetail valueForKey:@"height"]];
            
            if ([settingSaved isEqualToString:[[profileResolutions objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
    }
    else if (screenTag == kProfileFrameRateSettingsScreenTag) {
        [settingLabel setText:[[profileFrameRates objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        if ([self.profileDetail valueForKey:@"framerate"] != nil) {
            NSString *settingSaved = [self.profileDetail valueForKey:@"framerate"];
            if ([settingSaved isEqualToString:[[profileFrameRates objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        
    }
    else if (screenTag == kProfileBitRateSettingsScreenTag) {
        [settingLabel setText:[[profileBitRates objectAtIndex:indexPath.row] objectForKey:@"title"]];
        [settingValue removeFromSuperview];
        
        if ([self.profileDetail valueForKey:@"bitrate"] != nil) {
            NSString *settingSaved = [self.profileDetail valueForKey:@"bitrate"];
            if ([settingSaved isEqualToString:[[profileBitRates objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
    }
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    settingsVC.screenTag = 1000;
    
    selectedTableCell = nil;
    
    if (screenTag == 100) {
        NSUInteger cellScreenTag = [[[settingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"screen_tag"] integerValue];
        
        if (cellScreenTag == 101 || cellScreenTag == 103) {
            // Video Configuration OR Recording configuration
            
            settingsVC.screenTag = cellScreenTag;
            [self.navigationController pushViewController:settingsVC animated:NO];
        }
        else if (cellScreenTag == 102) {
            // Benavior Configuration
            sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
            BehaviorConfigVC *behaviorConfigVC = [sb instantiateViewControllerWithIdentifier:@"BehaviorConfigVC"];
            [self.navigationController pushViewController:behaviorConfigVC animated:NO];
        }
        else if (cellScreenTag == 104) {
            // FTPS server
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
            FTPServerSettingVC *ftpServerVC = [sb instantiateViewControllerWithIdentifier:@"FTPServerSettingVC"];
            [self.navigationController pushViewController:ftpServerVC animated:NO];
        }
        else if (cellScreenTag == 105) {
            // Wowza Settings
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingScreens" bundle:nil];
            WowzaSettingVC *wowzaSettingsVC = [sb instantiateViewControllerWithIdentifier:@"WowzaSettingVC"];
            [self.navigationController pushViewController:wowzaSettingsVC animated:NO];
        }
    }
    else if (screenTag == 101) {
        settingsVC.screenTag = [[[videoSettingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"screen_tag"] integerValue];
        [self.navigationController pushViewController:settingsVC animated:NO];
//        [settingSelectionPicker setHidden:NO];
//        [pickerTextfield resignFirstResponder];
    }
    else if (screenTag == 103) {
        settingsVC.screenTag = [[[recordingSettingsMenuArr objectAtIndex:indexPath.row] objectForKey:@"screen_tag"] integerValue];
        [self.navigationController pushViewController:settingsVC animated:NO];
    }
    else if (screenTag == kVideoResotionScreenTag) {
        
        NSString *selectedValue = [[resolutionArr objectAtIndex:indexPath.row] objectForKey:@"title"];
//        [self updateUserDefaults:selectedValue forKey:kVideoResolutionSettings];
        
        [stremerConfig setResolution:selectedValue];
        
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:indexPath.row] forSettingKey:kVideoResolutionSettings inContext:[appDelegate managedObjectContext]];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    else if (screenTag == kVideoFrameScreenTag) {
        
        NSString *selectedValue = [[frameRateArr objectAtIndex:indexPath.row] objectForKey:@"title"];
//        [self updateUserDefaults:selectedValue forKey:kVideoFrameRateSettings];

        [stremerConfig setFrameRate:selectedValue];
        
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:indexPath.row] forSettingKey:kVideoFrameRateSettings inContext:[appDelegate managedObjectContext]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (screenTag == kVideoBitrateScreenTag) {
        
        NSString *selectedValue = [[bitRateArr objectAtIndex:indexPath.row] objectForKey:@"title"];
        [stremerConfig setSelectedBitRate:selectedValue];
        
//        [self updateUserDefaults:selectedValue forKey:kVideoBitRateSettings];
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:indexPath.row] forSettingKey:kVideoBitRateSettings inContext:[appDelegate managedObjectContext]];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (screenTag == kRecordingLimitScreenTag) {
        
        NSString *selectedValue = [[recordingLimitArr objectAtIndex:indexPath.row] objectForKey:@"title"];
        [stremerConfig setSelectedVideoRecordLimit:selectedValue];
        
//        [self updateUserDefaults:selectedValue forKey:kRecordingLimitSettings];
        
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:indexPath.row] forSettingKey:kRecordingLimitSettings inContext:[appDelegate managedObjectContext]];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (screenTag == kStreamTypeSettingsScreenTag) {
        
        NSString *selectedValue = [[videoStreamingTypes objectAtIndex:indexPath.row] objectForKey:@"title"];
        [stremerConfig setStreamType:selectedValue];
        
//        [self updateUserDefaults:selectedValue forKey:kVideoStreamType];
        
//        [SettingsData updateSettingValue:[NSNumber numberWithInt:indexPath.row] forSettingKey:kVideoStreamType inContext:[appDelegate managedObjectContext]];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (screenTag == kProfileResolutionSettingsScreenTag) {
        
        NSString *resolution = [[profileResolutions objectAtIndex:indexPath.row] valueForKey:@"title"];
        
        NSRange range = [resolution rangeOfString:@"x"];
        NSNumber *width = [NSNumber numberWithInteger:[[resolution substringToIndex:range.location] integerValue]];
        NSNumber *height = [NSNumber numberWithInt:[[resolution substringFromIndex:range.location+1] integerValue]];
        
//        self.profileDetail = [NSMutableDictionary dictionaryWithCapacity:0];
        [self.profileDetail setValue:width forKey:@"width"];
        [self.profileDetail setValue:height forKey:@"height"];
        
        AddProfileVC *profileVC = (AddProfileVC *)self.parentVC;
        profileVC.profileDics = [NSMutableDictionary dictionaryWithDictionary:self.profileDetail];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (screenTag == kProfileFrameRateSettingsScreenTag) {
        AddProfileVC *profileVC = (AddProfileVC *)self.parentVC;
        [self.profileDetail setValue:[[profileFrameRates objectAtIndex:indexPath.row] valueForKey:@"title"] forKey:@"framerate"];
        profileVC.profileDics = [NSMutableDictionary dictionaryWithDictionary:self.profileDetail];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if (screenTag == kProfileBitRateSettingsScreenTag) {
        AddProfileVC *profileVC = (AddProfileVC *)self.parentVC;
        [self.profileDetail setValue:[[profileBitRates objectAtIndex:indexPath.row] valueForKey:@"title"] forKey:@"bitrate"];
        profileVC.profileDics = [NSMutableDictionary dictionaryWithDictionary:self.profileDetail];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        selectedTableCell = [tableView cellForRowAtIndexPath:indexPath];
        [settingSelectionPicker setHidden:NO];
        
        [pickerTextfield resignFirstResponder];
    }
    
    //    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
}

//
//#pragma mark - User Defined Methods
//- (void)updateUserDefaults:(id)settingValue forKey:(NSString *)settingKey {
//    NSMutableDictionary *settingDetail = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kSettingData]];
//    
//    [settingDetail setObject:settingValue forKey:settingKey];
//    [[NSUserDefaults standardUserDefaults] setObject:settingDetail forKey:kSettingData];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}


@end
