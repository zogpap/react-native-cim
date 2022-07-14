/*
 * @Author: zogpap zogpap@163.com
 * @Date: 2022-07-13 12:24:48
 * @LastEditors: zogpap zogpap@163.com
 * @LastEditTime: 2022-07-13 17:06:25
 * @FilePath: /react-native-cim/android/src/main/java/com/diaozhao/cimsocket/RNCimModule.java
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

package com.diaozhao.cimsocket;

import android.net.NetworkInfo;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.stetho.common.LogUtil;
import com.farsunset.cim.sdk.android.CIMEventListener;
import com.farsunset.cim.sdk.android.CIMListenerManager;
import com.farsunset.cim.sdk.android.CIMPushManager;
import com.farsunset.cim.sdk.android.constant.CIMConstant;
import com.farsunset.cim.sdk.android.model.Message;
import com.farsunset.cim.sdk.android.model.ReplyBody;
import com.farsunset.cim.sdk.android.model.SentBody;

import java.util.IdentityHashMap;
import java.util.Map;

public class RNCimModule extends ReactContextBaseJavaModule implements CIMEventListener {

  public static final String EVENT_MSG_NAME = "CIMMESSAGELISTER";
  public static final String EVENT_CONNECT_NAME = "EVENT_CONNECT_NAME";

  private final ReactApplicationContext reactContext;

  private String sockethost;
  private String port;
  private String apibase;

  public RNCimModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }


  public static final String NAME = "RNCim";

  @Override
  public String getName() {
    return RNCimModule.NAME;
  }

  @Override
  public void onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy();
    CIMPushManager.destroy(this.reactContext);
  }

  @ReactMethod
  public void init(String sockethost, String port, String apibase, Promise promise) {
    try {
      this.sockethost=sockethost;
      this.port=port;
      this.apibase=apibase;
      CIMPushManager.connect(this.reactContext,sockethost, Integer.parseInt(port));

      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void connectionBindUserId(String usid,Promise promise) {
    try {
      CIMPushManager.bind(this.reactContext,usid);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(e);
    }
  }

  @ReactMethod
  public void setMsgListener() {
    CIMListenerManager.registerMessageListener(this);
  }

  @ReactMethod
  public void removeMessageListener() {
    CIMListenerManager.removeMessageListener(this);
  }

  @ReactMethod
  public void setConnectListener() {

  }

  @ReactMethod
  public void removeConnectListener() {
    
  }

  @ReactMethod
  public void reconnect() {

  }

  @ReactMethod
  public void disconnect() {
    
  }

  @ReactMethod
  public void enterForeground() {
    
  }

  @ReactMethod
  public void enterBackground() {
    
  }

//CIMEventListener
  @Override
  public void onMessageReceived(Message message) {
    LogUtil.e("liyc","cimCommonMsgSucess");
    Map<String,Object> obj = new IdentityHashMap<>();
    obj.put("type","1");
    obj.put("title","cimCommonMsgSucess");
    obj.put("msg",message);

    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_MSG_NAME, obj);
  }

  @Override
  public void onReplyReceived(ReplyBody replyBody) {
    /*
     *第三步 用户id绑定成功，可以接收消息了
     */
    if (replyBody.getKey().equals(CIMConstant.RequestKey.CLIENT_BIND)) {
      LogUtil.e("liyc","cimDidBindUserSuccess");
      Map<String,String> obj = new IdentityHashMap<>();
      obj.put("type","3");
      obj.put("title","cimDidBindUserSuccess");
      reactContext
              .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
              .emit(EVENT_CONNECT_NAME, obj);
    }
  }

  @Override
  public void onSendFinished(SentBody sentBody) {
    LogUtil.e("liyc","onSendFinished");
    Map<String,Object> obj = new IdentityHashMap<>();
    obj.put("type","2");
    obj.put("title","onSendFinished");
    obj.put("sentbody",sentBody);

    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_MSG_NAME, obj);
  }

  @Override
  public void onNetworkChanged(NetworkInfo networkInfo) {

  }

  @Override
  public void onConnectFinished(boolean b) {
    LogUtil.e("liyc","cimDidConnectSuccess");
    Map<String,String> obj = new IdentityHashMap<>();
    obj.put("type","1");
    obj.put("title","cimDidConnectSuccess");
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_CONNECT_NAME, obj);

  }

  @Override
  public void onConnectionClosed() {
    LogUtil.e("liyc","cimDidConnectClose");
    Map<String,String> obj = new IdentityHashMap<>();
    obj.put("type","0");
    obj.put("title","cimDidConnectClose");
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_CONNECT_NAME, obj);
  }

  @Override
  public void onConnectFailed() {
    LogUtil.e("liyc","cimDidConnectError");
    Map<String,String> obj = new IdentityHashMap<>();
    obj.put("type","2");
    obj.put("title","cimDidConnectError");
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_CONNECT_NAME, obj);

  }

  @Override
  public int getEventDispatchOrder() {
    return 0;
  }
}