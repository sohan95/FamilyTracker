//
//  ChatLogin.m
//  GroupVideoConnect
//
//  Created by Qaium Hossain on 1/19/15.
//  Copyright (c) 2015 Technuff, LLC. All rights reserved.
//

#import "ChatLogin.h"

@implementation ChatLogin

+(void)storeUser:(NSString *)username pass:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USER_ID_FULL_KEY_SMALL];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:kPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
