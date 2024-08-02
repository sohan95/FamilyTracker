//
//  SettingsTableViewController.h
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 17/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>
{
    NSUInteger screenTag;
}
@property (strong, nonatomic) NSMutableDictionary *profileDetail;
@property (strong, nonatomic) id parentVC;

@property (nonatomic, assign) NSUInteger screenTag;

@end
