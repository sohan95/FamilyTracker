//
//  OnvifNamespaceKeyBuilder.h
//  CiscoOnvifPlayer
//
//  Created by einfochips on 15/10/14.
//  Copyright (c) 2014 eInfochips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnvifNamespaceKeyBuilder : NSObject
{
    NSString *discoveryNamespace;
    NSString *deviceNamespace;
    NSString *mediaNamespace;
    NSString *schemaNamespace;
    NSString *ptzNamespace;
}

- (void)getServiceNamespace:(NSDictionary *)responseDic;
- (NSString *)discoveryKey:(NSString *)key;
- (NSString *)deviceKey:(NSString *)key;
- (NSString *)mediaKey:(NSString *)key;
- (NSString *)schemaKey:(NSString *)key;
- (NSString *)ptzKey:(NSString *)key;
@end
