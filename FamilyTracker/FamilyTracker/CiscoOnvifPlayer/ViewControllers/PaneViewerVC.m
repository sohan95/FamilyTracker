//
//  PaneViewerVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 16/02/16.
//  Copyright © 2016 eInfochips. All rights reserved.
//

#import "PaneViewerVC.h"

#define kPaneType2x1    21
#define kPaneType1x2    12
#define kPaneType2x2    22
#define kPaneType3x3    33

#define kPaneMargin 10

@interface PaneViewerVC ()
{
    IBOutlet UIView *containerView;
    
    NSInteger standardWidth;
    NSInteger standardHeight;
    NSUInteger viewCount;
    NSMutableArray *viewControllerArr;
    
    NSUInteger rowCount;
    NSUInteger columnCount;
}
@end

@implementation PaneViewerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Actions
- (IBAction)tappedPaneType:(id)sender {
    NSUInteger paneTag = [sender tag];
    
    for (id subView in [containerView subviews]) {
        [subView removeFromSuperview];
    }
    
//    NSInteger decimalNumberFirst = paneTag/10;
//    NSInteger decimalNumberSecond = paneTag%10;
    
//    viewCount = decimalNumberFirst * decimalNumberSecond;
//    if (decimalNumberFirst > 1 ) {
//        standardWidth = (containerView.frame.size.width/viewCount) - (kPaneMargin * (viewCount +1));
//    }
//    else {
//        standardWidth = containerView.frame.size.width - (kPaneMargin * viewCount);
//    }
//    
//    if (decimalNumberSecond > 1) {
//        standardHeight = (containerView.frame.size.height/viewCount) - (kPaneMargin * (viewCount +1));
//    }
//    else {
//        standardHeight = containerView.frame.size.height - (kPaneMargin * 2);
//    }
    
    rowCount = paneTag/10;
    columnCount = paneTag%10;
    
    viewCount = rowCount * columnCount;
    standardWidth = (containerView.frame.size.width/columnCount) - viewCount-kPaneMargin;//(kPaneMargin * (columnCount+1));
    standardHeight = (containerView.frame.size.height/rowCount) - viewCount-kPaneMargin;//(kPaneMargin * (rowCount+1));
    
    [self addSubViews];
    
    /*switch (paneTag) {
        case kPaneType1x2:
        {
            NSLog(@"1x2");
            viewCount = 2;
            rowCount = 1;
            columnCount = 2;
            standardWidth = (containerView.frame.size.width/2.0) -7;//- (kPaneMargin * 3);
            standardHeight = containerView.frame.size.height - (kPaneMargin * 2);
            [self addSubViews];
        }
            break;
        case kPaneType2x1:
        {
            NSLog(@"2x1");
            viewCount = 2;
            rowCount = 2;
            columnCount = 1;
            
            standardHeight = (containerView.frame.size.height/2.0)-5;// - (kPaneMargin *3);
            standardWidth = containerView.frame.size.width - (kPaneMargin * 2);
            [self addSubViews];

        }
            break;
        case kPaneType2x2:
        {
            NSLog(@"2x2");
            viewCount = 4;
            rowCount = 2;
            columnCount = 2;
            
            standardWidth = (containerView.frame.size.width/2.0)-7;// - (kPaneMargin * 3);
            standardHeight = (containerView.frame.size.height/2.0)-7;// - (kPaneMargin *3);
            [self addSubViews];
        }
            break;
        case kPaneType3x3:
        {
            NSLog(@"3x3");
            viewCount = 6;
            rowCount = 3;
            columnCount = 3;
            
            standardWidth = (containerView.frame.size.width/3.0)-6;// - (kPaneMargin + kPaneMargin+ kPaneMargin+ kPaneMargin);
            standardHeight = (containerView.frame.size.height/3.0)-7;// - (kPaneMargin *3);
            [self addSubViews];
        }
            break;
        default:
            break;
    }*/
}

#pragma mark - User Define Methods

- (void)addSubViews {
    viewControllerArr = [NSMutableArray arrayWithCapacity:viewCount];
    
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    
    NSLog(@"standardWidth:%d",standardWidth);
    NSLog(@"standardHeight:%d",standardHeight);
    
    NSUInteger screencount = 0;
    for (NSUInteger indexRow = 0; indexRow < rowCount; indexRow++) {

        for (NSUInteger indexCol = 0; indexCol < columnCount; indexCol++) {
            
//            if (standardWidth == containerView.frame.size.width - (kPaneMargin * 2)) {
//                xPos = kPaneMargin;
//            }
//            else {
                xPos = kPaneMargin + (indexCol * (standardWidth + kPaneMargin) );
//            }
            
//            if (standardHeight == containerView.frame.size.height - (kPaneMargin * 2)) {
//                yPos = kPaneMargin ;
//            }
//            else {
                yPos = kPaneMargin + (indexRow * (standardHeight + kPaneMargin) );
//            }
            
            screencount ++;
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, standardWidth, standardHeight)];
            [subView setBackgroundColor:[UIColor clearColor]];
            [containerView addSubview:subView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
            [label setText:[NSString stringWithFormat:@"View %d",screencount]];
            [subView addSubview:label];
            
            [viewControllerArr addObject:subView];
            
        }
    }
}

@end
