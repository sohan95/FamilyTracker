//
//  UserPackages.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/21/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"
#import "UserPackage.h"

@protocol UserPackages
@end


@interface UserPackages : JSONModel<Dto>

@property (nonatomic, strong) NSMutableArray<UserPackage,Optional> *resultset;

@end
