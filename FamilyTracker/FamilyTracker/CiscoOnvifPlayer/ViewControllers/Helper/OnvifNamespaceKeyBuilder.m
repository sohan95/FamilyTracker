//
//  OnvifNamespaceKeyBuilder.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 15/10/14.
//  Copyright (c) 2014 eInfochips. All rights reserved.
//

#import "OnvifNamespaceKeyBuilder.h"

@implementation OnvifNamespaceKeyBuilder


//Get serviceNamespace
- (void)getServiceNamespace:(NSDictionary *)responseDic
{
    //Traverse through responseDic
    for (NSString *key in [responseDic allKeys])
    {
        NSString *value = [responseDic valueForKey:key];
        if (![value isKindOfClass:[NSString class]]) {
            continue;
        }
        
        //Match key with predefined pattern and get its Namespace
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"(/discovery)$"
                                      options:0
                                      error:nil];

        if ([regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1)
        {
            discoveryNamespace = [[key componentsSeparatedByString:@":"] count] == 2 ? [[key componentsSeparatedByString:@":"] objectAtIndex:1]:@"";
            continue;
        }
        regex = [NSRegularExpression
                 regularExpressionWithPattern:@"(/device/wsdl)$"
                 options:0
                 error:nil];
        
        if ([regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1)
        {
            deviceNamespace = [[key componentsSeparatedByString:@":"] count] == 2 ? [[key componentsSeparatedByString:@":"] objectAtIndex:1]:@"";
            continue;
        }
        
        regex = [NSRegularExpression
                 regularExpressionWithPattern:@"(/schema)$"
                 options:0
                 error:nil];
        
        if ([regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1)
        {
            schemaNamespace = [[key componentsSeparatedByString:@":"] count] == 2 ? [[key componentsSeparatedByString:@":"] objectAtIndex:1]:@"";
            continue;
        }
        
        regex = [NSRegularExpression
                 regularExpressionWithPattern:@"(/media/wsdl)$"
                 options:0
                 error:nil];
        
        if ([regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1)
        {
            mediaNamespace = [[key componentsSeparatedByString:@":"] count] == 2 ? [[key componentsSeparatedByString:@":"] objectAtIndex:1]:@"";
            continue;
        }
        
        regex = [NSRegularExpression
                 regularExpressionWithPattern:@"(/ptz/wsdl)$"
                 options:0
                 error:nil];
       
        if ([regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])] == 1)
        {
            ptzNamespace = [[key componentsSeparatedByString:@":"] count] == 2 ? [[key componentsSeparatedByString:@":"] objectAtIndex:1]:@"";
            continue;
        }
    }
}

//genrate discoveryKey for given key using discovery namespace
- (NSString *)discoveryKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@:%@",discoveryNamespace,key];
}

//genrate deviceKey for given key using device namespace
- (NSString *)deviceKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@:%@",deviceNamespace,key];
}

//genrate mediaKey for given key using media namespace
- (NSString *)mediaKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@:%@",mediaNamespace,key];
}

//genrate schemaKey for given key using schema namespace
- (NSString *)schemaKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@:%@",schemaNamespace,key];
}

- (NSString *)ptzKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@:%@",ptzNamespace,key];
}

@end
