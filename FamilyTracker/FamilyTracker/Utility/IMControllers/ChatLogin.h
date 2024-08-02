//
//  ChatLogin.h
//  GroupVideoConnect
//
//  Created by Qaium Hossain on 1/19/15.
//  Copyright (c) 2015 Technuff, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FamilyTrackerDefine.h"

@interface ChatLogin : NSObject

+(void)storeUser:(NSString *)username pass:(NSString *)password;

@end
