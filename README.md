
# react-native-cim

## Getting started

`$ npm install react-native-cim --save`

### Mostly automatic installation

`$ react-native link react-native-cim`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-cim` and add `RNCim.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNCim.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

5. 推送设置---appdelegate 
```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken；
[[RNCim instance] setDeviceToken:deviceToken];

rn代码里：监听app前后台状态
CimSocket.enterBackground();
CimSocket.enterForeground();
CimSocket.openApns();
CimSocket.closeApns();

```

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.diaozhao.cimsocket.RNCimPackage;` to the imports at the top of the file
  - Add `new RNCimPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-cim'
  	project(':react-native-cim').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-cim/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-cim')
  	```
4. 推送设置 minifest.xml;创建CIMPushMessageReceiver接收消息处理通知
	```
		<!-- ****************************************CIM推送配置 begin*************************************** -->
        <service
            android:name="com.farsunset.cim.sdk.android.CIMPushService"
            android:process=":cimpush"
            android:exported="false"
            />

        <provider
            android:name="com.farsunset.cim.sdk.android.CIMCacheProvider"
            android:authorities="${applicationId}.cim.provider"
            android:exported="false" />
        <!-- ****************************************CIM推送配置 end*************************************** -->


        <!--消息接受广播注册-->
        <receiver android:name="com.XXX.XXX.CIMPushMessageReceiver">
            <intent-filter android:priority="0x7fffffff">
                <!-- 网络变事件action targetVersion 24之前 -->
                <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
                <action android:name="com.farsunset.cim.NETWORK_CHANGED" />
                <!-- 收到消息事件action -->
                <action android:name="com.farsunset.cim.MESSAGE_RECEIVED" />
                <!-- 发送sendBody完成事件action -->
                <action android:name="com.farsunset.cim.SEND_FINISHED" />
                <!--重新连接事件action -->
                <action android:name="com.farsunset.cim.CONNECTION_RECOVERY" />
                <!-- 连接关闭事件action -->
                <action android:name="com.farsunset.cim.CONNECTION_CLOSED" />
                <!-- 连接失败事件action -->
                <action android:name="com.farsunset.cim.CONNECT_FAILED" />
                <!-- 连接成功事件action-->
                <action android:name="com.farsunset.cim.CONNECT_FINISHED" />
                <!-- 收到replyBody事件action -->
                <action android:name="com.farsunset.cim.REPLY_RECEIVED" />

                <!-- 【可选】 一些常用的系统广播，增强pushService的复活机会-->
                <action android:name="android.intent.action.USER_PRESENT" />
                <action android:name="android.intent.action.ACTION_POWER_CONNECTED" />
                <action android:name="android.intent.action.ACTION_POWER_DISCONNECTED" />
            </intent-filter>
        </receiver>
	```
	```
	/*
 * Copyright 2013-2019 Xia Jun(3979434@qq.com).
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p>
 * **************************************************************************************
 *
 *                         Website : http://www.farsunset.com                           *
 *
 * **************************************************************************************
 */
package com.farsunset.cim.reveiver;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;

import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.farsunset.cim.R;
import com.farsunset.cim.activity.MessageActivity;
import com.farsunset.cim.app.CIMApplication;
import com.farsunset.cim.sdk.android.CIMEventBroadcastReceiver;
import com.farsunset.cim.sdk.android.CIMListenerManager;
import com.farsunset.cim.sdk.android.model.Message;
import com.farsunset.cim.sdk.android.model.ReplyBody;


/**
 * 消息入口，所有消息都会经过这里
 */
public final class CIMPushMessageReceiver extends CIMEventBroadcastReceiver {


    /**
     * 当收到消息时调用此方法
     */
    @Override
    public void onMessageReceived(com.farsunset.cim.sdk.android.model.Message sdkMessage, Intent intent) {

        /*
         * 通知到每个页面接收消息
         */
        CIMListenerManager.notifyOnMessageReceived(sdkMessage);


        /*
         * 切换到后台 弹通知栏
         */
        if (CIMApplication.getInstance().isAppInBackground()){
            showMessageNotification(sdkMessage);
        }
    }

    private void showMessageNotification(Message message){

        NotificationManager notificationMgr = ContextCompat.getSystemService(CIMApplication.getInstance(),NotificationManager.class);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(CIMApplication.getInstance(),CIMApplication.NOTIFICATION_CHANNEL_ID);

        Intent intent =  new Intent();
        intent.setClass(CIMApplication.getInstance(), MessageActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(CIMApplication.getInstance(), 1,intent, PendingIntent.FLAG_UPDATE_CURRENT);

        builder.setAutoCancel(true);
        builder.setSmallIcon(R.mipmap.ic_launcher);
        builder.setContentIntent(pendingIntent);
        builder.setWhen(System.currentTimeMillis());
        builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC);
        builder.setDefaults(NotificationCompat.DEFAULT_LIGHTS);

        builder.setContentTitle(CIMApplication.NOTIFICATION_CHANNEL_NAME);
        builder.setContentText(message.getContent());


        Notification notification = builder.build();
        notificationMgr.notify(0, notification);
    }

}

	```

## Usage
```javascript
import RNCim from 'react-native-cim';

// TODO: What to do with the module?
RNCim;
```
  