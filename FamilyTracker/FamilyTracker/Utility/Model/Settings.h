//
//  Settings.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "SettingModel.h"

@protocol Settings
@end

@interface Settings : JSONModel
@property (nonatomic, strong) NSMutableArray<SettingModel,Optional> *rows;
@end
