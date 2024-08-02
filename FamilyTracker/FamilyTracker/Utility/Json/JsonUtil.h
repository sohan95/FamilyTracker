//
//  JsonUtil.h
//  CamConnect
//
//  Created by makboney Ltd on 2/4/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//https://github.com/icanzilb/JSONModel

#import <Foundation/Foundation.h>
#import "FamilyTrackerDefine.h"

@interface JsonUtil : NSObject
+ (id)load:(NSString *)className andDataDictionary:(NSDictionary *)dataDictionary;
+ (id)loadObject:(NSString *)className withStringData:(NSString *)strData;
+ (id)loadObject:(NSString *)className withFile:(NSString *)fileName andReset:(BOOL)reset;
+ (id)loadObject:(NSString *)className withFile:(NSString *)fileName;
+ (void)saveObject:(id)object withFile:(NSString *)fileName;

@end
