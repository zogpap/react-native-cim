/*
 * @Author: zogpap zogpap@163.com
 * @Date: 2022-07-13 12:24:48
 * @LastEditors: zogpap zogpap@163.com
 * @LastEditTime: 2022-07-13 16:08:45
 * @FilePath: /react-native-cim/ios/RNCim.h
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RNCim : NSObject <RCTBridgeModule>

+(RNCim*)instance;
- (void)setDeviceToken:(NSData *)deviceToken;
@end
  