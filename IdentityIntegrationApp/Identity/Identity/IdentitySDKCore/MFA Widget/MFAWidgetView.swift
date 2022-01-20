//
//  MFAWidgetView.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 17/01/22.
//

import UIKit
import WebKit

class MFAWidgetView: UIView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    var webRequest: URLRequest?

    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    var webConfig: WKWebViewConfiguration {
        get {
            let contentController = WKUserContentController()
            contentController.add(self, name: "loginSuccessHandler")
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            return config
        }
    }
    
}

extension MFAWidgetView  {
    func commonInit() {
        addWebView()
    }
    func addWebView() {
        let webView = WKWebView(frame: self.frame)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        if let request = webRequest {
            webView.load(request)
        }
        self.addSubview(webView)
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "loginSuccessHandler") {
            print("It does ! \(message.body)")
        }
    }
}
 
