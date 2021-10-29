
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
    
    /// To login to the account
    /// - Parameter account: account
    func login(account: CyberarkAccount)
    
    /// Invokes auhtentication code related operations
    /// when the application comes from foreground to background.
    /// - Parameter url: url
    func resume(url: URL)

    /// Handler for the referesh token response
    /// - Parameters:
    ///   - Bool: result
    ///
    var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)? { get set }
    /// Handler for the referesh token response
    /// Completion block which will notify when the user logged out
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///
    var didReceiveRefreshToken: ((Bool,String, AccessToken?) -> Void)? { get set }
    
    /// Completion block which will notify when the user logged out
    /// Completion block which will notify when the user logged out
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///
    var didReceiveLogoutResponse: ((Bool,String) -> Void)? { get set }
    
    
    /// To update the device token to the backend
    /// - Parameter token: token
    func handlePushToken(token: Data, baseURL: String)
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

    // PKCE object
    private var pkce: AuthOPKCE?

    /// Builder object
    private var browser: CyberArkBrowser?
    
    /// Handler for the access token response
    public var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)?
    
    /// Handler for the referesh token response
    public var didReceiveRefreshToken: ((Bool,String, AccessToken?) -> Void)?

    /// Handler for the referesh token response
    public var didReceiveLogoutResponse: ((Bool,String) -> Void)?

    /// private initializers
    private init(){
        pkce = AuthOPKCE()
        builder = CyberArkBrowserBuilder(pkce: pkce)
        viewModel = AuthenticationViewModel()
        addAccessTokenObserver()
        addRefreshTokenObserver()
        addLogoutObserver()
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
    private func viewmodel() -> AuthenticationViewModel? {
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
    
    /// Add the access token observer
    func addAccessTokenObserver(){
        viewModel?.didReceiveAccessToken = { (status, message, response) in
            self.didReceiveAccessToken!(status, message, response)
        }
    }
    /// Add the refresh token observer
    func addRefreshTokenObserver(){
        viewModel?.didReceiveRefreshToken = { (status, message, response) in
            self.didReceiveRefreshToken!(status, message, response)
        }
    }
    /// Add the refresh token observer
    func addLogoutObserver(){
        viewModel?.didLoggedOut = { (status, message) in
            self.didReceiveLogoutResponse!(status, message)
        }
    }
}

//MARK:- Plist Configuration
extension CyberarkAuthProvider {
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
//MARK:- Device token and push notifications relateed
extension CyberarkAuthProvider {
    /// To update the device token to the backend
    /// - Parameter token: token
    public func handlePushToken(token: Data, baseURL: String){
        
        viewModel?.updatePushToken(token: token, baseURL: baseURL)
    }
}
