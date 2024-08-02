//
//  PaymentViewController.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 3/1/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PaymentViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, readwrite) NSString *currentURL;
@property (nonatomic, weak) id<UIWebViewDelegate> delegate;
@end
