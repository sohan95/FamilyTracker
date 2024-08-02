//
//  JsonUtil.m
//  CallCoreRnD
//
//  Created by makboney Ltd on 2/4/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JsonUtil.h"
#import "JSONModel.h"
#import <objc/runtime.h>
@implementation JsonUtil

+ (id)loadObject:(NSString *)className withStringData:(NSString *)strData{
    return [[NSClassFromString(className) alloc] initWithString:strData];
}

+ (id)loadObject:(NSString *)className withFile:(NSString *)fileName andReset:(BOOL)reset{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//gets the list of directories in searchpath
    NSString *docDir = [paths objectAtIndex:0];//gets the root document directory
    NSString *jsonDocDir = [[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",JSON_KEY,fileName]] stringByAppendingPathExtension:JSON_KEY];//gets string for path with file name and extention
    NSLog(@"jsonDocDir %@",jsonDocDir);
    @try {
        BOOL fileExists = [fileManager fileExistsAtPath:jsonDocDir];//returns true if file exists
        NSLog(@" %d ",fileExists);
        NSError *error = nil;
        
        //if file doesn't exist, 
        if (!fileExists) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:JSON_KEY];
            if (filePath) {
                BOOL dirExists,isDirectory;
                dirExists = [fileManager fileExistsAtPath:[docDir stringByAppendingPathComponent:JSON_KEY]isDirectory:&isDirectory];
                if (dirExists) {
                    BOOL fileSaved = [fileManager copyItemAtPath:filePath toPath:jsonDocDir error:&error];//copy file to directory
                    if (!fileSaved) return nil;
                }else{
                    [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:JSON_KEY] withIntermediateDirectories:NO attributes:nil error: &error];
                    BOOL fileSaved = [fileManager copyItemAtPath:filePath toPath:jsonDocDir error:&error];//copy file to directory
                    if (!fileSaved) return nil;
                }
            }
        }
        NSString *fileJsonStr = [NSString stringWithContentsOfFile:jsonDocDir encoding:NSUTF8StringEncoding error:&error];
        id Object;
        if (fileJsonStr) {
            NSError *error = nil;
            Object = [[NSClassFromString(className) alloc] initWithString:fileJsonStr error:&error];
        }
        return Object;
    }
    @catch (NSException *exception) {
        [self loadObject:className withFile:fileName andReset:YES];
    }
    @finally {
        
    }
    if (reset) {
        NSData *jsonData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        [jsonData writeToURL:[NSURL URLWithString:jsonDocDir] atomically:YES];
    }else{
        [self loadObject:className withFile:fileName andReset:YES];
    }
}

+ (id)loadObject:(NSString *)className withFile:(NSString *)fileName{
    return [self loadObject:className withFile:fileName andReset:NO];
}

+ (void)saveObject:(id)object withFile:(NSString *)fileName {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *jsonDocDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:JSON_KEY];
    NSString *filePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",JSON_KEY,fileName]] stringByAppendingPathExtension:JSON_KEY];
    NSLog(@"jsonDocDir %@",filePath);

    //TODO::Create file direcotory if not exists
    BOOL isFile=NO,isDir=NO;
    isFile = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!isFile && !isDir) {
        isFile = [fileManager fileExistsAtPath:jsonDocDir isDirectory:&isDir];
        if (!isDir) {
            isDir = [fileManager createDirectoryAtPath:jsonDocDir withIntermediateDirectories:NO attributes:nil error:&error];
        }
        if (isDir) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:fileName ofType:JSON_KEY] toPath:filePath error:&error];
        }
    }
    NSLog(@"jsonDocDir %@",filePath);
    NSString *jsonData = [(JSONModel *)object toJSONString];
    [jsonData writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@",error);
}

+ (id)load:(NSString *)className andDataDictionary:(NSDictionary *)dataDictionary{
    id Object;
    if(dataDictionary){
        NSMutableArray *propertyKeys = [NSMutableArray array];
        Class theClass = NSClassFromString(className);
        Object = [[theClass alloc] init];
        while ([theClass superclass]) { // avoid printing NSObject's attributes
            unsigned int outCount, i;
            objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
            for (i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                const char *propName = property_getName(property);
                if (propName) {
                    NSString *propertyName = [NSString stringWithUTF8String:propName];
                    [propertyKeys addObject:propertyName];
                }
            }
            free(properties);
            theClass = [theClass superclass];
        }
    }
    for (NSString *key in [dataDictionary allKeys]) {
        if (!(key == (id)[NSNull null]) || [dataDictionary[key] length] != 0 ){
            [Object setValue:dataDictionary[key] forKey:key];
        }else{
            NSLog(@"key %@",key);
        }
    }
    return Object;
}
@end
