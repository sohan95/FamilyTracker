//
//  Updater.h
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Updater <NSObject>
@optional
- (void)update;
- (void)onUpdate;
@end
