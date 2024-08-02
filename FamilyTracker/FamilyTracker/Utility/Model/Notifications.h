//
//  Notifications.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Notification.h"

@protocol Notifications
@end

@interface Notifications : JSONModel
//@property (nonatomic, strong) NSString *nextPageForAlert;
@property (nonatomic, strong) NSMutableArray<Notification,Optional> *rows;
@end
