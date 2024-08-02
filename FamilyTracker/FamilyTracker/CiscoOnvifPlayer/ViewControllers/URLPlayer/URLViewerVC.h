//
//  URLViewerVC.h
//  CameraStreamming
//
//  Created by einfochips on 12/09/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+AutorotationFromVisibleView.h"

@interface URLViewerVC : UIViewController<UITextFieldDelegate>
{
    // For RTSP URL Text
    IBOutlet UITextField *rtspUrlTextField;
}

@end
