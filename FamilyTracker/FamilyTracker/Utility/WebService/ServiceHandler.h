//
//  ServiceHandler.h
//  CamConnect
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelManager.h"
#import "Updater.h"
#import "Progress.h"
#import "Http.h"
#import "ReplyHandler.h"
#import "GlobalData.h"

@interface ServiceHandler : NSObject {
    ModelManager *_modelManager;
    Http *_http;
    id<Progress> _progress;
}
- (id)initWithReplyHandler:(ReplyHandler *)handler;
- (void)onOperate:(id)msg;

@end
