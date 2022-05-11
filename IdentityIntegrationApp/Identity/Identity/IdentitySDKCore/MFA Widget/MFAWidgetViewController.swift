
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
import CoreGraphics
import WebKit

class MFAWidgetViewController: UIViewController, WKScriptMessageHandler {
    
    public var didRecieveResponse: ((Bool) -> Void)?

    @IBOutlet weak var contentWebView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var webUrl: String?
    
    var webRequest: URLRequest?
    
    var webData:Data?
    
    var imageData:Data?
    
    var webConfig: WKWebViewConfiguration {
        get {
            
            let config = WKWebViewConfiguration()
            let contentController = WKUserContentController()
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(userScript)
            contentController.add(self, name: "loginSuccessHandler")
            config.preferences = WKPreferences()
            config.preferences.javaScriptEnabled = true
            config.userContentController = contentController
            return config
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialSetUp()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addWebView()
    }
    func addWebView() {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: contentWebView.frame.width, height: contentWebView.frame.height))
        let webView = WKWebView(frame: rect, configuration: webConfig)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        if let request = webRequest {
            webView.load(request)
        }
        self.contentWebView.addSubview(webView)
        contentWebView.isHidden = true
    }
    @IBAction func close(_ sender: Any) {
        self.didRecieveResponse?(false)
    }
}

extension MFAWidgetViewController {
   
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "loginSuccessHandler") {
            HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
            URLCache.shared.removeAllCachedResponses()
            self.didRecieveResponse?(true)
        }
    }
}

extension MFAWidgetViewController: WKUIDelegate, WKNavigationDelegate,WKURLSchemeHandler, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        contentWebView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        contentWebView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        contentWebView.isHidden = false
    }
}
