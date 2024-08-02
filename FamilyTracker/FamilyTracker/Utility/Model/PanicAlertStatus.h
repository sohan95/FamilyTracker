//
//  PanicAlertStatus.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/23/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PanicAlertStatus
@end

@interface PanicAlertStatus : NSObject
@property(nonatomic,strong) NSString * panicId;
@property(nonatomic,strong) NSString * userId;
@property(nonatomic,strong) NSString * userName;
@property(nonatomic,strong) NSString * status;
@property(nonatomic,strong) NSString * alreadyRed;

@end
