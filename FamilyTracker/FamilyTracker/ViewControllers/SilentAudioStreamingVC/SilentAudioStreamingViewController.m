//
//  SilentAudioStreamingViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 4/13/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "SilentAudioStreamingViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"
#import "GlobalData.h"
#import "Common.h"

@interface SilentAudioStreamingViewController () {
    MBProgressHUD *addDevicetHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    MemberData *selectedMember;
}
@end

@implementation SilentAudioStreamingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _memberList = [ModelManager sharedInstance].members.rows;
    _modelManager = [ModelManager sharedInstance];
    [self setDefaultView];
    [self initService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Service Call Method -
- (void)initService {
    //---Initialize Service Call Back Handler---//
    ReplyHandler * handler = [[ReplyHandler alloc]
                              initWithModelManager:_modelManager
                              operator:nil
                              progress:nil
                              signupUpdate:nil
                              addMemberUpdate:nil
                              updateUserUpdate:nil
                              settingsUpdate:nil
                              loginUpdate:nil
                              trackAppDayNightModeUpdate:(id)self
                              saveLocationUpdate:nil
                              getLocationUpdate:nil
                              getLocationHistoryUpdate:nil
                              saveAlertUpdate:(id)self
                              getAlertUpdate:nil
                              andTarget:self];
    _serviceHandler = [[ServiceHandler alloc] initWithReplyHandler:handler];
}

- (void)startStreamingService:(NSString*) alertType {
    NSString *sharedUrlLink = @"silentStreaming";
    NSDictionary *requestBody = @{kTokenKey:_modelManager.user.sessionToken,
                                  kFamily_id_key:_modelManager.user.guardianId,
                                  kCreated_user:_modelManager.user.identifier,
                                  kUser_id_key :selectedMember.identifier,
                                  kLink:sharedUrlLink,
                                  kAlert_type:alertType,
                                  kResourceTypeKey: kAlertResourceTypeAudio,
                                  kLocationKey:
                                      @{ klatitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.latitude],
                                         kLongitudeKey:[NSNumber numberWithDouble:[GlobalData sharedInstance].userLocation.longitude]
                                         }
                                  };
    NSDictionary *requestBodyDic = @{WHAT_KEY:[NSNumber numberWithInt:SAVE_ALERT],
                                     WHEN_KEY:[NSDate date],
                                     OBJ_KEY:requestBody
                                     };
    [_serviceHandler onOperate:requestBodyDic];
}

#pragma mark - user Define Method
-(void)setDefaultView{
    [_dropDownView setHidden:YES];
    if ([Common isNullObject:[GlobalData sharedInstance].runningSilentStreamingMemberId]) {
        [_startStopSilentBtn setTitle:@"Start Silent Streaming" forState:UIControlStateNormal];
    } else {
        [_startStopSilentBtn setTitle:@"Stop Silent Streaming" forState:UIControlStateNormal];
        for (MemberData *member in _memberList) {
            if ([member.identifier isEqualToString:[GlobalData sharedInstance].runningSilentStreamingMemberId]) {
                _silentStreamingInfo.text = [self getFullName:member];
                selectedMember = member;
                [_memberSelectBtn setTitle:_silentStreamingInfo.text forState:UIControlStateNormal];
                return;
            }
        }
        
    }
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString*)getFullName:(MemberData*)member {
    if (([Common isNullObject:member.firstName] || member.firstName.length<1) && ([Common isNullObject:member.lastName] || member.lastName.length<1)) {
        return member.userName;
    } else {
        if ([Common isNullObject:member.lastName] || member.lastName.length<1) {
            return [NSString stringWithFormat:@"%@",member.firstName];
        } else {
            return [NSString stringWithFormat:@"%@ %@",member.firstName, member.lastName];
        }
    }
}

#pragma mark - Button Action

- (IBAction)memberSelectAction:(id)sender {
    if ([Common isNullObject:[GlobalData sharedInstance].runningSilentStreamingMemberId]) {
        if ([_dropDownView isHidden]) {
            [_dropDownView setHidden:NO];
        } else {
            [_dropDownView setHidden:NO];
        }
    } else {
        [self showAlertMessage:nil message:@"You have already start a silent streaming. Please stop the previous silent streaming first."];
        return;
    }
    
}

- (IBAction)startStopSilentStreamingAction:(id)sender {
    addDevicetHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:addDevicetHud];
    [addDevicetHud show:YES];
    if ([Common isNullObject:[GlobalData sharedInstance].runningSilentStreamingMemberId]) {
        [addDevicetHud setLabelText:NSLocalizedString(@"Start Silent Streaming...",nil)];
        [self startStreamingService:kAlert_type_silent_audio_streaming_on];
    } else {
        [addDevicetHud setLabelText:NSLocalizedString(@"Stop Silent Streaming...",nil)];
        [self startStreamingService:kAlert_type_silent_audio_streaming_off];
    }
}

#pragma mark tableview delegate methods -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    MemberData *member = [_memberList objectAtIndex:indexPath.row];
    NSString *fullName = @"";
    if(([Common isNullObject:member.firstName] || member.firstName.length<1) && ([Common isNullObject:member.lastName] || member.lastName.length<1)) {
        fullName = member.userName;
    }else {
        if ([Common isNullObject:member.lastName] || member.lastName.length<1) {
            fullName = [NSString stringWithFormat:@"%@",member.firstName];
        }else {
            fullName = [NSString stringWithFormat:@"%@ %@",member.firstName, member.lastName];
        }
    }
    cell.textLabel.text = fullName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_dropDownView setHidden:YES];
    selectedMember = [_memberList objectAtIndex:indexPath.row];
    [_memberSelectBtn setTitle:[self getFullName:selectedMember] forState:UIControlStateNormal];
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [addDevicetHud hide:YES];
        addDevicetHud = nil;
        if(sourceType == SAVE_ALERT_SUCCEEDED) {//---Save Alerts
            NSError *error = nil;
            _modelManager.liveStreamingAlert  = [[Notification alloc] initWithDictionary:object error:&error];
            if ([Common isNullObject:[GlobalData sharedInstance].runningSilentStreamingMemberId]) {
                 _silentStreamingInfo.text = [NSString stringWithFormat:@"%@", [self getFullName:selectedMember]];
                [GlobalData sharedInstance].runningSilentStreamingMemberId = selectedMember.identifier;
                [Common displayToast:NSLocalizedString(@"Start silent streaming command has been sent.", nil) title:nil duration:1];
            } else {
                _silentStreamingInfo.text = @"";
                [_memberSelectBtn setTitle:@"Select Member" forState:UIControlStateNormal];
                [_startStopSilentBtn setTitle:@"Start Silent Streaming" forState:UIControlStateNormal];
                [GlobalData sharedInstance].runningSilentStreamingMemberId = nil;
                [Common displayToast:NSLocalizedString(@"Stop silent streaming command has been sent.", nil)  title:nil duration:1];
            }
        } else if(sourceType == SAVE_ALERT_FAILED) {
            [Common displayToast:NSLocalizedString(@"Silent streaming command has been failed.", nil)  title:nil duration:1];
        }
    });
}

@end
