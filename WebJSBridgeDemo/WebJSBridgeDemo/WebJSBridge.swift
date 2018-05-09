//
//  WebJSBridge.swift
//  TextJS
//
//  Created by song on 2017/3/4.
//  Copyright © 2017年 song. All rights reserved.
//

import UIKit
import JavaScriptCore

/*! 回调数据 */
typealias WebJSResponseCallback = (_ responseData:Any?) -> ()

/*! js回调App的block */
typealias WebJBHandler = ( _ data:Any?, _ responseCallback:WebJSResponseCallback) -> ()

/*! webView与JS的初始化回调 */
typealias WebJSInitHandler = ( _ success:Bool, _ error:String) -> ()


/*
 *  WebJSBridge
 *
 /// 初始化桥接功能
 *init(_ webView:UIWebView,_ jsKey:String,webViewDelegate:UIWebViewDelegate?,handler:WebJSInitHandler?)
 *
 *
 /// js调用App回调
 *func registerHandler(handlerName:String,webJBHandler: @escaping WebJBHandler)
 *
 *
 /// 移除回调监听
 *func removeHandler(handlerName:String)
 *
 *
/// 移除所有的监听
 *func reset()
 *
 *
 /// App调用js中方法
 *func callHandler(handlerName:String,data:Any?,responseCallback:WebJSResponseCallback?)
 *
 */
@objc class WebJSBridge: NSObject,WebJSDelegate {
    fileprivate var appHandler: WebJSDelegate.JSHandler!
    fileprivate var webView:UIWebView
    fileprivate var jsContext:JSContext
    fileprivate var jsModelDict:[String:WebJSModel] = [String:WebJSModel]()
    fileprivate weak var webViewDelegate:UIWebViewDelegate?
    fileprivate var isFinishLoad = false
    fileprivate var cacheCallDict:[String:Any?] = [String:Any?]()
    /// 初始化桥接功能
    ///
    /// - Parameters:
    ///   - webView: 需要加载的webView
    ///   - jsKey: h5中调用iOS方法的对象
    ///   - webViewDelegate: webView.delegate所在的VC
    ///   - handler: 是否桥接成功的回调
    init(_ webView:UIWebView,_ jsKey:String,webViewDelegate:UIWebViewDelegate?,handler:WebJSInitHandler?) {
        self.webView = webView
        self.webViewDelegate = webViewDelegate
        if let context = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext {
            jsContext = context
        }
        else
        {
            print("无法获取webView的JSContext")
            jsContext = JSContext()
            if let `handler` = handler {
               handler(false,"无法获取webView的JSContext，请检查webView")
            }
            super.init()
            return
        }
        super.init()
        jsContext.setObject(self, forKeyedSubscript: jsKey as (NSCopying & NSObjectProtocol)?)
        if let `handler` = handler {
            handler(true,"JS与iOS桥接成功")
        }
        initRegisterHandler()
        webView.delegate = self
    }
    
    /// js调用App回调
    ///
    /// - Parameters:
    ///   - handlerName: 双方约定的Key
    ///   - webJBHandler: 里面的data:给App的数据，responseCallback：App给js的响应结果
    func registerHandler(handlerName:String,webJBHandler: @escaping WebJBHandler){
        let model = WebJSModel()
        model.handlerName = handlerName
        model.isCall = false
        model.webJBHandler = webJBHandler
        let responseCallback:WebJSResponseCallback = {
            [weak self] (responseData) in
            guard let `self` = self else { return }
            if let callName = model.callName, let jsParamsFunc = self.jsContext.objectForKeyedSubscript(callName) {
                var arr = [Any]()
                if let data = responseData {
                    arr.append(data)
                }
                jsParamsFunc.call(withArguments: arr)
            }
        }
        model.responseCallback = responseCallback
        jsModelDict[handlerName] = model
    }
    
    /// 移除回调监听
    ///
    /// - Parameter handlerName: 双方约定的Key
    func removeHandler(handlerName:String){
        jsModelDict.removeValue(forKey: handlerName)
    }
    
    /// 移除所有的监听
    func reset(){
        jsModelDict.removeAll()
    }
    
    /// App调用js中方法
    ///
    /// - Parameters:
    ///   - handlerName: handlerName: 双方约定的Key
    ///   - data: 给js的数据
    ///   - responseCallback: js给App的响应结果
    func callHandler(handlerName:String,data:Any?,responseCallback:WebJSResponseCallback?){
        if let _ = responseCallback {
            let model = WebJSModel()
            model.handlerName = handlerName
            model.isCall = true
            model.responseCallback = responseCallback
            jsModelDict[handlerName] = model
        }
        if isFinishLoad {
            if let jsParamsFunc = jsContext.objectForKeyedSubscript(handlerName) {
                var arr = [Any]()
                if let callData = data {
                    arr.append(callData)
                }
                jsParamsFunc.call(withArguments: arr)
            }
        }
        else
        {
            cacheCallDict[handlerName] = data
        }
    }
    
    /*! 真实js回调APP的地方 */
    private func initRegisterHandler(){
        appHandler = {
            [weak self] (handlerName,data,callBack) in
            guard let `self` = self else { return }
            if let jsModle = self.jsModelDict[handlerName]   {
                //监听js调App  isCall一定等于false
                if let webJBHandler = jsModle.webJBHandler{
                    jsModle.callName = callBack
                    if let responseCallback = jsModle.responseCallback {
                        webJBHandler(data,responseCallback)
                    }
                    else
                    {
                        let responseCallback:WebJSResponseCallback = {
                            [weak self] (responseData) in
                            guard let `self` = self else { return }
                            if let jsParamsFunc = self.jsContext.objectForKeyedSubscript(handlerName) {
                                var arr = [Any]()
                                if let data = responseData {
                                    arr.append(data)
                                }
                                jsParamsFunc.call(withArguments: arr)
                            }
                        }
                        webJBHandler(data,responseCallback)
                    }
                }
                else if let responseCallback = jsModle.responseCallback { //isCall一定等于true
                    responseCallback(data)
//                    self.jsModelDict.removeValue(forKey: handlerName)
                }
                //这里有两种情况会销毁js给App的响应结果 1,call js后 js给App的响应结果  2.call js后  js没有给App响应结果 接下来有了 call App的动作
                for (handlerName, jsModel) in self.jsModelDict {
                    if jsModel.isCall {
                        self.jsModelDict.removeValue(forKey: handlerName)
                    }
                }
            }
        }
    }
    
    /*! h5加载成功后才能Call到js */
    fileprivate func callCache(){
        cacheCallDict.forEach {
            [weak self](handlerName, data) in
            guard let `self` = self else { return }
            if let jsParamsFunc = self.jsContext.objectForKeyedSubscript(handlerName) {
                var arr = [Any]()
                if let callData = data {
                    arr.append(callData)
                }
                jsParamsFunc.call(withArguments: arr)
            }
        }
        cacheCallDict.removeAll()
    }
}


/*! 这里是为了使用webViewDidFinishLoad 但必须将其回调到所在的VC中 */
extension WebJSBridge:UIWebViewDelegate{
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        if let boo = webViewDelegate?.webView?(webView, shouldStartLoadWith: request, navigationType: navigationType) {
            return boo
        }
       return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        isFinishLoad = false
        webViewDelegate?.webViewDidStartLoad?(webView)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        isFinishLoad = true
        callCache()
        webViewDelegate?.webViewDidFinishLoad?(webView)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewDelegate?.webView?(webView, didFailLoadWithError: error)
    }
}



/*
 *
 * 增加属性为了H5中调用
 */
@objc fileprivate  protocol WebJSDelegate: JSExport {
    /*! js与APP的实际参数 */
    typealias JSHandler = (_ handlerName:String,_ data:Any?,_ callBack:String?) -> ()
    /*! h5中统一调用该属性*/
    var appHandler:JSHandler! { get set }
    
}

/*
 *
 * 该对象主要处理WebJSDelegate中registerHandler和方法的对接
 */
fileprivate class WebJSModel: NSObject {
    
    var handlerName:String = ""
    var isCall = false //true:App调用js  false:js调用APP
    var webJBHandler:WebJBHandler?
    var responseCallback:WebJSResponseCallback?
    var callName:String?
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
