/*
 * @Author: zogpap zogpap@163.com
 * @Date: 2022-07-13 12:24:48
 * @LastEditors: zogpap zogpap@163.com
 * @LastEditTime: 2022-07-14 10:06:33
 * @FilePath: /react-native-cim/index.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import { NativeModules ,NativeEventEmitter} from 'react-native';

const { RNCim } = NativeModules;

const EVENT_MSG_NAME = "CIMMESSAGELISTER";
const EVENT_CONNECT_NAME = "CIMCONNECTLISTER";


var eventEmitter = new NativeEventEmitter(RNCim);
var listenerCount = eventEmitter.listenerCount;

var addMessageListener = function (callback) {
    if (listenerCount(EVENT_MSG_NAME) === 0) {
        RNCim.setMsgListener();
    }
    var res = eventEmitter.addListener(EVENT_MSG_NAME, callback);
    // Path the remove call to also remove the native listener
    // if we no longer have listeners
    // @ts-ignore
    res._remove = res.remove;
    res.remove = function () {
        // @ts-ignore
        this._remove();
        if (listenerCount(EVENT_MSG_NAME) === 0) {
            RNCim.removeMessageListener();
        }
    };
    return res;
};

var addConnectListener = function (callback) {
    if (listenerCount(EVENT_CONNECT_NAME) === 0) {
        RNCim.setConnectListener();
    }
    var res = eventEmitter.addListener(EVENT_CONNECT_NAME, callback);
    // Path the remove call to also remove the native listener
    // if we no longer have listeners
    // @ts-ignore
    res._remove = res.remove;
    res.remove = function () {
        // @ts-ignore
        this._remove();
        if (listenerCount(EVENT_CONNECT_NAME) === 0) {
            RNCim.removeConnectListener();
        }
    };
    return res;
};

var apibaset = "";
class CimSocket {

    static init(sockethost,port,apibase){
        if (RNCim&&RNCim.init) {
            apibaset = apibase;
            RNCim.init(sockethost,port,apibase);
        }
    }

    static reconnect(){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.reconnect) {
            RNCim.reconnect();
        }
    }

    static disconnect(){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.disconnect) {
            RNCim.disconnect();
        }
    }

    static connectionBindUserId(usid){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.connectionBindUserId) {
            RNCim.connectionBindUserId(usid,()=>{});
        }
    }

    static addConnectListener(callback){
        return addConnectListener(callback);
    }

    static removeConnectListener(){
        if (RNCim&&RNCim.removeConnectListener) {
            RNCim.removeConnectListener();
        }
    }

    static addMessageListener(callback){
        return addMessageListener(callback);
    }

    static removeMessageListener(){
        if (RNCim&&RNCim.removeMessageListener) {
            RNCim.removeMessageListener();
        }
    }

    //苹果专用
    static enterBackground(){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.enterBackground) {
            RNCim.enterBackground();
        }
    }

    //苹果专用
    static enterForeground(){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.enterForeground) {
            RNCim.enterForeground();
        }
    }

    //发送消息
    static sendMessage({sender,reviceid,action,content,format,extra,callback}){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        
        let obj = {
            sender: sender,
            reviceid: reviceid,
            action:action,
            content:content,
            format:format,
            extra:extra,
        }

        // 通过设置 encode 为 false 禁止 URI 编码：
        let formData = new FormData()
        for(let key in obj) {
            formData.append(key, obj[key])
        }
        let headers = {
            "Content-Type": "multipart/form-data"
        };
        try {
            var allurl = apibaset + "/api/message/send";
            
            let res = await fetch(allurl, {
                method: "POST",
                headers: headers,
                body: formData
            });
            let body = await res.json();
            console.log('--------------', body)
            if (!res.ok && !body.errCode) {
                throw "URL error";
            }

            if (callback) {
                callback({
                    ok: res.ok,
                    body: body
                });
            }
            
        } catch (err) {
            console.log(`Network doesn\'t work. Error:${err}-------end;`);
            //throw('网络错误,请检查网络连接!');
            
            if (callback) {
                callback({
                    ok: false,
                    body: {
                        errCode: "5000001"
                    }
                });
            }
        }
    }

    //苹果专用
    static getDeviceToken(){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        if (RNCim&&RNCim.getDeviceToken) {
           return RNCim.getDeviceToken();
        }
    }

    //苹果专用
    static openApns(uid,deviceToken,callback){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        
        let obj = {
            deviceToken: deviceToken,
            uid: uid,
        }

        // 通过设置 encode 为 false 禁止 URI 编码：
        let formData = new FormData()
        for(let key in obj) {
            formData.append(key, obj[key])
        }
        let headers = {
            "Content-Type": "multipart/form-data"
        };
        try {
            var allurl = apibaset + "/apns/open";
            
            let res = await fetch(allurl, {
                method: "POST",
                headers: headers,
                body: formData
            });
            let body = await res.json();
            console.log('--------------', body)
            if (!res.ok && !body.errCode) {
                throw "URL error";
            }

            if (callback) {
                callback({
                    ok: res.ok,
                    body: body
                });
            }
            
        } catch (err) {
            console.log(`Network doesn\'t work. Error:${err}-------end;`);
            //throw('网络错误,请检查网络连接!');
            
            if (callback) {
                callback({
                    ok: false,
                    body: {
                        errCode: "5000001"
                    }
                });
            }
        }
    }

    //苹果专用
    static closeApns(uid,callback){
        if (!apibaset) {
            console.error("未初始化init");
            return;
        }
        
        let obj = {
            uid: uid,
        }

        // 通过设置 encode 为 false 禁止 URI 编码：
        let formData = new FormData()
        for(let key in obj) {
            formData.append(key, obj[key])
        }
        let headers = {
            "Content-Type": "multipart/form-data"
        };
        try {
            var allurl = apibaset + "/apns/close";
            
            let res = await fetch(allurl, {
                method: "POST",
                headers: headers,
                body: formData
            });
            let body = await res.json();
            console.log('--------------', body)
            if (!res.ok && !body.errCode) {
                throw "URL error";
            }

            if (callback) {
                callback({
                    ok: res.ok,
                    body: body
                });
            }
            
        } catch (err) {
            console.log(`Network doesn\'t work. Error:${err}-------end;`);
            //throw('网络错误,请检查网络连接!');
            
            if (callback) {
                callback({
                    ok: false,
                    body: {
                        errCode: "5000001"
                    }
                });
            }
        }
    }

}

export default CimSocket;
