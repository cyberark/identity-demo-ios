
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

public typealias NodeCompletion<T> = (_ result: T?, _ error: Error?) -> Void

/*
/// CyberArkAuthProvider
/// This class resposible for OAuth SDK Entry Point
/// Shared instance
 */
public var CyberArkAuthProvider: CyberarkAuthProvider {
    return CyberarkAuthProvider.shared
}

/*
/// CyberarkAuthProviderProtocol
/// This class resposible for OAuth SDK Entry Point
/// Shared instance
///
 */
public protocol CyberarkAuthProviderProtocol: class {
    func login(account: CyberarkAccount)
    func resume(url: URL)
    var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)? { get set }
    var didReceiveRefreshToken: ((Bool,String, AccessToken?) -> Void)? { get set }

}
/*
/// CyberarkAuthProvider
/// This class resposible for OAuth SDK Entry Point
/// Shared instance
///
 */
public class CyberarkAuthProvider: CyberarkAuthProviderProtocol {
    
    /// Shared Instance
    static fileprivate var shared = CyberarkAuthProvider()
    
    /// Builder object
    private var builder: CyberArkBrowserBuilder?
    
    //ViewModel
    private var viewModel: AuthenticationViewModel?

    // PKCE object creation
    private var pkce: AuthOPKCE?

    /// Builder object
    private var browser: CyberArkBrowser?
    
    public var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)?
    
    public var didReceiveRefreshToken: ((Bool,String, AccessToken?) -> Void)?

    /// private initializers
    private init(){
        pkce = AuthOPKCE()
        builder = CyberArkBrowserBuilder(pkce: pkce)
        viewModel = AuthenticationViewModel()
        addAccessTokenObserver()
        addRefreshTokenObserver()
    }
    
}
//MARK:- configurations
extension CyberarkAuthProvider {
    
    /// Browser Builder object
    /// - Returns: Builder object
    public func webAuth() -> CyberArkBrowserBuilder? {
        return builder
    }
    
    /// ViewModel
    /// - Returns: Viewmodel object
    public func viewmodel() -> AuthenticationViewModel? {
        return viewModel
    }
}
//MARK:- Authentication and Autherization
extension CyberarkAuthProvider {
    /// Login
    /// - Parameter account: CyberarkAccount with the required parameters
    public func login(account: CyberarkAccount){
        launchBrowser(account: account)
    }
    /// Browser
    /// - Parameter account: CyberarkAccount with the required parameters
    private func launchBrowser(account: CyberarkAccount){
            let browser =  CyberArkBrowser(account: account)
            self.browser = browser
        browser.login(completion: { (status, error) in
            print(status ?? "")
        })
    }
    /// To fecth the access token
    /// - Parameter code: code
    func fetchAuthToken(code: String) {
        viewmodel()?.fetchAuthToken(code: code, pkce: self.pkce)
    }
    /// When application recieves external response from safariview controller
    /// - Parameter url: url
    public func resume(url: URL) {
        guard let configuredURI = getRedirectURI(bundle: Bundle.main) else { return }

        if url.absoluteString.contains(configuredURI) {
            if let code =  url.queryParameter(with:"code") {
                fetchAuthToken(code: code)
            } else {
                dismiss()
            }
        }
    }
}
//MARK:- Close Session
extension CyberarkAuthProvider {
    /// To logout from the current session
    /// - Parameter account: cyberarkaccount
    public func closeSession(account: CyberarkAccount){
        let browser =  CyberArkBrowser(account: account)
        self.browser = browser
        browser.closeSession(completion: { (status, error) in
        })
    }
}
//MARK:- Refresh token related operations
extension CyberarkAuthProvider {
    
    /// To send the refresh token related operations
    public func sendRefreshToken() {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.grantCode.rawValue), let code = data.toString() , let refreshTokenData = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.refreshToken.rawValue),let refreshToken = refreshTokenData.toString() else {
                return
            }
            viewmodel()?.sendRefreshToken(code: code, refreshToken: refreshToken, pkce: self.pkce)
        } catch  {
        }
    }
    public func dismiss(){
        browser?.presentingViewController?.dismiss(animated: true, completion: {
            self.viewmodel()?.logout()
        })
    }
}
//MARK:- Device Enroll
extension CyberarkAuthProvider {
    
    func addAccessTokenObserver(){
        viewModel?.didReceiveAccessToken = { (status, message, response) in
            self.didReceiveAccessToken!(status, message, response)
        }
    }
    
    func addRefreshTokenObserver(){
        viewModel?.didReceiveRefreshToken = { (status, message, response) in
            self.didReceiveRefreshToken!(status, message, response)
        }
    }
    
}

//MARK:- Plist Configuration
extension CyberarkAuthProvider {

    /// To get the configuration values
    /// - Parameter bundle: main bundle
    /// - Returns: client id, domain etc
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String)? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, threshold: threshold, applicationID: applicationID, logouturi: logouturi)
    }
    
    /// To get the redirect URI
    /// - Parameter bundle: Main bundle
    /// - Returns: redirectURI
    func getRedirectURI(bundle: Bundle) -> String? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let redirectUri = values["redirecturi"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return redirectUri
    }
}
