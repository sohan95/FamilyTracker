//
//  Cameras.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "Settings.h"

@implementation Settings
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<SettingModel> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"resultset":@"rows"}];
}


@end
