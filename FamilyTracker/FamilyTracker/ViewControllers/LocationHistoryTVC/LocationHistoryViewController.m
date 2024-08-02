//
//  LocationHistoryViewController.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 1/2/17.
//  Copyright © 2017 SurroundApps. All rights reserved.
//

#import "LocationHistoryViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "MBProgressHUD.h"

@interface LocationHistoryViewController ()<MBProgressHUDDelegate,UIWebViewDelegate> {
    MBProgressHUD *loadingHud;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end

@implementation LocationHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self loadUIWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User Defined Methods -
- (void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

//This method should get called when you want to add and load the web view
- (void)loadUIWebView {
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_currentURL]]];
    [self.view addSubview:_webView];
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

#pragma mark - HUD Delegate -
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
