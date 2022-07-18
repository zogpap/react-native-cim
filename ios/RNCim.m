
#import "RNCim.h"
#import "RCTAssert.h"
#import "RCTUtils.h"
#import "RCTLog.h"

static NSString *_devicetoken=nil;




@implementation RNCim

NSString *const EVENT_MSG_NAME = @"CIMMESSAGELISTER";
NSString *const EVENT_CONNECT_NAME = @"CIMCONNECTLISTER";

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
     return @true;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(disconnect) {
     
  [[CIMService instance] disconnect];
     return @true;
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(enterForeground) {
     
  [[CIMService instance] enterForeground];
     return @true;
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(enterBackground) {
     
  [[CIMService instance] enterBackground];
     return @true;
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
    NSLog(@"cimDidConnectError%@",[error localizedDescription]);
    
    NSDictionary *json = @{
                            @"type": @"2",
                            @"title": @"cimDidConnectError",
                            @"error": [error localizedDescription]
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
    
     NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
     if (msg) {
          if (msg.action) {
               [msgDic setObject:msg.action forKey:@"action"];
          }
          if (msg.content) {
               [msgDic setObject:msg.content forKey:@"content"];
          }
          if (msg.extra) {
               [msgDic setObject:msg.extra forKey:@"extra"];
          }
          if (msg.format) {
               [msgDic setObject:msg.format forKey:@"format"];
          }
          if (msg.id_p) {
               [msgDic setObject:[NSNumber numberWithLong:msg.id_p] forKey:@"id_p"];
          }
          if (msg.receiver) {
               [msgDic setObject:msg.receiver forKey:@"receiver"];
          }
          if (msg.sender) {
               [msgDic setObject:msg.sender forKey:@"sender"];
          }
          if (msg.timestamp) {
               [msgDic setObject:[NSNumber numberWithLong:msg.timestamp] forKey:@"timestamp"];
          }
          if (msg.title) {
               [msgDic setObject:msg.title forKey:@"action"];
          }
     }
    NSDictionary *json = @{
                            @"type": @"1",
                            @"msg":msgDic,
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
  
