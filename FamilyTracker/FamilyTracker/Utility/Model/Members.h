//
//  Members.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 2/26/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "MemberData.h"

@protocol Members
@end

@interface Members : JSONModel
@property (nonatomic, strong) NSMutableArray<MemberData,Optional> *rows;

@end
