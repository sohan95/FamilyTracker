//
//  HomeViewController.h
//  Family Tracker
//
//  Created by Zeeshan Khan on 11/14/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ChatManager.h"
#import "ChatLogin.h"
#import "OCMapView.h"
#import "CMPopTipView.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : BaseViewController <SMChatDelegate, MKMapViewDelegate,CMPopTipViewDelegate,CLLocationManagerDelegate>

//@property (nonatomic, weak) IBOutlet OCMapView *mapView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak,nonatomic) IBOutlet UIView *footerView;
@property (nonatomic,strong) ChatManager *chatManager;
@property (nonatomic,readwrite) NSMutableArray *annotationArray;
@property (nonatomic, weak) IBOutlet UIView *panicAlertViewBg;
@property (nonatomic, weak) IBOutlet UIView *panicAlertView;
@property (nonatomic, weak) IBOutlet UIView *panicAlertHeaderLbl;
@property (nonatomic, weak) IBOutlet UILabel *panicAlertTimerLabel;
@property (nonatomic, weak) IBOutlet UIButton *chatBtn;
@property (strong, nonatomic) IBOutlet UILabel *panicAlertHeaderText;
@property (strong, nonatomic) IBOutlet UIButton *panicAlertCancelActionOutlet;
@property (weak, nonatomic) IBOutlet UIButton *panicSendNowOutlet;
@property (weak, nonatomic) IBOutlet UIButton *popUpPanicInformationButton;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSTimer *timer;

- (IBAction)popUpPanicInformationAction:(id)sender;
- (IBAction)callBtnAction:(id)sender;
- (IBAction)nexArrowBtnAction:(id)sender;
- (IBAction)previousBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *previousView;
@property (weak, nonatomic) IBOutlet UIView *nextView;
- (IBAction)videoBtnAction:(id)sender;
- (IBAction)calendarBtnAction:(id)sender;
- (IBAction)memoriesBtnAction:(id)sender;
- (IBAction)musicBtnAction:(id)sender;

@end
