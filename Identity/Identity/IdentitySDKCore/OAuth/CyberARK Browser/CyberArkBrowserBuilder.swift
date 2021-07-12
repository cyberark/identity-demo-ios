//
//  WebBrowserBuilder.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 06/07/21.
//

import Foundation
import UIKit

/// This is created for
/// building the browser object.
///
/// - webType: type of  the browser
/// - customParam: as custom parameters
/// - oAuthEndPoint: url components
/// - presentingViewController: presentingViewController

public class CyberArkBrowserBuilder: NSObject {
    
    var webType: WebType? = .sfsafari
    
    var customParam: [String: String] = [:]

    var isInProgress: Bool = false

    var presentingViewController: UIViewController?
    
    var oAuthEndPoint: OAuthEndPoint?
    
    var pkce: AuthOPKCE?

    init(_ oAuthEndPoint: OAuthEndPoint? = nil, pkce: AuthOPKCE? = nil) {
        self.oAuthEndPoint = oAuthEndPoint ?? OAuthEndPoint(pkce: pkce)
        self.pkce = pkce
    }
    
    
    /// Sets BrowserType (an external user-agent) for Browser object; default to .authSession
    /// - Parameter browserType: An external user-agent type to be used for /authorize flow
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setWebType:) public func set(webType: WebType) -> CyberArkBrowserBuilder {
        self.webType = webType
        return self
    }
    
    
    /// Sets presenting ViewController which will be used as ASPresentationAnchor for ASWebAuthenticationSession in iOS 13.0 or above
    /// - Parameter presentingViewController: ViewController that will act as ASPresentationAnchor for ASWebAuthenticationSession
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setPresentingViewController:) public func set(presentingViewController: UIViewController) -> CyberArkBrowserBuilder {
        self.presentingViewController = presentingViewController
        return self
    }
    
    
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setCustomKey:CustomValue:) public func setCustomParam(key: String, value: String) -> CyberArkBrowserBuilder {
        customParam[key] = value
        return self
    }
    
    /// builds the 
    /// - Returns: the browser object
    @objc public func build() -> CyberArkBrowser {
        let browser = CyberArkBrowser(type: self.webType, presentingViewController: self.presentingViewController, oauthEndPoint: self.oAuthEndPoint, pkce: self.pkce)
        return browser
    }

}
