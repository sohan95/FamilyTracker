//
//  FamilyMemberListViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/16/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "FamilyMemberListViewController.h"
#import "MemberControlTableViewController.h"
#import "MemberSignUpViewController.h"
#import "MemberData.h"
#import "ModelManager.h"
#import "MemberListCustomCell.h"

@interface FamilyMemberListViewController ()
@property(nonatomic, readwrite) NSMutableArray *memberList;
@end

@implementation FamilyMemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.memberListView.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    self.memberListView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.memberListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = NSLocalizedString(CONTROL_MEMBER_KEY,nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [GlobalData sharedInstance].currentVC = self;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    _memberList = [ModelManager sharedInstance].members.rows;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.navigationItem setHidesBackButton:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Defined Methods -
- (void)loadMemberControlPage:(MemberData *)member {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    MemberControlTableViewController *memberControlTVC = [sb instantiateViewControllerWithIdentifier:MEMBER_CONTROL_TVC_KEY];
    memberControlTVC.member = member;
    [self.navigationController pushViewController:memberControlTVC animated:YES];
}

- (void)loadMemberSignUpPage {

}

#pragma mark - Action Methods -
- (IBAction)signUpNewMember:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    MemberSignUpViewController *memberSignUpVC = [sb instantiateViewControllerWithIdentifier:MEMBER_SIGNUP_VIEW_CONTROLLER_KEY];
    [self.navigationController pushViewController:memberSignUpVC animated:YES];
}

#pragma mark tableview delegate methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _memberList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *memberCell = [tableView dequeueReusableCellWithIdentifier:@"MemberListCustomCell" /*MEMBER_CELL_IDENTIFIER_KEY*/];
    
    
    MemberListCustomCell *memberCell = (MemberListCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"MemberListCustomCell"];
    
    if (memberCell == nil) {
        memberCell = (MemberListCustomCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MENU_CELL_IDENTIFIER_KEY];
    }
    MemberData *member = [_memberList objectAtIndex:indexPath.row];
    NSString *fullName = @"";
    //---Set UserName or fullName---//
    if(([Common isNullObject:member.firstName] || member.firstName.length<1) && ([Common isNullObject:member.lastName] || member.lastName.length<1)) {
        fullName = member.userName;
    }else {
        if ([Common isNullObject:member.lastName] || member.lastName.length<1) {
            fullName = [NSString stringWithFormat:@"%@",member.firstName];
        }else {
            fullName = [NSString stringWithFormat:@"%@ %@",member.firstName, member.lastName];
        }
    }
    
    
    memberCell.memberName.text = fullName;
    if([member.role intValue] == 2) {
        [memberCell.guardianStatus setHidden:YES];
    }
    
    memberCell.memberProfileImage.layer.cornerRadius = memberCell.memberProfileImage.frame.size.width / 2;
   memberCell.memberProfileImage.layer.masksToBounds = YES;
    [self lazyImageLoader:member.profile_pic andImageView:memberCell.memberProfileImage];
    
    if(![member.isActive boolValue]) {
        [memberCell.activeInactiveStatusImage setImage:[UIImage imageNamed:@"Inactive-Sign"]];
    }
    
    /*
    [memberCell.textLabel setText:fullName];//@"পারিবারিক সদস্য"
    [memberCell.textLabel setFont:ROBOTOREGULAR(16)];
    if([member.role intValue] == 1) {
        [memberCell.imageView setImage:[UIImage imageNamed:@"User-Profile-Menu-Guardian"]];
    }else {
        [memberCell.imageView setImage:[UIImage imageNamed:USER_PROFILE_PLACEHOLDER]];
    }
    
//    NSString *gender = member.gender;
//    if(gender == nil || [gender isEqual:(id)[NSNull null]] || [gender isEqualToString:@""]) {
//        [memberCell.imageView setImage:[UIImage imageNamed:@"Men"]];
//    } else {
//        if([gender isEqualToString:@"Male"] || [gender isEqualToString:@"পুরুষ"]) {
//            [memberCell.imageView setImage:[UIImage imageNamed:@"Men"]];
//        } else if([gender isEqualToString:@"Female"] || [gender isEqualToString:@"মহিলা"]) {
//             [memberCell.imageView setImage:[UIImage imageNamed:@"Women"]];
//        }
//    }
    memberCell.backgroundColor = [UIColor clearColor];
    memberCell.selectionStyle = UITableViewCellSelectionStyleGray;
     */
    return memberCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     MemberData *member = [_memberList objectAtIndex:indexPath.row];
    [self loadMemberControlPage:member];
}


#pragma  - mark lazy image loder -
- (void)lazyImageLoader:(NSString*)imageUrl andImageView:(UIImageView* )imageView{
    if(imageUrl == nil) {
        return;
    }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            NSURL *imageURL = [NSURL URLWithString:imageUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithData:imageData];
                
            });
        });
}

@end
