
#import "UserDefaults.h"

@implementation UserDefaults

- (id)init
{
	self = [super init];
    
    if(self)
    {
		defaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

- (NSString *)getStringWithKey: (NSString*)key
{
	return [defaults stringForKey:key];
}

- (void)removeValueForKey:(NSString *)key
{
	[defaults removeObjectForKey:key];
	[defaults synchronize];
}

- (void)setStringWithKey: (NSString*)key andValue:(NSString*)value
{
	[defaults setObject:value forKey:key];
    [self synchronize];
}

- (void)synchronize
{
	[defaults synchronize];
}

@end
