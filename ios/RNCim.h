/*
 * @Author: zogpap zogpap@163.com
 * @Date: 2022-07-13 12:24:48
 * @LastEditors: zogpap zogpap@163.com
 * @LastEditTime: 2022-07-18 18:00:52
 * @FilePath: /react-native-cim/ios/RNCim.h
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import <React/RCTEventEmitter.h>
#endif

#import "SocketRocket.h"
#import "GCDAsyncSocket.h"

#import "CIMHeader.h"
#import "SentBody.pbobjc.h"
#import "Message.pbobjc.h"
#import "NSData+IM.h"
#import "NSString+IM.h"

@interface RNCim : RCTEventEmitter <RCTBridgeModule,GCDAsyncSocketDelegate,CIMPeerMessageObserver,CIMConnectionObserver>

{
    BOOL isObserving;
}

@property (strong, nonatomic) NSString *sockethost;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *apibase;

+(RNCim*)instance;
- (void)setDeviceToken:(NSData *)deviceToken;
@end
