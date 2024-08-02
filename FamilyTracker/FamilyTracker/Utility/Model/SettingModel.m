//
//  SettingModel.m
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/7/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel
+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"app_id":@"appId",
                                                       @"id":@"identifier",
                                                       @"created_at":@"createdAt",
                                                       @"description": @"descriptionSetting",
                                                       @"title": @"title",
                                                       @"settings_for": @"settingsFor",
                                                       @"settings_type": @"settingType",
                                                       @"settings_value": @"settingValue"
                                                       }];
}

@end
