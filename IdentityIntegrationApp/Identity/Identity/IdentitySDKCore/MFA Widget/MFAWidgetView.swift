
/* Copyright (c) 2021 CyberArk Software Ltd. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

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
 
