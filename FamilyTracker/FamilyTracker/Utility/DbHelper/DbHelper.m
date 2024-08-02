//
//  DbHelper.m
//  FamilyTracker
//
//  Created by Zeeshan Khan on 2/19/17.
//  Copyright © 2017 Sansongs Corporation. All rights reserved.
//

#import "DbHelper.h"
#import "Common.h"
#import "FamilyTrackerDefine.h"
#import "EmergencyContactModel.h"
#import "ModelManager.h"

//#define kDbName @"FamilyTracker.db"
//
//#define kMessageTable @"messageTable"
//#define kId @"Id"
//#define kMessageBody @"message"
//#define kStatus @"status"
//#define kCurrentDateAndTime @"currentDateAndTime"
//#define kchatWithUser @"chatWithUser"

@implementation DbHelper

- (instancetype)init {
    if (self = [super init]) {
        NSString *docDir ;
        NSArray *dirPaths;
        dirPaths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        docDir = dirPaths[0];
        _databashPath = [[NSString alloc] initWithString:[docDir stringByAppendingPathComponent:k_Db_Name]];
    }
    return self;
}


+(id)sharedInstance{
    static DbHelper * shareObject  = nil;
    @synchronized (self) {
        if(shareObject == nil){
            shareObject = [[self alloc] init];
        }
    }
    return shareObject;
}

#pragma - mark offLine Message 

- (void)createOffLineMessageTable {
    char *errorMessage;
    NSString * sql_createOffLineMessage_stm = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ text, %@ text, %@ text,%@ text)",k_Db_MessageTable,k_Db_Id,k_Db_MessageBody,k_Db_CurrentDateAndTime,k_Db_chatWithUser,k_Db_Status];
    
    const char *stm = [sql_createOffLineMessage_stm UTF8String];
    
    if(sqlite3_exec(_DB,stm,NULL,NULL,&errorMessage)) {
        NSLog(@"Error is %s",errorMessage);
    } else {
        NSLog(@"table create successfully");
    }
}

- (BOOL)insertMessageForOffLine:(NSString *)message andChatWithUser:(NSString *)chatWithUser {
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createOffLineMessageTable];
        NSString *currentDateStr = [Common getEpochTimeFromDate:[NSDate date]];
        NSString * status = @"0";
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@) values (\"%@\",\"%@\",\"%@\",\"%@\")",k_Db_MessageTable,k_Db_MessageBody,k_Db_CurrentDateAndTime,k_Db_chatWithUser,k_Db_Status,message,currentDateStr,chatWithUser,status];
        const char *insert_statement = [insertSQL UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL,NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"Error %s",error);
        } else{
            NSLog(@"insert successfully");
            isSucess = YES;
        }
        sqlite3_close(_DB);
    }
    return isSucess;
}

- (NSMutableArray *)getAllOffLineMessage {
    sqlite3_stmt *statement;
    NSMutableArray * allMessageArray = [[NSMutableArray alloc] init];
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        NSString *querySql = [NSString stringWithFormat:@"select * from %@ WHERE %@ = 0",k_Db_MessageTable,k_Db_Status];
        const char *query_statement = [querySql UTF8String];
        if(sqlite3_prepare_v2(_DB,query_statement,-1,&statement,NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *ID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
                NSString *messageBody = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,1)];
                NSString *currentDate = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,2)];
                NSString *chatWithUser = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,3)];
                NSLog(@"Id =  %@ messageBody =  %@ currentDate = %@",ID,messageBody,currentDate);
                NSMutableDictionary * singleMessageDic = [[NSMutableDictionary alloc] init];
                [singleMessageDic setValue:ID forKey:k_Db_Id];
                [singleMessageDic setValue:messageBody forKey:k_Db_MessageBody];
                [singleMessageDic setValue:currentDate forKey:k_Db_CurrentDateAndTime];
                [singleMessageDic setValue:chatWithUser forKey:k_Db_chatWithUser];
                [allMessageArray addObject:singleMessageDic];
            }
        }
    }
    sqlite3_close(_DB);
    return allMessageArray;
}

#pragma - mark Emergency Contact 

-(void)createEmergencyContactTable {
    char *errorMessage;
    NSString * sql_createOffLineMessage_stm = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ text, %@ text, %@ text,%@ text,%@ text, %@ text)",k_Db_EmergencyContactTable,k_Db_Id,k_Db_ContactName,k_Db_ContactNumber,k_Db_ContactNumberServerId,k_Db_ContactPic,k_Db_Status,k_Db_List_Order];
    
    const char *stm = [sql_createOffLineMessage_stm UTF8String];
    
    if(sqlite3_exec(_DB,stm,NULL,NULL,&errorMessage))
    {
        NSLog(@"Error is %s",errorMessage);
    }
    else{
        NSLog(@"table create successfully");
    }
}

-(BOOL) insertEmergencyContact:(NSDictionary *)insertContactDic{
   // NSString *Id = [insertContactDic valueForKey:k_Db_Id];
    NSString *contactName = [insertContactDic valueForKey:k_Db_ContactName];
    NSString *contactNumber = [insertContactDic valueForKey:k_Db_ContactNumber];
    NSString *contactServerId = [insertContactDic valueForKey:k_Db_ContactNumberServerId];
    NSString *contactPic = [insertContactDic valueForKey:k_Db_ContactPic];
    NSString *status = [insertContactDic valueForKey:k_Db_Status];
    NSString *list_order = [insertContactDic valueForKey:k_Db_List_Order];
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createEmergencyContactTable];
        NSString * insetQry = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",k_Db_EmergencyContactTable,k_Db_ContactName,k_Db_ContactNumber,k_Db_ContactNumberServerId,k_Db_ContactPic,k_Db_Status,k_Db_List_Order,contactName,contactNumber,contactServerId,contactPic,status,list_order];
            const char *insert_statement = [insetQry UTF8String];
            int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
            if(rc != SQLITE_OK) {
                NSLog(@"Error %s",error);
            } else{
                NSLog(@"insert emergency contact successfully");
                isSucess = YES;
            }
        sqlite3_close(_DB);
    }
    return isSucess;
}

-(BOOL) insertEmergencyContact1:(EmergencyContactModel *)emergencyContactModel{
    NSString *Id = @"1";
    NSString *contactName = emergencyContactModel.contactName;
    NSString *contactNumber = emergencyContactModel.contactArray[0];
    NSString *contactServerId = emergencyContactModel.contactId;
    NSString *contactPic = @"";
    NSString *status = @"1";
    NSString * listorder = emergencyContactModel.listOrder;
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createEmergencyContactTable];
        NSString * insetQry = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",k_Db_EmergencyContactTable,k_Db_ContactName,k_Db_ContactNumber,k_Db_ContactNumberServerId,k_Db_ContactPic,k_Db_Status,k_Db_List_Order,contactName,contactNumber,contactServerId,contactPic,status,listorder];
        const char *insert_statement = [insetQry UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"Error %s",error);
        } else{
            NSLog(@"insert emergency contact successfully");
            isSucess = YES;
        }
        sqlite3_close(_DB);
    }
    return isSucess;
}

-(BOOL)updateEmergencyContact:(EmergencyContactModel *)emergencyContactModel {
    BOOL isSucess = NO;
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        char *error;
        NSString *contactServerId = emergencyContactModel.contactId;
//        NSString *contactName = emergencyContactModel.contactName;
//        NSString *contacNumber =[NSString stringWithFormat:@"%@",emergencyContactModel.contactArray[0]];
        NSString * status = @"1";
        NSString * listOrder = emergencyContactModel.listOrder;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = \"%@\", %@ = \"%@\"  WHERE %@ = \"%@\" ",k_Db_EmergencyContactTable,k_Db_ContactNumberServerId,contactServerId,k_Db_Status,status,k_Db_List_Order,listOrder];
        const char *insert_statement = [updateSQL UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
        }else {
            isSucess = YES;
        }
    }
    sqlite3_close(_DB);
    
    return isSucess;
}
-(NSMutableArray *)getAllEmergencyContactFromSqlit:(NSString * )quaryLastPart {
    sqlite3_stmt *statement;
    NSMutableArray * allEmergencyContact = [[NSMutableArray alloc] init];
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        NSString *querySql = [NSString stringWithFormat:@"select * from %@ %@",k_Db_EmergencyContactTable,quaryLastPart];
        const char *query_statement = [querySql UTF8String];
        if(sqlite3_prepare_v2(_DB,query_statement,-1,&statement,NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
               // NSString *ID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
                NSString *contactName = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,1)];
                NSString *contact = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,2)];
                NSString *contactServerId = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,3)];
                NSString *contactPic = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,4)];
                //NSString *status = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,5)];
                NSString *listOrder = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,6)];
                
                NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
               NSString * userId = [ModelManager sharedInstance].user.identifier;
                [row setValue:userId forKey:@"user_id"];
                [row setValue:contactServerId forKey:@"id"];
                NSArray * contactArray = [[NSArray alloc] initWithObjects:contact, nil];
                [row setValue:contactArray forKey:@"contact"];
                [row setValue:contactName forKey:@"contact_name"];
                [row setValue:contactPic forKey:@"contact_pic"];
                [row setValue:listOrder forKey:@"list_order"];
                [allEmergencyContact addObject:row];

            }
        }
    }
    sqlite3_close(_DB);
    return allEmergencyContact;
}


-(void)createRemoveEmergencyContactTable {
    char *errorMessage;
    NSString * sql_createOffLineMessage_stm = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ text, %@ text)",k_Db_EmergencyRemoveContactTable,k_Db_Id,k_Db_ContactNumberServerId,k_Db_Status];
    const char *stm = [sql_createOffLineMessage_stm UTF8String];
    if(sqlite3_exec(_DB,stm,NULL,NULL,&errorMessage))
    {
        NSLog(@"Error is %s",errorMessage);
    }
    else{
        NSLog(@"table create successfully");
    }
}

-(BOOL) insertRemoveEmergencyContact:(EmergencyContactModel *)emergencyContactModel{
    NSString *contactServerId = emergencyContactModel.contactId;
    NSString * status = @"0";
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createRemoveEmergencyContactTable];
        NSString * insetQry = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@) VALUES (\"%@\",\"%@\")",k_Db_EmergencyRemoveContactTable,k_Db_ContactNumberServerId,k_Db_Status,contactServerId,status];
        const char *insert_statement = [insetQry UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"Error %s",error);
        } else{
            NSLog(@"insert remove emergency contact successfully");
            isSucess = YES;
        }
        sqlite3_close(_DB);
    }
    return isSucess;
}



-(NSMutableArray *)getAllRemoveEmergencyContactFromSqlit:(NSString * )quaryLastPart {
    sqlite3_stmt *statement;
    NSMutableArray * allEmergencyContact = [[NSMutableArray alloc] init];
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        NSString *querySql = [NSString stringWithFormat:@"select * from %@ %@",k_Db_EmergencyRemoveContactTable,quaryLastPart];
        const char *query_statement = [querySql UTF8String];
        if(sqlite3_prepare_v2(_DB,query_statement,-1,&statement,NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *serverId = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,1)];
                [allEmergencyContact addObject:serverId];
            }
        }
    }
    sqlite3_close(_DB);
    return allEmergencyContact;
}


#pragma - mark offLineLocationPost Function
-(void)createOffLinePostLocationTable {
    char *errorMessage;
    NSString * sql_createOffLinePostLocation_stm = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ text, %@ text, %@ text,%@ text)",k_Db_PostLocationTable,k_Db_Id,k_Db_Latitude,k_Db_Longitude,K_Db_timeStamp,k_Db_Status];
    
    const char *stm = [sql_createOffLinePostLocation_stm UTF8String];
    
    if(sqlite3_exec(_DB,stm,NULL,NULL,&errorMessage))
    {
        NSLog(@"Error is %s",errorMessage);
    }
    else{
        NSLog(@"postLocation table create successfully");
    }
}


- (BOOL)insertPostLocation:(NSDictionary *)postLocationData{
    NSString * lat = [postLocationData valueForKey:k_Db_Latitude];
    NSString * lon = [postLocationData valueForKey:k_Db_Longitude];
    NSString * time = [postLocationData valueForKey:K_Db_timeStamp];
    NSString * status = @"0";
    
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createOffLinePostLocationTable];
        
        NSString * insertQry = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@) VALUES (\"%@\",\"%@\",\"%@\",\"%@\")",k_Db_PostLocationTable,k_Db_Latitude,k_Db_Longitude,K_Db_timeStamp,k_Db_Status,lat,lon,time,status];
        const char *insert_statement = [insertQry UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"Error %s",error);
        } else{
            NSLog(@"insert successfully");
            isSucess = YES;
        }
        
        sqlite3_close(_DB);
    }
    return isSucess;
}

- (NSMutableArray *)getLocations: (NSString *)where {
    sqlite3_stmt *statement;
    NSMutableArray * locations = [[NSMutableArray alloc] init];
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        NSString *querySql = [NSString stringWithFormat:@"select * from %@ %@",k_Db_PostLocationTable,where];
        const char *query_statement = [querySql UTF8String];
        if(sqlite3_prepare_v2(_DB,query_statement,-1,&statement,NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *ID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
                NSString *latitude = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,1)];
                NSString *longitude = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,2)];
                NSString *timestamp = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,3)];
                
                NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
                [row setValue:ID forKey:k_Db_Id];
                [row setValue:latitude forKey:k_Db_Latitude];
                [row setValue:longitude forKey:k_Db_Longitude];
                [row setValue:timestamp forKey:K_Db_timeStamp];
                [locations addObject:row];
            }
        }
    }
    sqlite3_close(_DB);
    return locations;
}


#pragma - mark updateTable Status

-(BOOL)updateStatus:(NSString *)Id andTableName:(NSString * )tableName {
    BOOL isSucess = NO;
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        char *error;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = 1  WHERE %@ = \"%@\" ",tableName,k_Db_Status,k_Db_Id,Id];
        const char *insert_statement = [updateSQL UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
        
        }else {
         isSucess = YES;
        }
    }
    return isSucess;
}


-(BOOL)updateStatusWithCondition:(NSString * )tableName andcondition:(NSString*)condition{
    BOOL isSucess = NO;
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        char *error;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ = 1  WHERE  \"%@\" ",tableName,k_Db_Status,condition];
        const char *insert_statement = [updateSQL UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"%s",error);
        }else {
            isSucess = YES;
        }
    }
    return isSucess;
}

#pragma - mark resetSingleTable
-(BOOL) resetSingleTable:(NSString *)tableName {
    BOOL isSucess = NO;
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK)
    {
        char *error;
        NSString *sql_stm = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
        const char *insert_statement = [sql_stm UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK && rc != 1)
        {
            NSLog(@"Error %s",error);
        }
        else{
            NSLog(@"truncate %@ successfully",tableName);
            isSucess = YES;
        }
        sqlite3_close(_DB);
    }
    return isSucess;
}

#pragma - mark resetAllTable
-(void) resetAllTable {
    char * error;
   NSString *kMessageReset_stm = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@ ",k_Db_MessageTable];
    const char *reset_statement = [kMessageReset_stm UTF8String];
    int rc = sqlite3_exec(_DB,reset_statement,NULL, NULL,&error);
    
    NSString *kEmergencyReset_stm = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",k_Db_EmergencyContactTable];
    const char *emergency_statement = [kEmergencyReset_stm UTF8String];
     rc = sqlite3_exec(_DB,emergency_statement,NULL, NULL,&error);
    
    NSString *kLocationPostTableReset_stm = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",k_Db_PostLocationTable];
    const char *locationPost_statement = [kLocationPostTableReset_stm UTF8String];
    rc = sqlite3_exec(_DB,locationPost_statement,NULL, NULL,&error);
}

#pragma - mark offLinePanicAlert Function

- (void)createOffLinPanicPosting {
    char *errorMessage;
    NSString * sql_createOffLinePostLocation_stm = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( %@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text)",k_Db_PostPanicTable,k_Db_Id,kAlert_type,kResourceTypeKey,Kcreated_at,klatitudeKey,kLongitudeKey,k_Db_Status];
    const char *stm = [sql_createOffLinePostLocation_stm UTF8String];
    if (sqlite3_exec(_DB,stm,NULL,NULL,&errorMessage)) {
        NSLog(@"Error is %s",errorMessage);
    } else {
        NSLog(@"postLocation table create successfully");
    }
}

- (BOOL)insertPanicService:(NSDictionary *)postPanicData {
    NSString * alertType = [postPanicData valueForKey:kAlert_type];
    NSString * resourceType = [postPanicData valueForKey:kResourceTypeKey];
    NSString * createdAt = [postPanicData valueForKey:Kcreated_at];
    NSString * latitude = [postPanicData valueForKey:klatitudeKey];
    NSString * longitude = [postPanicData valueForKey:kLongitudeKey];
    NSString * status = @"0";
    
    BOOL isSucess = NO;
    const char *dbPath = [_databashPath UTF8String];
    char *error;
    if(sqlite3_open(dbPath,&_DB) == SQLITE_OK){
        [self createOffLinPanicPosting];
        NSString * insertQry = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",k_Db_PostPanicTable,kAlert_type,kResourceTypeKey,Kcreated_at,klatitudeKey,kLongitudeKey,k_Db_Status,alertType,resourceType,createdAt,latitude,longitude,status];
        const char *insert_statement = [insertQry UTF8String];
        int rc = sqlite3_exec(_DB,insert_statement,NULL, NULL,&error);
        if(rc != SQLITE_OK) {
            NSLog(@"Error %s",error);
        } else {
            NSLog(@"insert successfully");
            isSucess = YES;
        }
        sqlite3_close(_DB);
    }
    return isSucess;
}

- (NSMutableArray *)getPanicService {
    sqlite3_stmt *statement;
    NSMutableArray * panicServices = [[NSMutableArray alloc] init];
    const char *dataPath = [_databashPath UTF8String];
    if(sqlite3_open(dataPath,&_DB) == SQLITE_OK) {
        NSString *querySql = [NSString stringWithFormat:@"select * from %@ WHERE %@ = 0",k_Db_PostPanicTable,k_Db_Status];
        const char *query_statement = [querySql UTF8String];
        if(sqlite3_prepare_v2(_DB,query_statement,-1,&statement,NULL) == SQLITE_OK) {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                NSString *ID = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
                NSString *alertType = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,1)];
                NSString *resourceType = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,2)];
                NSString *createdAt = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,3)];
                NSString *latitude = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,4)];
                NSString *longitude = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,5)];
                
                NSMutableDictionary * row = [[NSMutableDictionary alloc] init];
                [row setValue:ID forKey:k_Db_Id];
                [row setValue:alertType forKey:kAlert_type];
                [row setValue:resourceType forKey:kResourceTypeKey];
                [row setValue:createdAt forKey:Kcreated_at];
                [row setValue:latitude forKey:klatitudeKey];
                [row setValue:longitude forKey:kLongitudeKey];
                [panicServices addObject:row];
            }
        }
    }
    sqlite3_close(_DB);
    return panicServices;
}

@end
