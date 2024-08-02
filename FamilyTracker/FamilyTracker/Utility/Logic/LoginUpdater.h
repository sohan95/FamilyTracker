//
//  LoginUpdater.h
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginUpdater <NSObject>
- (void)loginSuccess:(BOOL)success;
@end
