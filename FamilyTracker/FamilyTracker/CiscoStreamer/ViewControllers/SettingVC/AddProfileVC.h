//
//  AddProfileVC.h
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 18/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MediaProfiles+CoreDataProperties.h"

@interface AddProfileVC : UIViewController
{
    NSDictionary *savedProfileDetail;
    NSMutableDictionary *profileDics;
}

@property (nonatomic, strong) NSDictionary *savedProfileDetail;
@property (nonatomic, strong) NSMutableDictionary *profileDics;
@end
