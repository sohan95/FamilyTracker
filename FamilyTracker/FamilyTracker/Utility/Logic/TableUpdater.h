//
//  TableUpdated.h
//  CamConnect
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableUpdater <NSObject>
- (void)refreshUI:(int)sourceType;
@end
