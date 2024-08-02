//
//  UIAlertAction+UIAlertView.m
//  CiscoIPICSVideoStreamer
//
//  Created by einfochips on 04/04/15.
//  Copyright (c) 2015 AHMLPT0406. All rights reserved.
//

#import "UIAlertAction+UIAlertView.h"

@implementation UIAlertController (UIAlertView)
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
