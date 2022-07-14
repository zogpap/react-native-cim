/*
 * @Author: zogpap zogpap@163.com
 * @Date: 2022-07-14 09:55:59
 * @LastEditors: zogpap zogpap@163.com
 * @LastEditTime: 2022-07-14 10:18:46
 * @FilePath: /react-native-cim/index.d.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { EmitterSubscription } from 'react-native';

export interface SendMessageProps {
    sender:String;
    reviceid:String;
    action:number|String;
    content:String;
    format:number|String;
    extra?:any;
    callback:(e:any)=>void;
}

interface connectionMsgProps {
    type:String;
    title:String;
    msg?:Object|String;
}

export declare const RNCIM : {
    init(sockethost:String,port:String,apibase:String):void;
    connectionBindUserId(usid:String):void;

    addConnectListener(callback:(e:connectionMsgProps)=>void): EmitterSubscription;
    removeConnectListener():void;
    addMessageListener(callback:(e:connectionMsgProps)=>void): EmitterSubscription;
    removeMessageListener():void;

    sendMessage(sendMsg:SendMessageProps):void;

    // 苹果专用
    reconnect():void;
    disconnect():void;
    enterBackground():void;
    enterForeground():void;
    getDeviceToken():any;
    openApns(uid:String,deviceToken:String,callback:(e:any)=>void):void;
    closeApns(uid:String,callback:(e:any)=>void):void;
}