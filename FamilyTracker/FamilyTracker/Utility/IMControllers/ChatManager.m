//
//  XMPPManager.m
//  JabberClient
//
//  Created by Qaium Hossain on 1/14/15.
//
//

#import "ChatManager.h"
#import "GCDAsyncSocket.h"
#import "NSString+Utils.h"
#import "MPNotificationView.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "GlobalData.h"
#import "GlobalServiceManager.h"
#import "ChatViewController.h"
#import "ModelManager.h"
#import "Common.h"

@interface ChatManager()

- (void)setupStream;

- (void)goOnline;
- (void)goOffline;

@end

@implementation ChatManager

@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRoom;
@synthesize xmppMuc;
@synthesize roomJID;
@synthesize _chatDelegate;
@synthesize _messageDelegate;
@synthesize msgDictionary;

static ChatManager *gInstance = nil;
+ (ChatManager *)instance {
    @synchronized(self) {
        if (gInstance == nil) {
            gInstance = [[ChatManager alloc] init];
            
        }
    }
    return gInstance;
}

- (void)setupStream {
    if (self.xmppStream) {
        NSLog(@"already initialized");
    }
    else {
        
        xmppStream = [[XMPPStream alloc] init];
        
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //[xmppStream setHostName:@"52.8.171.170"];
//        [xmppStream setHostName:EJABBER_HOST_NAME];
        [xmppStream setHostName:[ModelManager sharedInstance].user.chatSetting.ipAddress];
        [xmppStream setHostPort:5222];
        
        XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage   sharedInstance];
        //NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
        
        XMPPMessageArchiving *xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:storage];
        [xmppMessageArchivingModule activate:xmppStream];
        [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    [self setupStream];
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ID_FULL_KEY_SMALL];
    
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kPasswordKey];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    
    if (jabberID == nil || myPassword == nil) {
        
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    NSLog(@"jid=%@",xmppStream.myJID);
    password = myPassword;
    
    NSError *error = nil;
    
    BOOL connected = [xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    //if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    if (!connected)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    if (self.xmppStream.isSecure) {
        NSLog(@"secure connection");
    }
    
    return YES;
}

- (void)disconnect {
    
    [self goOffline];
    [xmppStream disconnect];
    [_chatDelegate didDisconnect];
}

- (void)sendMessage:(DDXMLElement *)message {
    //[self.xmppStream sendElement:message];
    delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (delegate.isConference==1) {
        NSLog(@"send msg to room");
        [self.xmppRoom sendMessage:(XMPPMessage *)message];
    }
    else{
        [self.xmppStream sendElement:message];
    }
}

- (void)addTrunkToChatUser:(NSString *)chatUser{
    turnSockets = [[NSMutableArray alloc] init];
    XMPPJID *jid = [XMPPJID jidWithString:chatUser];    
    NSLog(@"Attempting TURN connection to %@", jid);
    
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:self.xmppStream toJID:jid];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void) addBuddy:(NSString *)buddyName {    
    XMPPJID *newBuddy = [XMPPJID jidWithString:buddyName];
    
    [self.xmppRoster addUser:newBuddy withNickname:buddyName];
}

#pragma mark - Trunk Socket Delegates -

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
    
    [turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
    NSLog(@"TURN Connection failed!");
    [turnSockets removeObject:sender];
}


#pragma mark -
#pragma mark XMPP delegates

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    completionHandler(YES);
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"server secured");
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
     settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:&error];
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"disconnecting");
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"time out");
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    [self goOnline];
    [self._chatDelegate didAuthenticate];
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"XMPP Authentication Error: %@",error);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"%@", [iq description]);
    
    NSXMLElement *queryElement = [iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    
    NSArray *items = [queryElement elementsForName:@"item"];
    for (NSXMLElement *i in items) {
        NSString *roomName = [i attributeStringValueForName:@"name"];
        NSString *jidString = [i attributeStringValueForName:@"jid"];
        XMPPJID *jid = [XMPPJID jidWithString:jidString];
    }
    
    return NO;
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *delay = (NSString*)[message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];//contains value if incoming message is history message for room,otherwise it will nil
    NSString *msgType = [[message attributeForName:@"type"] stringValue];
    NSString *msg = @"";

    msg = [[message elementForName:@"body"] stringValue];
    NSXMLElement *propertiesElement = [message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
//    NSArray *propertyElementArr = [propertiesElement elementsForName:@"property"];
//    NSString *str = (NSString*)[propertiesElement elementForName:@"property" xmlnsPrefix:kMsgResourceTypeKey];
    NSArray *propertyArray = (NSArray*)[propertiesElement elementsForName:@"property"];
    if ([propertyArray count] < 2) return;
    NSXMLElement *propertyElement = [[propertiesElement elementsForName:@"property"] objectAtIndex:0];
    NSString *dataType = [[propertyElement elementForName:@"value"] stringValue];

    if (dataType) {
        msg = [[message elementForName:@"body"] stringValue];
        if (!delay) {// if not history room message
            NSString *sender; //message sender contains only user name
            NSString *from = [[message attributeForName:@"from"] stringValue];
            NSString *to = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ID_FULL_KEY_SMALL];
            NSLog(@"to=%@",to);
            from = [[from componentsSeparatedByString:@"/"] objectAtIndex:0];
            
            if ([msgType isEqualToString:kGroupChatKey]) {//check for conference message
                NSArray *buddyNameParts = [from componentsSeparatedByString:@"@"];
                from = buddyNameParts[0];
                sender = [[message attributeForName:@"from"] stringValue];
                sender = [[sender componentsSeparatedByString:@"/"]objectAtIndex:1];
            } else {
                sender = from;
            }
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [msgDic setObject:sender forKey:kSenderKey];
            [msgDic setObject:msg forKey:kMsgKey];
            [msgDic setObject:msgType forKey:kMsgTypeKey];
            [msgDic setObject:dataType forKey:kMsgResourceTypeKey];
            
            if (self._messageDelegate) {
                
            } else {
                NSLog(@"message delegate nil");
            }
            
            if ([msgType isEqualToString:kGroupChatKey]) {
                NSLog(@"conference message");
            } else {
                [_messageDelegate newMessageReceived:msgDic];
            }
        }
    }//end if
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, [ModelManager sharedInstance].user.chatSetting.hostName]];
            //[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, [ModelManager sharedInstance].user.chatSetting.hostName]];
            //[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
            
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    NSLog(@"XMPP Error: %@",error);
}



#pragma mark conference

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"room created");
    //[self bookMark:@"TestGroup4"];
    [self enterRoom:self.xmppStream.myJID.user];
    /*ModelManager *modelManager = [ModelManager sharedInstance];
    NSString *userFullName = @"";
    if (modelManager.user.lastName==nil || modelManager.user.lastName == (id)[NSNull null] || [modelManager.user.lastName isEqualToString:@""] || modelManager.user.lastName.length==0) {
        userFullName = [NSString stringWithFormat:@"%@",modelManager.user.firstName];
    }
    else {
        userFullName = [NSString stringWithFormat:@"%@ %@",modelManager.user.firstName,modelManager.user.lastName];
    }
   
    [self enterRoom:userFullName];*/
    
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"Leave room");
    [self.xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.xmppRoom = nil;
    [self.xmppMuc deactivate];
    [self.xmppMuc removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.xmppMuc = nil;
    
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"destroy room");
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    NSLog(@" joined the newly created room");
    [sender fetchConfigurationForm];
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [sender configureRoomUsingOptions:newConfig];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    //[sender inviteUser:[XMPPJID jidWithString:@"qaium12"] withMessage:@"Greetings!"];
    //[self showAlert:@"Room Created And Configured. Invite Users Now"];
    //[self inviteUsers:sender];
    
    /*for(int i = 0; i < self.groupContacts.count; i++)
    {
        NSString* contactNumber = [[self.groupContacts objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSLog(@"Group Number = %@", contactNumber);
        
        XMPPJID *inviteJid=[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@abcserver", contactNumber]];
        
        [sender inviteUser:inviteJid withMessage:@"Join Chat Group."];
    }*/
}

- (void)createRoom : (NSString *)groupName
{
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.xmppRoom removeDelegate:self];
    [self.xmppMuc removeDelegate:self];
    
    XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc] init];
    
    /**
     * Remember to add 'conference' in your JID like this:
     * e.g. uniqueRoomJID@conference.yourserverdomain
     */
    
    self.roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",groupName,[ModelManager sharedInstance].user.chatSetting.hostName]];
    //self.roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.localhost",groupName]];
    self.xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage
                                                      jid:self.roomJID
                                            dispatchQueue:dispatch_get_main_queue()];
    
    
    
    [self.xmppRoom activate:[self xmppStream]];
    
    
    [self.xmppRoom addDelegate:self
                 delegateQueue:dispatch_get_main_queue()];
    
    
    
    NSLog(@"my jid=%@",self.xmppStream.myJID.user);
    
    self.xmppMuc = [[XMPPMUC alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppMuc activate:[self xmppStream]];
    
    [self.xmppMuc addDelegate:self
                delegateQueue:dispatch_get_main_queue()];
    
    [self enterRoom:self.xmppStream.myJID.user];
    /*ModelManager *modelManager = [ModelManager sharedInstance];
    NSString *userFullName = @"";
    if (modelManager.user.lastName==nil || modelManager.user.lastName == (id)[NSNull null] || [modelManager.user.lastName isEqualToString:@""] || modelManager.user.lastName.length==0) {
        userFullName = [NSString stringWithFormat:@"%@",modelManager.user.firstName];
    }
    else {
        userFullName = [NSString stringWithFormat:@"%@ %@",modelManager.user.firstName,modelManager.user.lastName];
    }
    
    [self enterRoom:userFullName];*/
    
}

- (void)enterRoom:(NSString *)userFullName
{
    /*NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    
    [presence addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",self.xmppStream.myJID]];
    [presence addAttributeWithName:@"id" stringValue:@"n13mt3l"];
    [presence addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@/%@",self.roomJID,userFullName]];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];

    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    //[history addAttributeWithName:@"maxstanzas" stringValue:@"25"];
    NSString *seconds = [NSString stringWithFormat:@"%d",5*24*60*60];
    [history addAttributeWithName:@"seconds" stringValue:seconds];

    [x addChild:history];
    [presence addChild:x];*/
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    //[history addAttributeWithName:@"maxstanzas" stringValue:@"25"];
    NSString *seconds = [NSString stringWithFormat:@"%d",5*24*60*60];
    [history addAttributeWithName:@"seconds" stringValue:seconds];
    [self.xmppRoom joinRoomUsingNickname:userFullName history:history];
}

- (void)destroyRoom
{
    [self.xmppRoom leaveRoom];
    [self.xmppRoom destroyRoom];
    
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message
{
    NSLog(@"receive room invitation");
}

- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message
{
//    NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
//    NSXMLElement * invite  = [x elementForName:@"invite"];
    /*if (!isEmpty(invite))
    {
        NSString * conferenceRoomJID = [[message attributeForName:@"from"] stringValue];
        [self joinMultiUserChatRoom:conferenceRoomJID];
        
    }*/
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    NSString *msg = [[message elementForName:@"body"] stringValue];
    
    NSXMLElement *delayElement = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
    NSString *delay = (NSString *)delayElement;
    NSString *msgTime = @"";
    if (delay) {
        msgTime = [[delayElement attributeForName:@"stamp"] stringValue];
        msgTime = [Common getEpochTimeFromServerTime:msgTime];
    } else {
        
        NSXMLElement *propertiesElement = [message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
        NSArray *propertyArray = (NSArray*)[propertiesElement elementsForName:@"property"];
        if ([propertyArray count]<2) return;
        NSXMLElement *propertyElement = [[propertiesElement elementsForName:@"property"] objectAtIndex:1];
        msgTime = [[propertyElement elementForName:@"value"] stringValue];
    }

    NSString *msg_sender; //message sender contains only user name
    NSString *from = [[message attributeForName:@"from"] stringValue];
    msg_sender = [[from componentsSeparatedByString:@"/"] objectAtIndex:0];

    NSArray *buddyNameParts = [msg_sender componentsSeparatedByString:@"@"];
    msg_sender = buddyNameParts[0];
    msg_sender = [[message attributeForName:@"from"] stringValue];
    msg_sender = [[msg_sender componentsSeparatedByString:@"/"] objectAtIndex:1];
    //---Message Element-1---//
    NSXMLElement *propertiesElement = [message elementForName:@"properties" xmlns:@"http://www.jivesoftware.com/xmlns/xmpp/properties"];
    NSArray *propertyArray = (NSArray*)[propertiesElement elementsForName:@"property"];
    if ([propertyArray count]<2) return;
    //
    NSXMLElement *propertyElement = [[propertiesElement elementsForName:@"property"] objectAtIndex:0];
    NSString *resourceType = [[propertyElement elementForName:@"value"] stringValue];
    if (resourceType == nil || [resourceType isEqual:(id)[NSNull null]]) {
        return;
    }
    if ([occupantJID.resource isEqualToString:self.xmppStream.myJID.user]) {
        [m setObject:msg forKey:kMsgKey];
        [m setObject:from forKey:kSenderKey];
        [m setObject:msg_sender forKey:kSenderNameKey];
        [m setObject:msgTime forKey:kTimeStampKey];
        [m setObject:resourceType forKey:kMsgResourceTypeKey];
        if (delay) {
            //NSLog(@"history msg send by me");
            [[GlobalData sharedInstance].messages addObject:m];
        } else {
            //NSLog(@"Runtime message send by me");
        }
    }
    else {
        //NSLog(@"message from other");
        if (msg) {
                //NSString *from = [[message attributeForName:@"from"] stringValue];
                //NSString *dataType = [[message attributeForName:kMsgResourceTypeKey] stringValue];
                NSString *to = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ID_FULL_KEY_SMALL];
                NSLog(@"to=%@",to);
                //from = [[from componentsSeparatedByString:@"/"]objectAtIndex:0];
                
                [m setObject:msg forKey:kMsgKey];
                [m setObject:from forKey:kSenderKey];
                [m setObject:msg_sender forKey:kSenderNameKey];
                [m setObject:msgTime forKey:kTimeStampKey];
                [m setObject:resourceType forKey:kMsgResourceTypeKey];
                NSLog(@"active chat view=%d",delegate.isActiveChatView);
                if (delay) {
                    NSLog(@"history msg send by other");
                    [[GlobalData sharedInstance].messages addObject:m];
                } else {
                    NSLog(@"Runtime message send by other");
                    if ([[ModelManager sharedInstance].user.settings[kChatPostPermission] boolValue]) {
                    //if ([[GlobalServiceManager sharedInstance] isSettingOnByMemberId:[ModelManager sharedInstance].user.identifier withSettingItemId:kChatPostPermission]) {
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                            UILocalNotification * notification = [[UILocalNotification alloc] init];
                            
                            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.0];
                            notification.timeZone = [[NSCalendar currentCalendar] timeZone];
                            NSString *notiBodyStr = [NSString stringWithFormat:@"%@: %@",msg_sender,msg];
                            notification.alertBody = NSLocalizedString(notiBodyStr, nil);
                            notification.hasAction = YES;
                            notification.alertAction = NSLocalizedString(@"View", nil);
                            notification.soundName = @"SentMessage.wav";
                            [notification setCategory:@"custom_category_id"];
                            notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber +1;
                            
                            notification.userInfo = @{kAlert_type : kAlert_type_chat,
                                                      kLink : @"",
                                                      kMsgResourceTypeKey : resourceType};
                            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                            NSLog(@"%lu",(unsigned long)[GlobalData sharedInstance].messages.count);
                            [[GlobalData sharedInstance].messages addObject:m];
                            NSLog(@"%lu",(unsigned long)[GlobalData sharedInstance].messages.count);
                        }
                        else {
                            if (delegate.isActiveChatView == 1) {
                                [_messageDelegate newRoomMessageReceived:m];
                            }
                            else {
                                [[GlobalData sharedInstance].messages addObject:m];
                                [MPNotificationView notifyWithText:msg_sender
                                                        detail:msg
                                                 andTouchBlock:^(MPNotificationView *notificationView) {
                                                     //NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
                                                     [[GlobalServiceManager sharedInstance] gotoChatViewController];
                                                 }];
                            }
                        }
                    }
                }
            }
    }
    //[_messageDelegate newRoomMessageReceived:m];
}

- (void) getListOfGroups
{
    [self.xmppRoom removeDelegate:self];
    [self.xmppMuc removeDelegate:self];

    [self.xmppRoom addDelegate:self
                 delegateQueue:dispatch_get_main_queue()];
    NSLog(@"my jid=%@",self.xmppStream.myJID.user);
    
    self.xmppMuc = [[XMPPMUC alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppMuc activate:[self xmppStream]];
    
    [self.xmppMuc addDelegate:self
                delegateQueue:dispatch_get_main_queue()];
    
    NSString* server = [NSString stringWithFormat:@"conference.%@",[ModelManager sharedInstance].user.chatSetting.hostName];//@"conference.aphelia.com";//@"54.148.21.160"; //or whatever the server address for muc is
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
    
}

-(void)bookMark :(NSString *)roomName{
    
    XMPPIQ *iq = [[XMPPIQ alloc]init];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:private"];
    NSXMLElement *storage =   [NSXMLElement elementWithName:@"storage" xmlns:@"storage:bookmarks"];
    NSXMLElement *conference_s = [NSXMLElement elementWithName:@"conference"];
    [conference_s addAttributeWithName:@"autojoin" stringValue:@"true"];
    [conference_s addAttributeWithName:@"jid" stringValue:roomName];
    [storage addChild:conference_s];
    [query addChild:storage];
    [iq addChild:query];
    NSLog(@"print eml log %@:",iq);
    [xmppStream sendElement:iq];
}

- (void)setupMuc
{
    self.xmppMuc = nil;
    [self.xmppMuc removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.xmppMuc = [[XMPPMUC alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppMuc activate:[self xmppStream]];
    
    [self.xmppMuc addDelegate:self
                delegateQueue:dispatch_get_main_queue()];
}

- (NSArray*)loadChatHistoryWithUserName:(NSString *)userName
{
    NSString *userJid = userName;//[NSString stringWithFormat:@"%@@%@",userName,@"aphelia.com"];
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error;
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, userJid];
    request.predicate = predicate;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    NSLog(@"messages=%@",messages);
    [self print:messages :userName];
    return messages;
}

-(void)print:(NSArray*)messages_arc : (NSString *)userName {
       NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
            
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:message.body forKey:@"msg"];
            
            if ([[element attributeStringValueForName:@"to"] isEqualToString:userName]) {
                [m setObject:@"you" forKey:@"sender"];
            }
            else {
                [m setObject:userName forKey:@"sender"];
            }
            
            [messages addObject:m];
            
            NSLog(@"bareJid param is %@",message.bareJid);
            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
            NSLog(@"timestamp param is %@",message.timestamp);
            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
            NSLog(@"***************************************************");
        }
}

#pragma mark - User Defined Methods -
- (void)leaveRoom {
    [self.xmppRoom leaveRoom];
    [self disconnect];
}

@end
