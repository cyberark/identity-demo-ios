//
//  CyberarkAuthProvider.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation


/// A class resposible for OAuth entry Point
/// Shared instance
///
public var CyberArkAuthProvider: CyberarkAuthProvider {
    return CyberarkAuthProvider.shared
}

/// A Protocol for th CyberArkAuthProvider
public protocol CyberarkAuthProviderProtocol: class {
    func login()
    func resume(url: URL)
}
/// A class resposible for OAuth entry Point
public class CyberarkAuthProvider: CyberarkAuthProviderProtocol {
    
    /// Shared Instance
    static fileprivate var shared = CyberarkAuthProvider()
    
    /// Builder object
    private var builder: CyberArkBrowserBuilder?
    
    //ViewModel
    private var viewModel:AuthenticationViewModel?

    // PKCE object creation
    var pkce: AuthOPKCE?

    /// private initializers
    private init(){
        pkce = AuthOPKCE()
        builder = CyberArkBrowserBuilder(pkce: pkce)
        viewModel = AuthenticationViewModel()
    }
    
}
//MARK:-
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
//MARK:-
extension CyberarkAuthProvider {
    
    /// Entrypoint
    /// Login
    ///
    public func login(){
        builder?.build().login(completion: { (status, error) in
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
   
    /*public func dismiss( completion: (Bool)->()){
        do {
            try KeyChainWrapper.standard.deleteAll()

        } catch {
        }
        completion(true)
    }*/
}
//MARK:- To send refresh token related operations
extension CyberarkAuthProvider {
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
        builder?.build().presentingViewController?.dismiss(animated: true, completion: {
            self.viewmodel()?.logout()
        })
    }
}
//MARK:- read from plist
extension CyberarkAuthProvider {
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
