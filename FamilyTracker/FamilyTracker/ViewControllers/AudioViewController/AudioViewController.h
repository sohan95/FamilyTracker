//
//  ViewController.h
//  CiscoIcecastAudioStream
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 i5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioViewController : UIViewController

@property (readwrite, nonatomic) NSString *alertType;
- (void)showAlert:(NSString *)errorMessage;
- (void)stopClient;

@end

