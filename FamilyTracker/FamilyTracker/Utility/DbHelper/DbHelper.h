//
//  DbHelper.h
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "EmergencyContactModel.h"
@interface DbHelper : NSObject

+(id)sharedInstance;
@property (strong,nonatomic) NSString *databashPath;
@property (nonatomic) sqlite3 *DB;
// chating part
-(BOOL) insertMessageForOffLine:(NSString *)message andChatWithUser:(NSString *)chatWithUser;
-(NSMutableArray *)getAllOffLineMessage;
-(BOOL)updateStatus:(NSString *)Id andTableName:(NSString * )tableName;

-(BOOL) insertEmergencyContact:(NSDictionary *)insertContactDic;
-(BOOL)updateEmergencyContact:(EmergencyContactModel *)emergencyContactModel;
-(BOOL) insertEmergencyContact1:(EmergencyContactModel *)emergencyContactModel;
-(NSMutableArray *)getAllEmergencyContactFromSqlit:(NSString * )quaryLastPart;
-(BOOL) insertRemoveEmergencyContact:(EmergencyContactModel *)emergencyContactModel;
-(NSMutableArray *)getAllRemoveEmergencyContactFromSqlit:(NSString * )quaryLastPart;
// postLocation
-(BOOL)insertPostLocation:(NSDictionary *)postLocationData;
-(NSMutableArray *)getLocations: (NSString *)where;

- (BOOL)insertPanicService:(NSDictionary *)postPanicData;
- (NSMutableArray *)getPanicService;

-(BOOL)updateStatusWithCondition:(NSString * )tableName andcondition:(NSString*)condition;
-(BOOL) resetSingleTable:(NSString *)tableName;
-(void) resetAllTable;
@end
