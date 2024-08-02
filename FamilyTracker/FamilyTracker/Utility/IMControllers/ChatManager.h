//
//  XMPPManager.h
//  JabberClient
//
//  Created by Qaium Hossain on 1/14/15.
//
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"
#import "XMPPFramework.h" 
#import "XMPPRoster.h"
#import "XMPP.h"
#import "TURNSocket.h"
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"
#import "FamilyTrackerDefine.h"

//Conference
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"
#import "XMPPMUC.h"

#import "AppDelegate.h"
#import "FamilyTrackerDefine.h"

@interface ChatManager : NSObject<XMPPMUCDelegate> {
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    
    NSString *password;
    
    BOOL customCertEvaluation;
    
    BOOL isXmppConnected;
    
    BOOL isOpen;
    
    NSMutableArray *turnSockets;
    
    //NSMutableDictionary *newMsg;
    
    __strong NSObject <SMChatDelegate> *_chatDelegate;
    __strong NSObject <SMMessageDelegate> *_messageDelegate;
    
    AppDelegate *delegate;
}

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) id _chatDelegate;
@property (nonatomic, strong) id _messageDelegate;

@property (nonatomic, retain) NSMutableDictionary *msgDictionary; //contains msg history

@property (nonatomic, strong) XMPPJID *roomJID;
@property (nonatomic, strong) XMPPJID *serverJID;
@property (nonatomic, strong) XMPPRoom *xmppRoom;
@property (nonatomic, strong) XMPPMUC *xmppMuc;



+ (ChatManager *)instance;
- (BOOL)connect;
- (void)disconnect;
- (void)sendMessage:(DDXMLElement *)message;
- (void)addBuddy:(NSString *)buddyName;
- (void)addTrunkToChatUser:(NSString *)chatUser;


//Conference
- (void)setupMuc;
- (void)createRoom : (NSString *)groupName;
- (void)enterRoom: (NSString *)userFullName;
- (void)destroyRoom;
- (void)leaveRoom;
- (void) getListOfGroups;
-(void)bookMark :(NSString *)roomName;
//History
- (NSArray*)loadChatHistoryWithUserName:(NSString *)userName;

@end
