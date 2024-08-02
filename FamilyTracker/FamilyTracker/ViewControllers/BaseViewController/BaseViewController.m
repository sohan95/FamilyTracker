//
//  BaseViewController.m
//  OnTheMove
//
//  Created by Zeeshan Khan on 8/24/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "BaseViewController.h"
#import "HomeViewController.h"

@interface BaseViewController () {
    SWRevealViewController *revealController;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    revealController = [self revealViewController];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //[revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    //--- Left Home Btn---//
    UIBarButtonItem *leftRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HomeIcon"]
                                                                             style:UIBarButtonItemStylePlain target:self action:@selector(gotoHome)];
    
    self.navigationItem.leftBarButtonItem = leftRevealButtonItem;
    //self.navigationItem.leftBarButtonItem.image = [self.navigationItem.rightBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //--- Right Burger Btn---//
    UIBarButtonItem *rightRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:MENU_ICON]
                                                                              style:UIBarButtonItemStylePlain target:revealController action:@selector(rightRevealToggle:)];
    
    self.navigationItem.rightBarButtonItem = rightRevealButtonItem;
    self.navigationItem.rightBarButtonItem.image = [self.navigationItem.rightBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)gotoHome {
    UINavigationController *vc = (UINavigationController*)[revealController frontViewController];
    UIViewController *currentVC = [vc.viewControllers objectAtIndex:(0)];
    if (![currentVC isKindOfClass:[HomeViewController class]]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
        HomeViewController *homeViewController = [sb instantiateViewControllerWithIdentifier:HOME_VIEW_CONTROLLER_KEY];
        UINavigationController *newFrontController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        [revealController pushFrontViewController:newFrontController animated:YES];
    }
}

@end
