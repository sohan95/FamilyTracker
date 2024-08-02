//
//  PaymentViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 3/1/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "PaymentViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"


@interface PaymentViewController ()<MBProgressHUDDelegate> {
    NSTimer *alertTimer;
    MBProgressHUD *loadingHud;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, assign) BOOL isSuccess;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToPackageVc)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [HexToRGB colorForHex:COMMON_BACKGROUND_COLOR];
    leftBarBtnItem = nil;
    
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    NSURL *url = [NSURL URLWithString:_currentURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIWebViewDelegate Methods -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *currentURL = [[request URL]absoluteString];
    NSRange successRange = [currentURL rangeOfString:@"#/Success"];
    NSRange failedRange = [currentURL rangeOfString:@"#/Fail"];
    NSLog(@"First %@",currentURL);
    //---check success---//
    if (successRange.location == NSNotFound) {
    }else {
        _isSuccess = YES;
        NSLog(@"success: %@",currentURL);
        alertTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
        return YES;
    }
    //---check failed---//
    if (failedRange.location == NSNotFound) {
        //NSLog(@"Compare1: %@",currentURL);
    }else {
        _isSuccess = NO;
        NSLog(@"Fail: %@",currentURL);
        alertTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showAlert) userInfo:nil repeats:NO];
    }
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //---Start ProgressHUD & NetworkActivityIndicator---//
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    loadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHud.labelText = NSLocalizedString(LOADING_INFO_TEXT,nil);
    loadingHud.delegate = self;
    [loadingHud hide:YES afterDelay:10];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //---Stop ProgressHUD & NetworkActivityIndicator---//
    [loadingHud hide:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)showAlert {
    if (alertTimer) {
        [alertTimer invalidate];
        alertTimer = nil;
    }
    if (_isSuccess) {
        [self showAlertMessage:NSLocalizedString(@"Thank You",nil) message:NSLocalizedString(@"Your Payment has been Successful.",nil)];
    }else {
        [self showAlertMessage:NSLocalizedString(@"Sorry",nil) message:NSLocalizedString(@"Your Payment Failed!",nil)];
    }
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(DONE_BUTTON_TITLE_KEY,nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self goBackToHome];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self goBackToHome];
    }
}

- (IBAction)backToPackageVc {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBackToHome {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:MAIN_STORYBOARD_KEY bundle:nil];
    HomeViewController *homeViewController = [sb instantiateViewControllerWithIdentifier:HOME_VIEW_CONTROLLER_KEY];
    UINavigationController *newFrontController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [revealController pushFrontViewController:newFrontController animated:YES];
}

#pragma mark - HUD Delegate -
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
