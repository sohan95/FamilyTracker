
#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject
{
    NSUserDefaults* defaults;
}

- (NSString*)getStringWithKey: (NSString*)key;
- (void)setStringWithKey: (NSString*)key andValue:(NSString*)value;
- (void)removeValueForKey:(NSString *)key;

@end
