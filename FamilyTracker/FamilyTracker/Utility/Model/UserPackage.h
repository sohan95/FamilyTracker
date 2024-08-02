//
//  UserPackage.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 5/21/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"

@protocol UserPackage
@end


@interface UserPackage : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> * user_id;
@property (nonatomic, readwrite) NSString<Optional> * is_active;
@property (nonatomic, readwrite) NSString<Optional> * Id;
@property (nonatomic, readwrite) NSString<Optional> * actual_cost;
@property (nonatomic, readwrite) NSString<Optional> * discount_percentage;
@property (nonatomic, readwrite) NSString<Optional> * end_date;
@property (nonatomic, readwrite) NSString<Optional> * final_cost;
@property (nonatomic, readwrite) NSString<Optional> * package_id;
@property (nonatomic, readwrite) NSString<Optional> * package_name;
@property (nonatomic, readwrite) NSMutableDictionary<Optional> * period;
@property (nonatomic, readwrite) NSString<Optional> * remarks;
@property (nonatomic, readwrite) NSString<Optional> * start_date;
@property (nonatomic, readwrite) NSString<Optional> * user_name;
@end
