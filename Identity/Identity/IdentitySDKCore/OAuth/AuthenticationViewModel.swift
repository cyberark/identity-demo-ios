//
//  AuthenticationViewModel.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation


public protocol AuthenticationViewModelProtocol {
    
    var didReceiveAccessToken: ((Bool,String) -> Void)? { get set }
    
    func fetchAuthToken(code: String, pkce: AuthOPKCE?)
}

/// Oauth ViewModel
public class AuthenticationViewModel: AuthenticationViewModelProtocol {
    
    private let client = OAuthClient()
    
    public var didReceiveAccessToken: ((Bool,String) -> Void)?
    
    var loginResponse: AccessToken? {
        didSet {
            self.didReceiveAccessToken!(true,loginResponse?.access_token ?? "")
        }
    }
}
extension AuthenticationViewModel {

    /// To fetch the access token
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func fetchAuthToken(code: String, pkce: AuthOPKCE?) {
                
        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getAuthenticationEndpoint(code: code)
        
        client.fetchAccessToken(from: endpoint) { [weak self] result in
                  switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                    return
                }
                self?.loginResponse = response
            case .failure(let error):
                self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }

    }
}
