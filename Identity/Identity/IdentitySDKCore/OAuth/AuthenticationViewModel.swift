//
//  AuthenticationViewModel.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation


/// AuthenticationViewModelProtocol
///
/// Viewmodel protocol
public protocol AuthenticationViewModelProtocol {
    
    var didReceiveAccessToken: ((Bool,String) -> Void)? { get set }
    
    func fetchAuthToken(code: String, pkce: AuthOPKCE?)
}

/// AuthenticationViewModel ViewModel
///
///
public class AuthenticationViewModel: AuthenticationViewModelProtocol {
   
    private let client = OAuthClient()
    
    public var didReceiveAccessToken: ((Bool,String) -> Void)?
    
    var authResponse: AccessToken? {
        didSet {
            self.didReceiveAccessToken!(true,authResponse?.access_token ?? "")
        }
    }
}
extension AuthenticationViewModel {

    /// To fetch the access token
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func fetchAuthToken(code: String, pkce: AuthOPKCE?) {
        
        do {
            try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.grantCode.rawValue, data: code.toData() ?? Data())
        } catch {
            print("Unexpected error: \(error)")
        }
        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getAuthenticationEndpoint(code: code)
        
        client.fetchAccessToken(from: endpoint) { [weak self] result in
            switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                    return
                }
                self?.authResponse = response
                self?.save()
            case .failure(let error):
                self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }
        
    }
    internal func save() {
        do {
            if let accessToken = self.authResponse?.access_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.accessToken.rawValue, data: accessToken.toData() ?? Data())
            }
            if let refreshToken = self.authResponse?.refresh_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.refreshToken.rawValue, data: refreshToken.toData() ?? Data())
            }

        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}
// To Close the session
extension AuthenticationViewModel {

    /// To close the current session
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func sendRefreshToken(code: String, refreshToken: String, pkce: AuthOPKCE?) {

        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getRefreshTokenEndpoint(code: code, refreshToken: refreshToken)
        
        client.endSession(with: endpoint) { [weak self] result in
                  switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                    return
                }
                self?.authResponse = response
            case .failure(let error):
                self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }

    }
}
