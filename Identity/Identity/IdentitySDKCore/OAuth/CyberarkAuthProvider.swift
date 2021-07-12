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
    
    public func login(){
        builder?.build().login(completion: { (status, error) in
            print(status ?? "")
        })
    }
    func fetchAuthToken(code: String) {
        viewmodel()?.fetchAuthToken(code: code, pkce: self.pkce)
    }
    public func resume(url: URL) {
        guard let code = url.queryParameter(with:"code") else {
            return
        }
        fetchAuthToken(code: code)
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
