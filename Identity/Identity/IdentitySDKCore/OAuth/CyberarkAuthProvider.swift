//
//  CyberarkAuthProvider.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation

public var CyberArkAuthProvider: CyberarkAuthProvider {
    return CyberarkAuthProvider.shared
}

public protocol CyberarkAuthProviderProtocol: class {
    func login()
    func resume(url: URL)
}
public class CyberarkAuthProvider: CyberarkAuthProviderProtocol {
    
    static fileprivate var shared = CyberarkAuthProvider()
    
    private var builder: CyberArkBrowserBuilder?
    
    private var viewModel:AuthenticationViewModel?

    var pkce: AuthOPKCE?

    private init(){
        pkce = AuthOPKCE()
        builder = CyberArkBrowserBuilder(pkce: pkce)
        viewModel = AuthenticationViewModel()
    }
    
}
extension CyberarkAuthProvider {
    public func webAuth() -> CyberArkBrowserBuilder? {
        return builder
    }
    public func viewmodel() -> AuthenticationViewModel? {
        return viewModel
    }
}
extension CyberarkAuthProvider {
    public func login(){
        builder?.build().login(completion: { (status, error) in
            print(status ?? "")
        })
    }
    func fetchAuthToken(code: String) {
        viewmodel()?.fetchAuthToken(code: code, pkce: self.pkce)
    }
    public func sendRefreshToken() {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.grantCode.rawValue), let code = data.toString() , let refreshTokenData = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.refreshToken.rawValue),let refreshToken = refreshTokenData.toString() else {
                return
            }
            viewmodel()?.sendRefreshToken(code: code, refreshToken: refreshToken, pkce: self.pkce)
        } catch  {
        }
    }

    public func resume(url: URL) {
        guard let code = url.queryParameter(with:"code") else {
            return
        }
        
        fetchAuthToken(code: code)
    }
    public func dismiss(){
        do {
            try KeyChainWrapper.standard.deleteAll()

        } catch {
        }
        builder?.build().presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

