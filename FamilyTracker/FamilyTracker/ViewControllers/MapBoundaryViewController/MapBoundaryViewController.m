//
//  MapBoundaryViewController.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 3/22/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "MapBoundaryViewController.h"
#import "HexToRGB.h"
#import "FamilyTrackerDefine.h"
#import "CollectionViewCell.h"
#import "Algorithms.h"
#import "MemberBoundary.h"
#import "Boundary.h"
#import "BoundaryLocation.h"
#import "FamilyTrackerOperate.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
#import "SignupUpdater.h"
#import "Common.h"
#import "MBProgressHUD.h"
#import "EmergencyContactModel.h"
#import "DbHelper.h"
#import "FamilyTrackerReachibility.h"
#import "GlobalServiceManager.h"
#import "DXAnnotationMB.h"
#import "CallOutViewMB.h"
#import "MemberLocation.h"
#import "MemberLocations.h"
#import "MyAnnotation.h"
#import <AudioToolbox/AudioServices.h>
@interface MapBoundaryViewController ()<UITextFieldDelegate,MKMapViewDelegate,DataUpdater,UIGestureRecognizerDelegate> {
    MBProgressHUD *emergencyContactHud;
    ModelManager *_modelManager;
    ServiceHandler *_serviceHandler;
    Boundary *editBoundar;
    BOOL isUp;
    BOOL isEditMode;
    NSMutableArray * points;
    CLLocationCoordinate2D startPoint;
    BOOL isDraggingStart;
    CLLocationCoordinate2D draggingLeftPoint;
    CLLocationCoordinate2D draggingRightPoint;
    NSMutableArray * tempPoints;
    BOOL tempAnnotation;
    UIPanGestureRecognizer* dragReconizer;
    NSMutableArray *undoArray;
    CGPoint undoPoint;
    // for boundary tutorial
    int tutorialStep;
    BOOL tutorialMode;
    BOOL toggle;
    NSTimer *userInteractionTimer;
    BOOL isSaveBtnHidden,isCancelBtnHidden,isClearBtnHidden,isUndoBtnHidden;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *addressHideButtonOutlet;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHight;
@property (weak, nonatomic) IBOutlet UIButton *addBounaryButtonOutlet;
@property (nonatomic, strong) UIAlertAction *doneUIAlertButton;
@property (nonatomic, strong) UIBarButtonItem *rightDoneBarBtnItem;
@property (nonatomic, strong) UIBarButtonItem *rightCancelBarBtnItem;
@property (nonatomic, strong) NSMutableArray *addBoundaryPointArray;
@property (nonatomic, strong) NSString *boundaryName;
@property (nonatomic, strong) NSString *tempBoundaryName;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressReconginzer;//lpgr
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *boundaryClearButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *UndoButtonOutlet;
@property (strong,nonatomic) MemberBoundary * memberBoundary;
@property(nonatomic) int editMemberBoundaryIndex;
@property(nonatomic) int annotationIndex;
@property(nonatomic) int deleteCellIndex;
@property(nonatomic) int color_Code;
- (IBAction)addBoundaryButtonAction:(id)sender;
- (IBAction)addressHideButtonAction:(id)sender;
- (IBAction)UndoButtonAction:(id)sender;
- (IBAction)boundaryClearBottonAction:(id)sender;

// tooltips
@property (nonatomic, strong) id currentPopTipViewTarget;
@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (weak, nonatomic) IBOutlet UIButton *saveBtnOutlet;
- (IBAction)saveBtnActilon:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtnOutlet;
- (IBAction)cancelBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *tutorialView;
- (IBAction)gotItButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *gotItButtonOutlet;
@property (weak, nonatomic) IBOutlet UILabel *gotitLabel;
- (IBAction)neverShowMeAgainAction:(id)sender;
@property (nonatomic, assign) int timeCounter;
@end

static NSString *cellIdentifier = @"CollectionViewCell";
@implementation MapBoundaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelManager = [ModelManager sharedInstance];
    _modelManager.currentVCName = @"MapBoundaryViewController";
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:BACK_ICON] style:UIBarButtonItemStylePlain target:self action:@selector(backHomeVc)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    _rightDoneBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Draw",nil) style:UIBarButtonItemStylePlain target:self action:@selector(drawBoundaryAndServiceCall)];
    _rightCancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetSingleMapBondary)];
    NSArray *rightBarButtons = [NSArray arrayWithObjects:_rightDoneBarBtnItem,_rightCancelBarBtnItem, nil];
    //self.navigationItem.rightBarButtonItems = rightBarButtons;
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //hide right button
//    _tableView.backgroundColor = [UIColor clearColor];
    [self hideRightBarButton];
    [self setDefaultView];
    [self setDefaultMapConfig];
    [self initService];
    [self setTitle:_memberName];
    [self timerStart];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kDrawBoundaryTutorial]) {
        [self showDrawBoundayTutorialMessage];
        tutorialStep = 0;
        [self timerStop];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetMapView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self dismissAllPopTipViews];
    if(userInteractionTimer) {
        [userInteractionTimer invalidate];
        userInteractionTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Service Call Method -
- (void)initService {
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
    [self getBoundaryService];
}

#pragma mark - User Defined Methods -
-(void)setDefaultView {
    self.visiblePopTipViews = [NSMutableArray array];
    [_tutorialView setHidden:YES];
    [_boundaryClearButtonOutlet setHidden:YES];
    [_UndoButtonOutlet setHidden:YES];
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    self.addressHideButtonOutlet.layer.cornerRadius = self.addressHideButtonOutlet.frame.size.width / 2;
    self.addressHideButtonOutlet.layer.masksToBounds = YES;
    self.addBounaryButtonOutlet.layer.cornerRadius = self.addBounaryButtonOutlet.frame.size.width / 2;
    self.addBounaryButtonOutlet.layer.masksToBounds = YES;
    isUp = YES;
    isEditMode = NO;
    _memberBoundary = [[MemberBoundary alloc] init];
    [self timerStart];
}

- (void)setDefaultMapConfig {
    _mapView.delegate = self;
    _mapView.showsUserLocation = NO;
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = _lat;
    ctrpoint.longitude = _lon;
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(ctrpoint, 1000, 1000)];
    _longPressReconginzer = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(singleTapdrawMapMarkerPin:)];
    _longPressReconginzer.minimumPressDuration = 0.1; //user needs to press for 1 seconds
    [self.mapView addGestureRecognizer:_longPressReconginzer];
     dragReconizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [dragReconizer setDelegate:self];
    [self.mapView addGestureRecognizer:dragReconizer];
    [dragReconizer setEnabled:NO];
    [self addMemberPositonOnMap];
}

- (void)addMemberPositonOnMap {
    DXAnnotationMB *annotation = [DXAnnotationMB new];
    [annotation setCoordinate:CLLocationCoordinate2DMake(_lat, _lon)];
    annotation.title = @"MemberPositionOnBoundary";
    annotation.index = kMemberIndexOnBoundary;
    annotation.intArrayIndex = kMemberIndexOnBoundary;
    [self.mapView addAnnotation:annotation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)backHomeVc {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewMapBoundary:(NSMutableArray *)boundaryPointArray andAddServiceCall:(BOOL)isAddServiceCall boundayIndex:(int)boundaryIndex andPolygonColor:(int)colorCode{
    [self timerStart];
    NSLog(@"addNewMapBoundary");
    _color_Code = colorCode;
    // here draw polygone
    NSMutableArray * polyGonPoints = [[NSMutableArray alloc] init];
//    polyGonPoints = [Algorithms convexHullAlgorithm:boundaryPointArray andSize:(int)boundaryPointArray.count];
    polyGonPoints = [boundaryPointArray copy];
    int totalPoint = (int)polyGonPoints.count;
    CLLocationCoordinate2D overflowLotCoords[totalPoint]; // store for overlay draw
    for(int i = 0; i < polyGonPoints.count; i++) {
        NSValue *val = [polyGonPoints objectAtIndex:i];
        CGPoint point = [val CGPointValue];
        overflowLotCoords[i] = CLLocationCoordinate2DMake(point.x,point.y);
    }
    MKPolygon *polLibcomPark = [MKPolygon polygonWithCoordinates:overflowLotCoords count:polyGonPoints.count];
    [polLibcomPark setTitle:[NSString stringWithFormat:@"%d",boundaryIndex]];
    [_mapView addOverlay:polLibcomPark];
    if(_color_Code == 3)
        return;
    NSString *st = _rightDoneBarBtnItem.title;
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    [self hideRightBarButton];
    _longPressReconginzer.enabled = NO;
    [_boundaryClearButtonOutlet setHidden:YES];
    [_UndoButtonOutlet setHidden:YES];
    //----show addMapButon----
    [_addBounaryButtonOutlet setHidden:NO];
    if(isAddServiceCall) {
        if(st.length >0 && ([st isEqualToString:@"Draw"] || [st isEqualToString:@"আঁকা"])) {
            [self addBoundaryService:polyGonPoints];
        }else {
            [self updateBounaryService:polyGonPoints andArrayIndex:_editMemberBoundaryIndex];
            _editMemberBoundaryIndex = 0;
        }
    }
}

-(void)calculatePopUpViewHeight {
    if(_memberBoundary.boundaryArray.count == 0) {
        _bottomViewHight.constant = 60.0f;
    }else if(_memberBoundary.boundaryArray.count<4){
        _bottomViewHight.constant = 47.0f*(float)_memberBoundary.boundaryArray.count + 60.0f;
    } else {
        _bottomViewHight.constant = 190.f;
    }
}

- (void)deleteCell:(int)index{
    [self timerStart];
        UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want to remove this bounary?",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Yes",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self deleteBoundaryService:index];
                                       _deleteCellIndex = index;
                                       [self timerStart];
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"No",nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self timerStart];
                                       }];
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
}

- (void)bounaryNameOkay:(NSString *)bounaryName {
    _boundaryName = bounaryName;
    _tempBoundaryName = bounaryName;
    _longPressReconginzer.enabled = YES;
    [_addBounaryButtonOutlet setHidden:YES];
    [self resetMapView]; // reset mpaView
    if(isUp){
    [self addressHideButtonAction:nil];
    }
    [self showRightBarButton];
    if(tutorialMode) {
        [self boudnaryTutorial];
    }
}

-(void)hideRightBarButton {
    _rightDoneBarBtnItem.title = NSLocalizedString(@"Draw", nil);
    [_rightDoneBarBtnItem setEnabled:NO];
    [_rightDoneBarBtnItem setTintColor: [UIColor clearColor]];
    [_rightCancelBarBtnItem setEnabled:NO];
    [_rightCancelBarBtnItem setTintColor: [UIColor clearColor]];
    [_saveBtnOutlet setHidden:YES];
    [_cancelBtnOutlet setHidden:YES];
}

- (void)showRightBarButton {
    _rightDoneBarBtnItem.title = NSLocalizedString(@"Draw", nil);
    [_rightDoneBarBtnItem setEnabled:YES];
    [_rightDoneBarBtnItem setTintColor:nil];
    [_rightCancelBarBtnItem setEnabled:YES];
    [_rightCancelBarBtnItem setTintColor:nil];
    [_saveBtnOutlet setHidden:NO];
    [_cancelBtnOutlet setHidden:NO];
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

-(void)setAnnotaionAndOverlay {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    CLLocationCoordinate2D overflowLotCoords[[points count]];
    for(int i = 0; i<[points count]; i++) {
        NSValue *val = [points objectAtIndex:i];
        CGPoint xy = [val CGPointValue];
        overflowLotCoords[i] = CLLocationCoordinate2DMake(xy.x,xy.y);
        MyAnnotation * ads = [[MyAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(xy.x,xy.y)];
        //        ads.title = [NSString stringWithFormat:@"%d",i];
        ads.title = @"Remove";
        ads.index = i;
        if([[tempPoints objectAtIndex:i] isEqualToString:@"0"]) { // 0 = mid point
            ads.isTempAnnotation = 1;
        } else {
            ads.isTempAnnotation = 0;
        }
        [_mapView addAnnotation:ads];
    }
    MKPolygon *polLibcomPark = [MKPolygon polygonWithCoordinates:overflowLotCoords count:[points count]];
    [_mapView addOverlay:polLibcomPark];
}

-(void)getBounaryName {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString( @"Set boundary name",nil) message: @""preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"enter your boundary name",nil);
        textField.textColor = [UIColor blueColor];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate = self;
    }];
    self.doneUIAlertButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                        NSArray * textfields = alertController.textFields;
                                        UITextField * bounaryNameField = textfields[0];
                                        [self bounaryNameOkay:bounaryNameField.text];
                                        if (tutorialMode) {
                                            [self dismissAllPopTipViews];
                                            [_tutorialView setHidden:NO];
                                            [_boundaryClearButtonOutlet setHidden:NO];
                                            [_UndoButtonOutlet setHidden:NO];
                                            isClearBtnHidden = YES;
                                            isUndoBtnHidden = YES;
                                             [self labelZoomIn];
                                        }
                                }];
    self.doneUIAlertButton.enabled = NO;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [alertController addAction:self.doneUIAlertButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)labelZoomIn {
    _gotitLabel.transform = CGAffineTransformScale(_gotitLabel.transform, 1, 1);
    [UIView animateWithDuration:1.0
                     animations:^{
                         _gotitLabel.transform = CGAffineTransformScale(_gotitLabel.transform, 2, 2);
                     }
                     completion:^(BOOL finished){
                         [self labelZoomOut];
                     }];
}

- (void)labelZoomOut {
    _gotitLabel.transform = CGAffineTransformScale(_gotitLabel.transform, 1, 1);
    [UIView animateWithDuration:1.0
                     animations:^{
                         _gotitLabel.transform = CGAffineTransformScale(_gotitLabel.transform, 0.5, 0.5);
                     }
                     completion:^(BOOL finished){
                         [self labelZoomIn];
                     }];
}

- (void)pulseScaleAnim {
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 0.5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.2];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    [_addBounaryButtonOutlet.layer addAnimation:pulseAnimation forKey:nil];
}

#pragma mark - draw boundary tutorial
- (void)showDrawBoundayTutorialMessage {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"Boundary Set Tutorial", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *continueAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Continue", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         tutorialMode = YES;
                                         [self boudnaryTutorial];
                                     }];
    UIAlertAction *skipAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Skip", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     [self timerStart];
                                 }];
    [alertController addAction:continueAction];
    [alertController addAction:skipAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma - mark toolTips start
- (void)dismissAllPopTipViews {
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}

#pragma mark - CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}

#pragma mark - UIViewController methods
- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
    for (CMPopTipView *popTipView in self.visiblePopTipViews) {
        id targetObject = popTipView.targetObject;
        [popTipView dismissAnimated:NO];
        if ([targetObject isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)targetObject;
            [popTipView presentPointingAtView:button inView:self.view animated:NO];
        }
        else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
        }
    }
}

-(void)boudnaryTutorial {
    //    [_skipTutorialBtnOutlet setHidden:NO];
    if(tutorialStep == 0) {
        [self showBundaryTutorial:_addBounaryButtonOutlet andMessage:NSLocalizedString(@"Create a boundary,Click here",nil) isBarButton:NO];
        tutorialStep++;
        [self pulseScaleAnim];
    }
}

-(void)showBundaryTutorial:(id)uIView andMessage:(NSString *)message isBarButton:(BOOL)isBarButton{
    
    [self dismissAllPopTipViews];
    NSString *contentMessage = nil;
    contentMessage = message;
    UIColor *backgroundColor = [UIColor blackColor];
    UIColor *textColor =[UIColor whiteColor];
    CMPopTipView *popTipView;
    popTipView = [[CMPopTipView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"  %@  ",contentMessage]];
    popTipView.delegate = self;
    if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
        popTipView.backgroundColor = backgroundColor;
    }
    if (textColor && ![textColor isEqual:[NSNull null]]) {
        popTipView.textColor = textColor;
        popTipView.textAlignment = NSTextAlignmentCenter;
    }
    
    popTipView.animation = arc4random() % 2;
    popTipView.has3DStyle = (BOOL)(arc4random() % 2);
    if(isBarButton) {
        [popTipView presentPointingAtBarButtonItem:uIView animated:YES];
    } else {
        [popTipView presentPointingAtView:uIView inView:self.view animated:YES];
    }
    [self.visiblePopTipViews addObject:popTipView];
    self.currentPopTipViewTarget = uIView;
}

#pragma mark - center point of polygon -
-(CGPoint)polygonCenterPoint:(NSMutableArray *)vertices {
    double x1 = 1000.0;
    double y1 = 1000.0;
    double x2 = 0.0;
    double y2 = 0.0;
    for (int i=0; i<vertices.count; i++)
    {
        CGPoint val = [[vertices objectAtIndex:i] CGPointValue];
        if(val.x < x1) // find min x position value
            x1 = val.x;
        if(val.y < y1) // find min y position value
            y1 = val.y;
        if(val.x > x2) // find max x position value
            x2 = val.x;
        if(val.y > y2) // find max y position value
            y2 = val.y;
    }
    CGPoint center = CGPointMake(x1 + ((x2 - x1) / 2),y1 + ((y2 - y1) / 2));
    return center;
}

#pragma - mark UIGesterReconginzer
- (void)singleTapdrawMapMarkerPin:(UIGestureRecognizer *)gestureRecognizer
{
    if(_boundaryName.length == 0)
        return;
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    [self timerStart];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // previous state back start
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    NSMutableArray *trArray = [[NSMutableArray alloc] init];
    for (id annotation in _mapView.annotations) {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
        NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.latitude] forKey:@"lat"];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.longitude] forKey:@"long"];
        [array setObject:subDic forKey:[NSString stringWithFormat:@"%d",dxAnnotation.index]];
        [trArray addObject:[NSNumber numberWithInt:dxAnnotation.index]];
    }
    NSArray *sorted = [trArray sortedArrayUsingSelector:@selector(compare:)];
    for(int i =0; i<[sorted count];i++) {
        NSString * key = [[sorted objectAtIndex:i] stringValue];
        NSMutableDictionary  *dictionary = (NSMutableDictionary *) [array valueForKey:key];
        NSString * lat = [dictionary valueForKey:@"lat"];
        NSLog(@"%@",lat);
        [tempArray addObject:[NSValue valueWithCGPoint:CGPointMake([[dictionary valueForKey:@"lat"] doubleValue],[[dictionary valueForKey:@"long"] doubleValue])]];
    }
    undoArray = [[NSMutableArray alloc] init];
    undoArray = [tempArray copy];
    // previous state back end
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(touchMapCoordinate.latitude,touchMapCoordinate.longitude)]];
    DXAnnotationMB *annotation = [DXAnnotationMB new];
    [annotation setCoordinate:touchMapCoordinate];
    annotation.title = editBoundar.boundary_name;
    annotation.index = _annotationIndex;
    annotation.intArrayIndex = (int)_addBoundaryPointArray.count;
    [self.mapView addAnnotation:annotation];
    _annotationIndex++;
    if([_UndoButtonOutlet isHidden]) {
        [_UndoButtonOutlet setHidden:NO];
        [_boundaryClearButtonOutlet setHidden:NO];
    }
    if(tutorialMode) {
        [self boudnaryTutorial];
    }
}

#pragma mark - mapView Drager delegate
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    [self timerStart];
    // if MKAnnotationViewDragStateDragging
    if(newState == MKAnnotationViewDragStateDragging) {
        if (newState == MKAnnotationViewDragStateDragging) {
            CLLocationCoordinate2D location = [_mapView convertPoint:annotationView.center toCoordinateFromView:annotationView.superview];
//            NSLog(@"%f",location.latitude);
        }
    }
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        CLLocationCoordinate2D coordinate;
        coordinate.latitude =droppedAt.latitude;
        coordinate.longitude = droppedAt.longitude;
        NSMutableArray  *mapPoint  = [[NSMutableArray alloc] init];
        NSMutableArray  *mapPoint_temp  = [[NSMutableArray alloc] init];
        for(int i = 0; i<[points count]; i++) {
            NSValue *val = [points objectAtIndex:i];
            CGPoint xy = [val CGPointValue];
            if(xy.x == startPoint.latitude && xy.y == startPoint.longitude) {
                //right point push up
                NSValue *val;
                CGPoint val_r;
                CGPoint val_l;
                if(i == 0) {
                    val = [points objectAtIndex:[points count]-1];
                    val_r = [val CGPointValue];
                    val = [points objectAtIndex:1];
                    val_l = [val CGPointValue];
                }else if(i == [points count]-1) {
                    val = [points objectAtIndex:[points count]-2];
                    val_r = [val CGPointValue];
                    val = [points objectAtIndex:0];
                    val_l = [val CGPointValue];
                } else {
                    val = [points objectAtIndex:i - 1];
                    val_r = [val CGPointValue];
                    val = [points objectAtIndex:i + 1];
                    val_l = [val CGPointValue];
                }
                
                CGPoint rightPoint;
                rightPoint.x = (val_r.x+droppedAt.latitude)/2.0;
                rightPoint.y =(val_r.y+droppedAt.longitude)/2.0;
                CGPoint leftPoint;
                leftPoint.x = (val_l.x+droppedAt.latitude)/2.0;
                leftPoint.y =(val_l.y+droppedAt.longitude)/2.0;
                if(tempAnnotation) {
                    [mapPoint addObject:[NSValue valueWithCGPoint:CGPointMake(rightPoint.x,rightPoint.y)]];
                    [mapPoint_temp addObject:@"0"];
                    [mapPoint addObject:[NSValue valueWithCGPoint:CGPointMake(droppedAt.latitude,droppedAt.longitude)]];
                    [mapPoint_temp addObject:@"1"];
                    [mapPoint addObject:[NSValue valueWithCGPoint:CGPointMake(leftPoint.x,leftPoint.y)]];
                    [mapPoint_temp addObject:@"0"];
                } else {
                    [mapPoint addObject:[NSValue valueWithCGPoint:CGPointMake(droppedAt.latitude,droppedAt.longitude)]];
                    [mapPoint_temp addObject:@"1"];
                }
            } else {
                [mapPoint addObject:[points objectAtIndex:i]];
                if([[tempPoints objectAtIndex:i] isEqualToString:@"1"]) {
                    [mapPoint_temp addObject:@"1"];
                } else {
                    [mapPoint_temp addObject:@"0"];
                }
            }
        }
        points = [[NSMutableArray alloc] init];
        tempPoints  = [[NSMutableArray alloc] init];
        tempPoints = [mapPoint_temp copy];
        points = [mapPoint copy];
        [self setAnnotaionAndOverlay];
        tempAnnotation = NO;
    }
    if (newState == MKAnnotationViewDragStateStarting)
    {
        isDraggingStart = YES;
        MyAnnotation * myAnnotation = (MyAnnotation *)annotationView.annotation;
        if(myAnnotation.isTempAnnotation == 1){
            tempAnnotation = YES;
        } else {
            tempAnnotation = NO;
        }
        startPoint = annotationView.annotation.coordinate;
        for(int i = 0; i<[points count]; i++) {
            NSValue *val = [points objectAtIndex:i];
            CGPoint xy = [val CGPointValue];
            if(xy.x == startPoint.latitude && xy.y == startPoint.longitude) {
                if(i == 0) {
                    NSValue *val_L = [points objectAtIndex:1];
                    CGPoint xy_L = [val_L CGPointValue];
                    draggingLeftPoint.latitude = xy_L.x;
                    draggingLeftPoint.longitude = xy_L.y;
                    NSValue *val_R = [points objectAtIndex:[points count]-1];
                    CGPoint xy_R = [val_R CGPointValue];
                    draggingRightPoint.latitude = xy_R.x;
                    draggingRightPoint.longitude = xy_R.y;
                } else if(i+1 == [points count]) {
                    NSValue *val_L = [points objectAtIndex:0];
                    CGPoint xy_L = [val_L CGPointValue];
                    draggingLeftPoint.latitude = xy_L.x;
                    draggingLeftPoint.longitude = xy_L.y;
                    NSValue *val_R = [points objectAtIndex:[points count]-2];
                    CGPoint xy_R = [val_R CGPointValue];
                    draggingRightPoint.latitude = xy_R.x;
                    draggingRightPoint.longitude = xy_R.y;
                } else {
                    NSValue *val_L = [points objectAtIndex:i+1];
                    CGPoint xy_L = [val_L CGPointValue];
                    draggingLeftPoint.latitude = xy_L.x;
                    draggingLeftPoint.longitude = xy_L.y;
                    NSValue *val_R = [points objectAtIndex:i-1];
                    CGPoint xy_R = [val_R CGPointValue];
                    draggingRightPoint.latitude = xy_R.x;
                    draggingRightPoint.longitude = xy_R.y;
                }
                break;
            }
        }
    }
}

#pragma mark - drag and drop -
- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    [self timerStart];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        isDraggingStart = NO;
    }
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged && isDraggingStart) {
        for (id<MKOverlay> overlayToRemove in _mapView.overlays)
        {
            NSString * st = overlayToRemove.title;
            if([st isEqualToString:@"title"]) {
                [_mapView removeOverlay:overlayToRemove];
            }
        }
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocationCoordinate2D coordinates[3];
        coordinates[0] = draggingLeftPoint;
        coordinates[1] = touchMapCoordinate;
        coordinates[2] = draggingRightPoint;
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:3];
        polyline.title = @"title";
        [self.mapView addOverlay:polyline];
    }
}

#pragma mark - button Action -
- (IBAction)addressHideButtonAction:(id)sender {
    if(isUp) {
        _bottomViewHight.constant = 55.0f;
        isUp = NO;
       [sender setImage:[UIImage imageNamed:@"upArrow"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"downArrow"] forState:UIControlStateNormal];
        [self calculatePopUpViewHeight];
        isUp = YES;
    }
}

- (IBAction)addBoundaryButtonAction:(id)sender {
    if(tutorialMode) {
        [_addBounaryButtonOutlet.layer removeAllAnimations];
        [self dismissAllPopTipViews];
    }
    if(!tutorialMode) {
        [self timerStart];
    }
    [_mapView removeAnnotations:_mapView.annotations];
    _annotationIndex = 0;
    _boundaryName = @"";
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    [self getBounaryName];
}

- (void)editMapBoundary:(UIButton *)sender {
    [self timerStart];
    _editMemberBoundaryIndex = (int)sender.tag;
    [self resetMapView];
    [_addBounaryButtonOutlet setHidden:YES];
    [_UndoButtonOutlet setHidden:YES];
    [_boundaryClearButtonOutlet setHidden:YES];
    _rightDoneBarBtnItem.title = NSLocalizedString(@"Update", nil);
    [_rightDoneBarBtnItem setEnabled:YES];
    [_rightDoneBarBtnItem setTintColor:nil];
    [_rightCancelBarBtnItem setEnabled:YES];
    [_rightCancelBarBtnItem setTintColor:nil];
    [self showRightBarButton];
    if(isUp) {
        [self addressHideButtonAction:nil];
    }
    isEditMode = YES;
    points = [[NSMutableArray alloc] init];
    editBoundar = [[Boundary alloc] init];
    editBoundar = [[_memberBoundary.boundaryArray objectAtIndex:(int)sender.tag] copy];
    _boundaryName = editBoundar.boundary_name;
    _annotationIndex = 0;
    NSMutableArray *allpoint = [[NSMutableArray alloc] init];
    for(SubBoundary *subBoundaryRow in editBoundar.subBoundaryArray) {
        BoundaryLocation * location = subBoundaryRow.location;
        [allpoint addObject:[NSValue valueWithCGPoint:CGPointMake(location.lat,location.log)]];
    }
    points = [allpoint copy];
    NSMutableArray * tpoints = [[NSMutableArray alloc] init];
    tempPoints = [[NSMutableArray alloc] init];
    for(int i =0 ; i<[points count]; i++) {
        NSValue * val_o =[points objectAtIndex:i];
        CGPoint xy_o = [val_o CGPointValue];
        [tpoints addObject:[points objectAtIndex:i]];
        [tempPoints addObject:@"1"]; // original point
        NSValue *val;
        CGPoint xy; // next point
        if(i!= [points count]-1) {
            val = [points objectAtIndex:i+1];
            xy = [val CGPointValue];
        } else {
            val = [points objectAtIndex:0];
            xy = [val CGPointValue];
        }
        CGPoint centerPoint = CGPointMake((xy_o.x+xy.x)/2.0,(xy_o.y+xy.y)/2.0);
        [tpoints addObject:[NSValue valueWithCGPoint:CGPointMake(centerPoint.x,centerPoint.y)]]; // add mid point
        [tempPoints addObject:@"0"]; // mid point bewteen two point
    }
    points = [[NSMutableArray alloc] init];
    points = [tpoints copy];
    [self setAnnotaionAndOverlay];
    [dragReconizer setEnabled:YES];
    CGPoint point = [self polygonCenterPoint:allpoint];
    [self focusSingleBoundary:point.x andLog:point.y];
}

- (void)deleteMapBoundary:(UIButton *)sender {
    [self cancelBtnAction:nil];
    [self deleteCell:(int)sender.tag];
}

- (IBAction)boundaryClearBottonAction:(id)sender {
    [self timerStart];
    // clear all points start
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    NSMutableArray *trArray = [[NSMutableArray alloc] init];
    for (id annotation in _mapView.annotations)
    {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
        [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(dxAnnotation.coordinate.latitude,dxAnnotation.coordinate.longitude)]];
        NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.latitude] forKey:@"lat"];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.longitude] forKey:@"long"];
        [array setObject:subDic forKey:[NSString stringWithFormat:@"%d",dxAnnotation.index]];
        [trArray addObject:[NSNumber numberWithInt:dxAnnotation.index]];
    }
    NSArray *sorted = [trArray sortedArrayUsingSelector:@selector(compare:)];
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    for(int i =0; i<[sorted count];i++) {
        NSString * key = [[sorted objectAtIndex:i] stringValue];
        NSMutableDictionary  *dictionary = (NSMutableDictionary *) [array valueForKey:key];
        [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake([[dictionary valueForKey:@"lat"] doubleValue],[[dictionary valueForKey:@"long"] doubleValue])]];
    }
        undoArray = [[NSMutableArray alloc] init];
        undoArray = [_addBoundaryPointArray copy];
        _addBoundaryPointArray = [[NSMutableArray alloc] init];
        [_mapView removeAnnotations:_mapView.annotations];
     // clear all points end
}

- (void)drawBoundaryAndServiceCall {
    if(tutorialMode) {
        [self dismissAllPopTipViews];
    }
    if(!isEditMode) {
//        _addBoundaryPointArray = [[NSMutableArray alloc] init];//sohan
        NSMutableDictionary * array = [[NSMutableDictionary alloc] init]; // store lat and long
        NSMutableArray *trArray = [[NSMutableArray alloc] init]; // store annotation index
        for (id annotation in _mapView.annotations) {
            DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
            if(dxAnnotation.index != kMemberIndexOnBoundary) { // kMemberIndexOnBoundary = User Position
               //[_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(dxAnnotation.coordinate.latitude,dxAnnotation.coordinate.longitude)]];//sohan
                NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
                [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.latitude] forKey:@"lat"];
                [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.longitude] forKey:@"long"];
                [array setObject:subDic forKey:[NSString stringWithFormat:@"%d",dxAnnotation.index]];
                [trArray addObject:[NSNumber numberWithInt:dxAnnotation.index]];
            }
        }
        NSArray *sorted = [trArray sortedArrayUsingSelector:@selector(compare:)];
        if([sorted count] < 3) {
            [self showAlertMessage:nil message:NSLocalizedString(@"add three points at least", nil)];
            return;
        }
        _addBoundaryPointArray = [[NSMutableArray alloc] init]; // store for draw overlay
        for(int i =0; i<[sorted count];i++) {
            NSString * key = [[sorted objectAtIndex:i] stringValue];
           NSMutableDictionary  *dictionary = (NSMutableDictionary *) [array valueForKey:key];
            [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake([[dictionary valueForKey:@"lat"] doubleValue],[[dictionary valueForKey:@"long"] doubleValue])]];
        }
        [self addNewMapBoundary:_addBoundaryPointArray andAddServiceCall:YES boundayIndex:0 andPolygonColor:1];
    } else {
        NSMutableArray * pointFilterArray = [[NSMutableArray alloc] init];
        for(int i = 0; i< [points count]; i++) {
            if([[tempPoints objectAtIndex:i] isEqualToString:@"1"]) {
                [pointFilterArray addObject:[points objectAtIndex:i]];
            }
        }
        points = [[NSMutableArray alloc] init];
        tempPoints = [[NSMutableArray alloc] init];
         [self updateBounaryService:pointFilterArray andArrayIndex:_editMemberBoundaryIndex];
    }
    [dragReconizer setEnabled:NO];
    isEditMode = NO;
}

-(void)resetSingleMapBondary {
    NSLog(@"resetSingleMapBondary");
    _addBoundaryPointArray = [[NSMutableArray alloc] init];
    [self hideRightBarButton]; // hide right bar button
    _boundaryName = @""; // reset boundary name
    _longPressReconginzer.enabled = NO; // disable UIGestureRecognizer
    isUp = YES; // upAddressView
    [self resetMapView];
    isEditMode = NO; //
    [dragReconizer setEnabled:NO];
    [self drawBoundaryInMapView:-1];
    [_tableView reloadData];
    [_addBounaryButtonOutlet setHidden:NO];
    [_UndoButtonOutlet setHidden:YES];
    [_boundaryClearButtonOutlet setHidden:YES];
}

- (IBAction)removeBoundaryAnnotaion:(UIButton *)sender {
    [self timerStart];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    NSMutableArray *trArray = [[NSMutableArray alloc] init];
    for (id annotation in _mapView.annotations)
    {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
        [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(dxAnnotation.coordinate.latitude,dxAnnotation.coordinate.longitude)]];
        NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.latitude] forKey:@"lat"];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.longitude] forKey:@"long"];
        [array setObject:subDic forKey:[NSString stringWithFormat:@"%d",dxAnnotation.index]];
        [trArray addObject:[NSNumber numberWithInt:dxAnnotation.index]];
    }
    NSArray *sorted = [trArray sortedArrayUsingSelector:@selector(compare:)];
    for(int i =0; i<[sorted count];i++) {
        NSString * key = [[sorted objectAtIndex:i] stringValue];
        NSMutableDictionary  *dictionary = (NSMutableDictionary *) [array valueForKey:key];
        NSString * lat = [dictionary valueForKey:@"lat"];
        NSLog(@"%@",lat);
        [tempArray addObject:[NSValue valueWithCGPoint:CGPointMake([[dictionary valueForKey:@"lat"] doubleValue],[[dictionary valueForKey:@"long"] doubleValue])]];
    }
    undoArray = [[NSMutableArray alloc] init];
    undoArray = [tempArray copy];
    for (id annotation in _mapView.annotations)
    {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
        NSLog(@"annotation index=%d",dxAnnotation.index);
        if(dxAnnotation.index == (int)sender.tag) {
            [self.mapView removeAnnotation:annotation];
        }
    }
}

- (IBAction)mapBtnTapped:(id)sender {
    [self timerStart];
    int originalAnnotaionCount = 0;
    for(int i = 0; i<[points count]; i++) {
            if([[tempPoints objectAtIndex:i] isEqualToString:@"0"]) {
                originalAnnotaionCount++;
        }
    }
    if(originalAnnotaionCount<=3) {
        [self showAlertMessage:nil message:NSLocalizedString(@"You can not remove less than threee points",nil)];
        return;
    }
    int index = (int)[sender tag];
    NSMutableArray * annotaionPointsArray = [[NSMutableArray alloc] init];
    for(int i = 0; i<[points count]; i++) {
        if(i!= index) {
            if([[tempPoints objectAtIndex:i] isEqualToString:@"1"]) {
                [annotaionPointsArray addObject:[points objectAtIndex:i]];
            }
        }
    }
    points = [annotaionPointsArray copy];
    NSMutableArray * tpoints = [[NSMutableArray alloc] init];
    tempPoints = [[NSMutableArray alloc] init];
    for(int i =0 ; i<[points count]; i++) {
        NSValue * val_o =[points objectAtIndex:i];
        CGPoint xy_o = [val_o CGPointValue];
        [tpoints addObject:[points objectAtIndex:i]];
        [tempPoints addObject:@"1"];
        NSValue *val;
        CGPoint xy;
        if(i!= [points count]-1) {
            val = [points objectAtIndex:i+1];
            xy = [val CGPointValue];
        } else {
            val = [points objectAtIndex:0];
            xy = [val CGPointValue];
        }
        CGPoint centerPoint = CGPointMake((xy_o.x+xy.x)/2.0,(xy_o.y+xy.y)/2.0);
        [tpoints addObject:[NSValue valueWithCGPoint:CGPointMake(centerPoint.x,centerPoint.y)]];
        [tempPoints addObject:@"0"];
    }
    points = [[NSMutableArray alloc] init];
    points = [tpoints copy];
    tpoints = [[NSMutableArray alloc] init];
    [self setAnnotaionAndOverlay];
}

- (IBAction)UndoButtonAction:(id)sender {
    [self timerStart];
    // previous state back start
    NSMutableArray *previousState = [[NSMutableArray alloc] init];
    NSMutableDictionary * array = [[NSMutableDictionary alloc] init];
    NSMutableArray *trArray = [[NSMutableArray alloc] init];
    for (id annotation in _mapView.annotations)
    {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)annotation;
        NSMutableDictionary * subDic = [[NSMutableDictionary alloc] init];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.latitude] forKey:@"lat"];
        [subDic setValue:[NSString stringWithFormat:@"%f",dxAnnotation.coordinate.longitude] forKey:@"long"];
        [array setObject:subDic forKey:[NSString stringWithFormat:@"%d",dxAnnotation.index]];
        [trArray addObject:[NSNumber numberWithInt:dxAnnotation.index]];
    }
    NSArray *sorted = [trArray sortedArrayUsingSelector:@selector(compare:)];
    for(int i =0; i<[sorted count];i++) {
        NSString * key = [[sorted objectAtIndex:i] stringValue];
        NSMutableDictionary  *dictionary = (NSMutableDictionary *) [array valueForKey:key];
        NSString * lat = [dictionary valueForKey:@"lat"];
        NSLog(@"%@",lat);
        
        [previousState addObject:[NSValue valueWithCGPoint:CGPointMake([[dictionary valueForKey:@"lat"] doubleValue],[[dictionary valueForKey:@"long"] doubleValue])]];
    }
    // previous state back end
    if([undoArray count]>0) {
        [_mapView removeAnnotations:_mapView.annotations];
        _addBoundaryPointArray = [[NSMutableArray alloc] init];
        _annotationIndex = 0;
        for(int i = 0; i<[undoArray count]; i++) {
            NSValue *val = [undoArray objectAtIndex:i];
            CGPoint point = [val CGPointValue];
            [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(point.x,point.y)]];
            DXAnnotationMB *annotation = [DXAnnotationMB new];
            [annotation setCoordinate:CLLocationCoordinate2DMake(point.x, point.y)];
            annotation.title = editBoundar.boundary_name;
            annotation.index = _annotationIndex;
            annotation.intArrayIndex = (int)_addBoundaryPointArray.count;
            [self.mapView addAnnotation:annotation];
            _annotationIndex++;
        }
    } else {
    }
    undoArray = [[NSMutableArray alloc] init];
    undoArray = [previousState copy];
}

- (IBAction)gotItButtonAction:(id)sender {
    [_tutorialView setHidden:YES];
    if(isUndoBtnHidden) {
        [_UndoButtonOutlet setHidden:YES];
    }
    if(isClearBtnHidden) {
        [_boundaryClearButtonOutlet setHidden:YES];
    }
    if(isSaveBtnHidden) {
        [_saveBtnOutlet setHidden:YES];
    }
    if(isCancelBtnHidden) {
        [_cancelBtnOutlet setHidden:YES];
    }
    tutorialMode = NO;
    isSaveBtnHidden = NO;
    isCancelBtnHidden = NO;
    isClearBtnHidden = NO;
    isUndoBtnHidden = NO;
    [self timerStart];
}
- (void)labelTapped:(UITapGestureRecognizer *)tapGesture {
    [_tutorialView setHidden:YES];
    [_UndoButtonOutlet setHidden:YES];
    [_boundaryClearButtonOutlet setHidden:YES];
    [self gotItButtonAction:nil];
}

- (IBAction)neverShowMeAgainAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDrawBoundaryTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self gotItButtonAction:nil];
}

- (IBAction)saveBtnActilon:(id)sender {
    [self timerStart];
    if([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:1];
    } else {
        [self drawBoundaryAndServiceCall];
    }
}

- (IBAction)cancelBtnAction:(id)sender {
    [self timerStart];
    [self resetSingleMapBondary];
}

#pragma mark - UITextField Delegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(finalString.length>=1) {
        [self.doneUIAlertButton setEnabled:YES];
    } else {
        [self.doneUIAlertButton setEnabled:NO];
    }
    return YES;
}

#pragma mark - polyGoneDraw in mapview -
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    NSString * title = overlay.title;
    if([title isEqualToString:@"title"]) {
        MKPolylineView * aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay];
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.lineWidth = 1;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        return aView;
    }else if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView* aView = [[MKPolygonView alloc]initWithPolygon:(MKPolygon*)overlay];
        if(_color_Code == 2) {
        aView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
            aView.lineWidth = 1;
            aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        } else if(_color_Code == 3){
            aView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        } else {
            aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
            aView.lineWidth = 1;
            aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        }
        return aView;
    }
    return nil;
}

#pragma mark - tableview delegaste -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self calculatePopUpViewHeight];
    return _memberBoundary.boundaryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (CollectionViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Boundary * boundary = [_memberBoundary.boundaryArray objectAtIndex:indexPath.row];
    cell.title.text = boundary.boundary_name;
    cell.tag = indexPath.row;
    cell.cellEditButtonOutlet.tag = indexPath.row;
    [cell.cellEditButtonOutlet addTarget:self action:@selector(editMapBoundary:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.cellDeleteOutlet.tag = indexPath.row;
    [cell.cellDeleteOutlet addTarget:self action:@selector(deleteMapBoundary:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.title.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self timerStart];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (isEditMode) {
            [self resetSingleMapBondary];
        }
        [self deleteCell:(int)indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cancelBtnAction:nil];
    [self timerStart];
    Boundary *boundary = [_memberBoundary.boundaryArray objectAtIndex:(int)indexPath.row];
    SubBoundary *subBoundary = [boundary.subBoundaryArray objectAtIndex:0];
    NSMutableArray *allpoint = [[NSMutableArray alloc] init];
    for(SubBoundary *subBoundaryRow in boundary.subBoundaryArray) {
        BoundaryLocation * location = subBoundaryRow.location;
        [allpoint addObject:[NSValue valueWithCGPoint:CGPointMake(location.lat,location.log)]];
    }
   CGPoint point = [self polygonCenterPoint:allpoint];
    [self focusSingleBoundary:point.x  andLog:point.y];
    for (id<MKOverlay> overlayToRemove in _mapView.overlays)
    {
       NSString * title = overlayToRemove.title;
        if(title.length>0) {
            if((int)indexPath.row == [title intValue]) {
                [_mapView removeOverlay:overlayToRemove];
                [self addNewMapBoundary:allpoint andAddServiceCall:NO boundayIndex:(int)indexPath.row andPolygonColor:2];
                NSLog(@"%ld",(long)indexPath.row);
                break;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self timerStart];
    NSLog(@"%ld",(long)indexPath.row);
    int index = (int)indexPath.row;
    NSLog(@"%d",index);
    [self resetMapView];
    [self drawBoundaryInMapView:-1];
}

#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    if(!isEditMode) {
    if ([annotation isKindOfClass:[DXAnnotationMB class]]) {
        DXAnnotationMB *dxAnnotation = (DXAnnotationMB*)annotation;
        UIImageView *pinView = nil;
        CallOutViewMB *calloutView = nil;
        DXAnnotationView *annotationView = (DXAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([DXAnnotationView class])];
        //if (!annotationView) {
        if (dxAnnotation.index == kMemberIndexOnBoundary) {
            pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Selected-User-Mark-icon"]];
            calloutView = nil;
        } else {
            annotationView.centerOffset = CGPointMake(-10,-10);
            pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapPin"]];
            calloutView = (CallOutViewMB*)[[[NSBundle mainBundle] loadNibNamed:@"CallOutViewMB" owner:self options:nil] firstObject];
            calloutView.removeBtn.tag = dxAnnotation.index;
            [calloutView.removeBtn addTarget:self action:@selector(removeBoundaryAnnotaion:) forControlEvents:UIControlEventTouchUpInside];
        }
        annotationView = [[DXAnnotationView alloc] initWithAnnotation:dxAnnotation
                                                          reuseIdentifier:NSStringFromClass([DXAnnotationView class])
                                                                  pinView:pinView
                                                              calloutView:calloutView
                                                                 settings:[DXAnnotationSettings defaultSettings]];
        return annotationView;
    }
    return nil;
    } else {
        MyAnnotation *myAnnotation = (MyAnnotation*)annotation;
        MKAnnotationView *pin = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
        pin = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
        pin.canShowCallout = YES;
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = myAnnotation.index;
        [detailButton setImage:[UIImage imageNamed:@"pinImage"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(mapBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = detailButton;
        if(myAnnotation.isTempAnnotation == 0) {
            pin.image = [UIImage imageNamed:@"pinImage"];
        } else {
            pin.image = [UIImage imageNamed:@"CloseButton"];
            [pin.rightCalloutAccessoryView setHidden:YES];
            pin.canShowCallout = NO;
        }
        pin.draggable = YES;
        return pin;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(!isEditMode) {
        if ([view isKindOfClass:[DXAnnotationView class]]) {
            for (id<MKAnnotation> annotation in mapView.annotations) {
                DXAnnotationView* anView = (DXAnnotationView*)[mapView viewForAnnotation: annotation];
                if (anView) {
                    DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)anView.annotation;
                    if(dxAnnotation.index == kMemberIndexOnBoundary) {
                    } else {
                        DXAnnotationView* dxView = (DXAnnotationView*)anView;
                        UIImageView *pinImage = (UIImageView*)dxView.pinView;
                        UIImage * image2 = [UIImage imageNamed:@"mapPin"];
                        pinImage.image = image2;
                    }
                }
            }
            DXAnnotationView* dxView = (DXAnnotationView*)view;
            DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)dxView.annotation;
            if(dxAnnotation.index == kMemberIndexOnBoundary) {
            } else {
                UIImageView *pinImage = (UIImageView*)dxView.pinView;
                UIImage * image2 = [UIImage imageNamed:@"mapPin"];
                pinImage.image = image2;
            }
            [self.mapView setCenterCoordinate:dxAnnotation.coordinate animated:YES];
            [((DXAnnotationView *)view)showCalloutView];
            view.layer.zPosition = 0;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if(!isEditMode){
        if ([view isKindOfClass:[DXAnnotationView class]]) {
            DXAnnotationView* dxView = (DXAnnotationView*)view;
            UIImageView *pinImage = (UIImageView*)dxView.pinView;
           DXAnnotationMB *dxAnnotation = (DXAnnotationMB *)dxView.annotation;
            UIImage * image2;
            if(dxAnnotation.index == kMemberIndexOnBoundary) {
                image2 = [UIImage imageNamed:@"Selected-User-Mark-icon"];
            } else {
                image2 = [UIImage imageNamed:@"mapPin"];
            }
            pinImage.image = image2;
            [((DXAnnotationView *)view)hideCalloutView];
            view.layer.zPosition = -1;
        }
    }
}

-(void)focusSingleBoundary:(double)lat andLog:(double)log{
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = lat;
    ctrpoint.longitude = log;
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(ctrpoint, 1000, 1000)];
}

-(void)drawBoundaryInMapView:(int)exceptDrawPolyGonIndex {
    int index = 0;
    for(Boundary *row in _memberBoundary.boundaryArray) {
        if(index != exceptDrawPolyGonIndex){
            NSString *boundaryName = row.boundary_name;
            //NSString *boundaryId = row.boundary_id;
            _addBoundaryPointArray = [[NSMutableArray alloc] init];
            NSMutableArray * subBoundaryArray = row.subBoundaryArray;
            for(SubBoundary *subBoundaryRow in subBoundaryArray) {
                BoundaryLocation * location = subBoundaryRow.location;
                [_addBoundaryPointArray addObject:[NSValue valueWithCGPoint:CGPointMake(location.lat,location.log)]];
            }
            [self addNewMapBoundary:_addBoundaryPointArray andAddServiceCall:NO boundayIndex:index andPolygonColor:1];
        }
        index++;
    }
}

- (void)resetMapView {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [self addMemberPositonOnMap];
}

#pragma mark - boundary add service
- (void)addBoundaryService:(NSMutableArray *)locationPoints {
    emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
    [emergencyContactHud setLabelText:NSLocalizedString(ADD_BOUNDARY_TEXT,nil)];
    [self.view addSubview:emergencyContactHud];
    [emergencyContactHud show:YES];
    NSMutableArray * locationArray = [[NSMutableArray alloc] init]; // format points send to service
    for(int i=0; i<locationPoints.count; i++) {
        NSValue *val = [locationPoints objectAtIndex:i];
        CGPoint point = [val CGPointValue];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithDouble:point.x] forKey:@"lat"];
        [dic setObject:[[NSNumber numberWithDouble:point.y] stringValue] forKey:@"long"];
        [locationArray addObject:dic];
    }
    NSDictionary *requestBody = @{kBoundaryName:_boundaryName,
                                  kGuardianId:_modelManager.user.guardianId,
                                  kUser_id_key:_memberId,
                                  kLocationKey:locationArray,
                                  kTokenKey:_modelManager.user.sessionToken
                                  };
    NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:ADD_BOUNDARY],
                             WHEN_KEY:[NSDate date],
                             OBJ_KEY:requestBody
                             };
    [_serviceHandler onOperate:newMsg];
    _boundaryName = @"";
}

- (void)getBoundaryService {
    if([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    }else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        NSDictionary *requestBody = @{
                                      kUser_id_key:_memberId,
                                      kTokenKey:_modelManager.user.sessionToken
                                      };
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:GET_BOUNDARY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:requestBody
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)deleteBoundaryService:(int)deleteCell {
    if([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    } else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        Boundary * boundary = [_memberBoundary.boundaryArray objectAtIndex:deleteCell];
        NSDictionary *requestBody = @{kUser_id_key:_memberId,
                                      kBoundaryIdKey:boundary.boundary_id,
                                      kTokenKey:_modelManager.user.sessionToken
                                      };
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:DELETE_BOUNDARY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:requestBody
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

- (void)updateBounaryService:(NSMutableArray *)locationPoints andArrayIndex:(int)arrayIndex {
    if([FamilyTrackerReachibility isUnreachable]) {
        [Common displayToast:NSLocalizedString(INTERNET_CONNECTION_ERROR,nil) title:NSLocalizedString(TRY_AGAIN,nil) duration:2];
    } else {
        emergencyContactHud = [[MBProgressHUD alloc] initWithView:self.view];
        [emergencyContactHud setLabelText:NSLocalizedString(UPDATE_TEXT,nil)];
        [self.view addSubview:emergencyContactHud];
        [emergencyContactHud show:YES];
        Boundary * boundary = [_memberBoundary.boundaryArray objectAtIndex:arrayIndex];
        NSMutableArray * locationArray = [[NSMutableArray alloc] init];
        for(int i=0; i<locationPoints.count; i++) {
            NSValue *val = [locationPoints objectAtIndex:i];
            CGPoint point = [val CGPointValue];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithDouble:point.x] forKey:@"lat"];
            [dic setObject:[[NSNumber numberWithDouble:point.y] stringValue] forKey:@"long"];
            [locationArray addObject:dic];
        }
        NSDictionary *requestBody = @{
                                      kGuardianId:_modelManager.user.guardianId,
                                      kUser_id_key:_memberId,
                                      kLocationKey:locationArray,
                                      kBoundaryName:boundary.boundary_name,
                                      kBoundaryIdKey:boundary.boundary_id,
                                      kTokenKey:_modelManager.user.sessionToken
                                      };
        NSDictionary *newMsg = @{WHAT_KEY:[NSNumber numberWithInteger:UPDATE_BOUNDARY],
                                 WHEN_KEY:[NSDate date],
                                 OBJ_KEY:requestBody
                                 };
        [_serviceHandler onOperate:newMsg];
    }
}

#pragma mark - Service Callback -
- (void)updateUI:(id)object withStatus:(int)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [emergencyContactHud hide:YES];
        emergencyContactHud = nil;
        if(sourceType == ADD_BOUNDARY_SUCCCEEDED) {
            [_mapView removeAnnotations:_mapView.annotations];
            [self getBoundaryService];
        } else if(sourceType == ADD_BOUNDARY_FAILED) {
            NSString *errorMsg = @"";
            if([object isKindOfClass:[NSDictionary class]]) {
                if (object[kMessageKey][[ModelManager sharedInstance].defaultLanguage]) {
                    errorMsg = object[kMessageKey][[ModelManager sharedInstance].defaultLanguage];
                } else {
                    errorMsg = NSLocalizedString(@"Boundary creation failed!",nil);
                }
            } else {
                errorMsg = NSLocalizedString(@"Boundary creation failed!",nil);
            }
            UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:NSLocalizedString(TRY_AGAIN, nil)  message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(OK_BUTTON_TITLE_KEY,nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self cancelBtnAction:nil];
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else if(sourceType == GET_BOUNDARY_SUCCCEEDED) {
            NSLog(@"GET_BOUNDARY_SUCCCEEDED");
            [self resetMapView];
            NSError *error = nil;
            _memberBoundary = [[MemberBoundary alloc] initWithDictionary:object error:&error];
            [self drawBoundaryInMapView:-1];
            [_tableView reloadData];
            //---temp code for check user position insidePolygons or outsidePolgyons---//
            for(Boundary *row in _memberBoundary.boundaryArray) {
                NSMutableArray * subBounaryAllPoints = [[NSMutableArray alloc] init];
                for(SubBoundary *subBoundary in row.subBoundaryArray) {
                    BoundaryLocation * location = subBoundary.location;
                    [subBounaryAllPoints addObject:[NSValue valueWithCGPoint:CGPointMake(location.lat,location.log)]];
                }
                CGPoint userPosition = CGPointMake(_lat, _lon);
               BOOL inside = [Algorithms isInsidePolyGon:subBounaryAllPoints andCheckPoint:userPosition];
                NSLog(@"%d",inside);
            }
            // temp code for check position
        } else if(sourceType == GET_BOUNDARY_FAILED) {
            NSLog(@"GET_BOUNDARY_FAILED");
        } else if(sourceType == DELETE_BOUNDARY_SUCCCEEDED) {
           [_memberBoundary.boundaryArray removeObjectAtIndex:_deleteCellIndex];
           [self resetMapView];
           [self drawBoundaryInMapView:-1];
           [_tableView reloadData];
        } else if(sourceType == DELETE_BOUNDARY_FAILED) {
            NSLog(@"DELETE_BOUNDARY_FAILED");
        } else if(sourceType == UPDATE_BOUNDARY_SUCCCEEDED) {
            [self getBoundaryService];
        } else if(sourceType == UPDATE_BOUNDARY_FAILED) {
            NSLog(@"UPDATE_BOUNDARY_FAILED");
        }
    });
}

-(void)timerStart{
    if(userInteractionTimer) {
        [userInteractionTimer invalidate];
        userInteractionTimer = nil;
    }
    _timeCounter = 30;
    userInteractionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

-(void)timerStop {
    if(userInteractionTimer) {
        [userInteractionTimer invalidate];
        userInteractionTimer = nil;
    }
}

- (void)updateTimer {
    if(tutorialMode) {
        return ;
    }
    if(_timeCounter == 0) {
        if(userInteractionTimer) {
            [userInteractionTimer invalidate];
            userInteractionTimer = nil;
        }
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:NSLocalizedString(@"Do you want to see the boundary tutorial?", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *continueAction = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"Show", nil)
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             if([_saveBtnOutlet isHidden]) {
                                                 isSaveBtnHidden = YES;
                                             }
                                             if([_cancelBtnOutlet isHidden]) {
                                                 isCancelBtnHidden = YES;
                                             }
                                             if([_boundaryClearButtonOutlet isHidden]) {
                                                 isClearBtnHidden = YES;
                                             }
                                             if([_UndoButtonOutlet isHidden]) {
                                                 isUndoBtnHidden = YES;
                                             }
                                             [_saveBtnOutlet setHidden:NO];
                                             [_cancelBtnOutlet setHidden:NO];
                                             [_tutorialView setHidden:NO];
                                             [_boundaryClearButtonOutlet setHidden:NO];
                                             [_UndoButtonOutlet setHidden:NO];
                                             [self labelZoomIn];
                                         }];
        UIAlertAction *skipAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Skip", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                     }];
        [alertController addAction:continueAction];
        [alertController addAction:skipAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _timeCounter--;
    }
}
@end
