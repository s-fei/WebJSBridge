# WebJSBridge
完美实现JS和Swift的互调

##安装
```
 pod 'WebJSBridge'
```
##使用

引入头文件

```
 import WebJSBridge
```
初始化

```
        // 加载本地Html页面
        let url = Bundle.main.url(forResource: "demo", withExtension: "html")
        let request = URLRequest(url: url!)
        self.webView.loadRequest(request)
        
        //初始化桥接
        bridge = WebJSBridge(webView, "AppObject", webViewDelegate: self, handler: nil)
        
        //js调用App的回调
        bridge.registerHandler(handlerName: "login") {
            [weak self](data, callBack) in
            guard let `self` = self else { return }
            print("login:\(data)")
            }
        }
        
        //js调用App的回调,并回馈结果给js
        bridge.registerHandler(handlerName: "loginToResult") {
            [weak self](data, callBack) in
            guard let `self` = self else { return }
            print("loginToResult:\(data)")
            }
            callBack("张三")
        }
        //App调用JS的方法
        bridge.callHandler(handlerName: "appToJSNotResult", data: ["name":"李四"], responseCallback: nil)
        App调用JS的方法 JS回馈结果给App
        bridge.callHandler(handlerName: "appToJSResult", data: ["name":"王五"]) {
            [weak self] (data) in
            guard let `self` = self else { return }
            print("callHandler:\(data)")
           
        }
```
H5中的调用方法

```   
       //AppObject:为Swift桥接时设置的Key appHandler：为调用App的方法  三个参数分别为：1.双方约定的功能key，不可为空 2. 需要传的参数，可为空 3，APP获得事件后 回调js的方法名 ，可为空
      onclick="AppObject.appHandler('loginToResult','js调用App成功，给我反馈','loginToResult')"
```