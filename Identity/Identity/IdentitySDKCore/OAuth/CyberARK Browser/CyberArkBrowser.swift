//
//  WebBrowser.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 05/07/21.
//

import Foundation
import AuthenticationServices
import SafariServices




@objc public enum WebType: Int {
    case webview
    case sfsafari
}

public typealias didFinishingbrowserOperationCallback = (_ result: String?, _ error:Error?) -> Void

/// This is created for browser related operations.
///  Safari controller
/// - webType: type of  the browser
/// - customParam: as custom parameters
/// - oAuthEndPoint: url components
/// - presentingViewController: presentingViewController

public class CyberArkBrowser: NSObject {
    
    var type: WebType?

    var browserCallback: didFinishingbrowserOperationCallback?
    
    var isInProgress: Bool = false

    var presentingViewController: UIViewController?

    var customParam: [String: String] = [:]

    var pkce: AuthOPKCE?

    var activeController: Any?
    
    var oAuthEndPoint: OAuthEndPoint?

    
    /// Initializer needed to construct the prarams to pass to the broswer
    /// - Parameters:
    ///   - type:WebType
    ///   - presentingViewController: presentingViewController
    ///   - oauthClient: oauthClient
    ///   - oauthClient: oauthClientoauthClient
    ///   - pkce: pkce
    init(type: WebType?, presentingViewController: UIViewController?, oauthClient: OAuthEndPoint?, _ customParam: [String: String] = [:], pkce: AuthOPKCE?) {
        self.type = type
        self.presentingViewController = presentingViewController
        self.oAuthEndPoint = oauthClient
        self.pkce = pkce
    }
    
    /// Navigate to broswer
    /// - Parameter completion: to get the callback
    public func login(completion: @escaping didFinishingbrowserOperationCallback) {
        //  Makes sure if the user is already authenticated or not
        /*if let _ = FRUser.currentUser?.token {
            completion(nil, AuthError.userAlreadyAuthenticated(true))
            return
        }
        
        //  Or make sure that either same Browser instance or other Browser instance is currently running
        if let isInProgress = Browser.currentBrowser?.isInProgress, isInProgress {
            completion(nil, BrowserError.externalUserAgentAuthenticationInProgress)
            return
        }
        else if self.isInProgress == true {
            completion(nil, BrowserError.externalUserAgentAuthenticationInProgress)
            return
        }*/
        //self.pkce = AuthOPKCE()
        self.browserCallback = completion
        let endpoint = oAuthEndPoint?.getAuthorizationEndpoint()
        //let encodedURL = endpoint?.request.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = endpoint?.request.url {
            launchSFViewController(url: url) { (result, error) in
                self.browserCallback!(result, error)
            }
        }
    }
    
}
//MARK: - SafariController delegate methods
extension CyberArkBrowser {
    
    /// launchSFViewController
    /// - Parameters:
    ///   - url: url
    ///   - completion: completion when browser related operation
    /// - Returns: value
     private func launchSFViewController(url: URL, completion: @escaping didFinishingbrowserOperationCallback) -> Bool {
        var viewController: SFSafariViewController?
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            viewController = SFSafariViewController(url: url, configuration: config)
            viewController?.delegate = self
        }
        else {
            viewController = SFSafariViewController(url: url)
            viewController?.delegate = self
        }
        self.activeController = viewController
        if let currentViewController = self.presentingViewController, let sfVC = viewController {
            currentViewController.present(sfVC, animated: true)
            return true
        } else {
            debugPrint("Failed to launch SFSafariViewController; missing presenting ViewController")
            return false
        }
    }
    /// Closes currently presenting ViewController
   private func dismiss() {
        if let sfViewController = self.activeController as? SFSafariViewController {
            print("Close called with SFSafariViewController: \(String(describing: self.activeController))")
            DispatchQueue.main.async {
                sfViewController.dismiss(animated: true) {
                    self.clearSessions()
                }
            }
        }
    }
    
    /// to clear the session and cookies
   private func clearSessions() {
        self.activeController = nil
        self.browserCallback = nil
    }
    
}
//MARK: - SafariController delegate methods
extension CyberArkBrowser: SFSafariViewControllerDelegate {
    
    /// safari callback
    /// - Parameter controller: <#controller description#>
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("User cancelled the authorization process by closing the window")
        if let completionCallback = self.browserCallback {
            completionCallback(nil, CyberArkBrowserError.cancelled)
        }
        self.dismiss()
    }
    
    /// safariviewcontroller callback
    /// - Parameters:
    ///   - controller: <#controller description#>
    ///   - URL: URL description
    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        
        print("Redirect in SFSafariViewController: \(URL.absoluteString)")
        
        if let redirectUri = oAuthEndPoint?.redirectUri, URL.absoluteString.hasPrefix(redirectUri) {
            print("Found matching redirect_uri in SFSafariViewController; closing SFSafariViewController and trying to exchange authorization_code with OAuth2 token(s)")
            controller.dismiss(animated: true, completion: nil)
            
            if let code = URL.queryParameter(with: "code") {
                //self.exchangeAuthCode(code: code)
            }
            else {
                print("Failed to retrieve authorization_code upon redirect_uri; completed redirect: \(URL.absoluteString)")
                if let completionCallback = self.browserCallback {
                    completionCallback(nil, IdentityOAuthError.oAuth_accessDenied(URL.absoluteString))
                }
                self.dismiss()
            }
        }
    }
}


