//
//  GlobalData.m
//  InstantConnect
//
//  Created by Qaium Hossain on 5/11/16.
//  Copyright © 2016 Cisco Systems Confidential - SPG. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData


static GlobalData *instance=nil;

- (instancetype)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}

+ (GlobalData *)sharedInstance {
    @synchronized(self) {
        if (!instance)
            instance = [[self alloc] init];
    }
    return instance;
}

- (void)reset {
    self.messages = [[NSMutableArray alloc] init];
    self._allAlertFullList = [[Notifications alloc] init];
    self.isJabberLogedIn = NO;
    self.isLiveStreamingView = NO;
    self.roomName = [NSString new];
    self.currentVC = [[UIViewController alloc] init];
    self.profilePicture = [UIImage imageNamed:@"defaultUserIcon"];
    self.isInPanic = NO;
    self.userLocation = [[LocationModel alloc] init];
    self._videoThumbnailCache = [[NSCache alloc] init];
}

- (NSString*)stringFromEpochTime:(NSTimeInterval)epochTime {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:((epochTime) / 1000)];
    NSDateFormatter *dtfrm = [[NSDateFormatter alloc] init];
    [dtfrm setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSString * formattedDate = [dtfrm stringFromDate:date];
    return formattedDate;
}

@end
