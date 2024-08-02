//
//  UIAlertController+supportedInterfaceOrientations.m
//  CicsoOnvifPlayer_IOS9
//
//  Created by Apple on 27/10/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "UIAlertController+supportedInterfaceOrientations.h"

@implementation UIAlertController (supportedInterfaceOrientations)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations; {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

@end
