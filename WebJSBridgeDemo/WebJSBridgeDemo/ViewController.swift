//
//  ViewController.swift
//  WebJSBridge-Demo
//
//  Created by song on 2017/3/5.
//  Copyright © 2017年 song. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    
    var bridge:WebJSBridge!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 加载本地Html页面
        let url = Bundle.main.url(forResource: "demo", withExtension: "html")
        let request = URLRequest(url: url!)
        self.webView.loadRequest(request)
        
        bridge = WebJSBridge(webView, "AppObject", webViewDelegate: self, handler: nil)
        
        bridge.registerHandler(handlerName: "login") {
            [weak self](data, callBack) in
            guard let `self` = self else { return }
            print("login:\(String(describing: data))")
            if let string = data as? String{
                let alert = UIAlertController(title: "js给App的数据", message: string, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        bridge.registerHandler(handlerName: "loginToResult") {
            [weak self](data, callBack) in
            guard let `self` = self else { return }
            print("loginToResult:\(String(describing: data))")
            if let string = data as? String{
                let alert = UIAlertController(title: "js给App的数据,App返回给js '张三'并显示到h5中", message: string, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            callBack("张三")
        }
    }
    
    @IBAction func appToJSNotResult(_ sender: Any) {
        bridge.callHandler(handlerName: "appToJSNotResult", data: ["name":"李四"], responseCallback: nil)
        
    }
    @IBAction func appToJSResult(_ sender: Any) {
        bridge.callHandler(handlerName: "appToJSResult", data: ["name":"王五"]) {
            [weak self] (data) in
            guard let `self` = self else { return }
            print("callHandler:\(String(describing: data))")
            if let string = data as? String{
                let alert = UIAlertController(title: "App已接收到js的反馈", message: string, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
}

extension ViewController:UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
}
