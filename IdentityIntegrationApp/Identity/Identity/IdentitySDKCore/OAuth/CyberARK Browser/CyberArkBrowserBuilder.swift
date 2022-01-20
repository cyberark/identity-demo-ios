
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

import Foundation
import UIKit

/*
/// CyberArkBrowserBuilder
/// This is created for
/// building the browser object.
///
/// - webType: type of  the browser
/// - customParam: as custom parameters
/// - oAuthEndPoint: url components
/// - presentingViewController: presentingViewController
*/
public class CyberArkBrowserBuilder: NSObject {
   
    /// clientId configured in the server
    var clientId: String? = nil
    
    /// domain configured in the server
    var domain: String? = nil
    
    /// scope configured in the server
    var scope: String? = nil
    
    /// redirectUri configured in the server
    var redirectUri: String? = nil
    
    /// threshold configured in the server
    var threshold: Int? = 60
    
    /// applicationID configured in the server
    var applicationID: String? = nil
    
    /// applicationID configured in the server
    var logoutUri: String? = nil

    /// System url for enrollment
    var systemURL: String? = nil

    /// webType
    var webType: WebType? = .sfsafari
    
    /// customParam
    var customParam: [String: String] = [:]

    /// is in progress
    var isInProgress: Bool = false
    
    /// presenting view controller
    var presentingViewController: UIViewController?
    
    /// endpoint
    var oAuthEndPoint: OAuthEndPoint?
    
    /// pkce
    var pkce: AuthOPKCE?

    /// widgetID
    var widgetID: String? = nil

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
    
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setDomain:) public func set(domain: String) -> CyberArkBrowserBuilder {
        self.domain = domain
        return self
    }
    
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setSystemURL:) public func set(systemURL: String) -> CyberArkBrowserBuilder {
        self.systemURL = systemURL
        return self
    }
    
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setScope:) public func set(scope: String) -> CyberArkBrowserBuilder {
        self.scope = scope
        return self
    }
    
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setClientId:) public func set(clientId: String) -> CyberArkBrowserBuilder {
        self.clientId = clientId
        return self
    }
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setRedirectUri:) public func set(redirectUri: String) -> CyberArkBrowserBuilder {
        self.redirectUri = redirectUri
        return self
    }
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setApplicationID:) public func set(applicationID: String) -> CyberArkBrowserBuilder {
        self.applicationID = applicationID
        return self
    }
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setlLogoutUri:) public func set(logoutUri: String) -> CyberArkBrowserBuilder {
        self.logoutUri = logoutUri
        return self
    }
    /// Sets custom URL Query parameters to be added to /authorize request
    /// - Parameters:
    ///   - key: URL Query parameter key
    ///   - value: URL Query parameter value
    /// - Returns: BrowserBuilder object to progressively build Browser object
    @discardableResult @objc(setWidgetID:) public func set(widgetID: String) -> CyberArkBrowserBuilder {
        self.widgetID = widgetID
        return self
    }
    
    /// builds the  Browser
    /// - Returns: the browser object
    @objc public func build() -> CyberarkAccount {
        return CyberarkAccount(clientId: self.clientId ?? "", domain: self.domain ?? "", scope: self.scope ?? "", redirectUri: self.redirectUri ?? "", threshold: self.threshold ?? 0, applicationID: self.applicationID ?? "", logoutUri: self.logoutUri ?? "", pkce: self.pkce ?? AuthOPKCE(), presentingViewController: self.presentingViewController ?? UIViewController(), systemURL: self.systemURL ?? "", widgetID: self.widgetID ?? "")
    }
}
