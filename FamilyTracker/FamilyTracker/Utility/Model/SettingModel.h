//
//  SettingModel.h
//  FamilyTracker
//
//  Created by Md. Shahanur Rahmann on 12/7/16.
//  Copyright © 2016 SurroundApps. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"

@protocol SettingModel
@end

@interface SettingModel : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> * appId;
@property (nonatomic, readwrite) NSString * identifier;
@property (nonatomic, readwrite) NSString<Optional> * createdAt;
@property (nonatomic, readwrite) NSDictionary<Optional> * descriptionSetting;
@property (nonatomic, readwrite) NSDictionary<Optional> * title;
@property (nonatomic, readwrite) NSNumber<Optional> * settingsFor;
@property (nonatomic, readwrite) NSString<Optional> * settingType;
@property (nonatomic, readwrite) NSArray<Optional> * settingValue;

@end
