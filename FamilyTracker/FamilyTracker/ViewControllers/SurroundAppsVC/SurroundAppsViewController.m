//
//  SurroundAppsViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/5/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "SurroundAppsViewController.h"
#import "FamilyTrackerDefine.h"

@interface SurroundAppsViewController ()

@end

@implementation SurroundAppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SURROUND_APPS_TITLE_TEXT;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalData sharedInstance].currentVC = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
