
#import "RNCim.h"
#import "CIMHeader.h"

#import "SocketRocket.h"

#import "GCDAsyncSocket.h"
#import "SentBody.pbobjc.h"
#import "Message.pbobjc.h"
#import "NSData+IM.h"
#import "NSString+IM.h"

static NSString _devicetoken=nil;


@interface RNCim : NSObject <GCDAsyncSocketDelegate,CIMPeerMessageObserver,CIMConnectionObserver>
{
    BOOL isObserving;
}
@property (strong, nonatomic) NSString *sockethost;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *apibase;

@end

@implementation RNCim

NSString *const EVENT_MSG_NAME = "CIMMESSAGELISTER";
NSString *const EVENT_CONNECT_NAME = "CIMCONNECTLISTER";

+(RNCim*)instance {
    static RNCim *imService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imService) {
            imService = [[RNCim alloc] init];
        }
    });
    return imService;
}

-(id) init {
    if (self = [super init]) {
       isObserving = NO;
   }
   return self;
}

- (void)setDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenBytes = [deviceToken bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"deviceToken:%@",hexToken);
    _devicetoken = hexToken;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[EVENT_MSG_NAME,EVENT_CONNECT_NAME];
}

- (void)startObserving {
    isObserving = YES;
}

-(void)stopObserving {
    isObserving = NO;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();


- (void) msglistener:(NSNotification *) notification
{
    if (isObserving) {
        [self sendEventWithName:EVENT_MSG_NAME body:notification.userInfo];
    }
}


- (void) connectlistener:(NSNotification *) notification
{
    if (isObserving) {
        [self sendEventWithName:EVENT_CONNECT_NAME body:notification.userInfo];
    }
}

RCT_REMAP_METHOD(init,sockethost:(NSString *)sockethost port:(NSString *)port apibase:(NSString *)apibase )
{
    self.sockethost = sockethost;
    self.port = port;
    self.apibase = apibase;
  [[CIMService instance] configHost:sockethost onPort:[port integerValue]];
}

RCT_REMAP_METHOD(connectionBindUserId,usid:(NSString *)usid callback2:(RCTResponseSenderBlock) callback)
{
  [[CIMService instance] connectionBindUserId:usid];
  callback(@[@(1)]);
}


RCT_EXPORT_METHOD(setMsgListener)
{
    [[CIMService instance] addMessageObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msglistener:) name:EVENT_MSG_NAME object:nil];
}

RCT_EXPORT_METHOD(removeMessageListener)
{
    [[CIMService instance] removeMessageObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_MSG_NAME object:nil];
}

RCT_EXPORT_METHOD(setConnectListener)
{
    [[CIMService instance] addConnectionObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectlistener:) name:EVENT_CONNECT_NAME object:nil];
}

RCT_EXPORT_METHOD(removeConnectListener)
{
    [[CIMService instance] removeConnectionObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_CONNECT_NAME object:nil];
    
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(reconnect) {
     
  [[CIMService instance] reconnect];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(disconnect) {
     
  [[CIMService instance] disconnect];
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(enterForeground) {
     
  [[CIMService instance] enterForeground];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(enterBackground) {
     
  [[CIMService instance] enterBackground];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getDeviceToken) {
     
  return _devicetoken;
}

- (void)dealloc{
    [[CIMService instance] removeMessageObserver:self];
    [[CIMService instance] removeConnectionObserver:self];
    [[CIMService instance] disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_MSG_NAME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_CONNECT_NAME object:nil];

}


#pragma mark CIMPeerMessageObserver,CIMConnectionObserver
- (void)cimDidConnectClose{
    NSLog(@"cimDidConnectClose");
    NSDictionary *json = @{
                            @"type": @"0",
                            @"title": @"cimDidConnectClose",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CONNECT_NAME object:nil userInfo:json];
}

- (void)cimDidConnectError:(NSError *)error{
    NSLog(@"cimDidConnectError");
    
    NSDictionary *json = @{
                            @"type": @"2",
                            @"title": @"cimDidConnectError",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CONNECT_NAME object:nil userInfo:json];

}

- (void)cimDidConnectSuccess{
    NSLog(@"cimDidConnectSuccess");
    
    NSDictionary *json = @{
                            @"type": @"1",
                            @"title": @"cimDidConnectSuccess",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CONNECT_NAME object:nil userInfo:json];

}

- (void)cimDidBindUserSuccess:(BOOL)bindSuccess{
    NSLog(@"cimDidBindUserSuccess");
    
    NSDictionary *json = @{
                            @"type": @"3",
                            @"title": @"cimDidBindUserSuccess",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CONNECT_NAME object:nil userInfo:json];

}

- (void)cimHandleMessage:(CIMMessageModel *)msg{
    NSLog(@"ViewController:%@\nu用户：%@(%lld)\n---------",msg.content,msg.sender,msg.timestamp);
    
    NSDictionary *json = @{
                            @"type": @"1",
                            @"msg":msg,
                            @"title": @"cimCommonMsgSucess",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_MSG_NAME object:nil userInfo:json];

}
- (void)cimHandleMessageError:(NSData *)data{
    NSLog(@"cimHandleMessageError");
    
    NSDictionary *json = @{
                            @"type": @"0",
                            @"title": @"cimHandleMessageError",
                          };
   [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_MSG_NAME object:nil userInfo:json];

}

@end
  