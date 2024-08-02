//
//  AlertView.h
//  Physician
//
//  Created by einfochips on 04/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface AlertView : UIAlertController

+(void)customAlertView:(NSString *)title message:(NSString *)message button:(int)button delegate:(UIViewController *)delegate;

@end
