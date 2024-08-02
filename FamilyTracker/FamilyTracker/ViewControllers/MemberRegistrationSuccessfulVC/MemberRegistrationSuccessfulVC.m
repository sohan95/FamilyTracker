//
//  RegistrationSuccessfulViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 11/16/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "MemberRegistrationSuccessfulVC.h"
#import "FamilyMemberListViewController.h"
#import "FamilyTrackerDefine.h"
#import "MemberSignUpViewController.h"

@interface MemberRegistrationSuccessfulVC ()

@end

@implementation MemberRegistrationSuccessfulVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    [GlobalData sharedInstance].currentVC = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action Event -
- (IBAction)loadMemberControlBtnTapped {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    FamilyMemberListViewController *familyMemberListViewController = [sb instantiateViewControllerWithIdentifier:FAMILY_MEMBER_VIEW_CONTROLLER_KEY];
    [self.navigationController pushViewController:familyMemberListViewController animated:YES];
}

- (IBAction)loadNewMemberBtnTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
