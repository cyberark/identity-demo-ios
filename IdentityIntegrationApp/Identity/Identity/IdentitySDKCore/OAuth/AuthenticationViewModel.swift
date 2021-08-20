//
//  AuthenticationViewModel.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//
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


/// AuthenticationViewModelProtocol
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
public protocol AuthenticationViewModelProtocol {
    
    /// Completion block which will notify when the acccess token api is finished loading
    /// To get the accesstoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveAccessToken: ((Bool,String) -> Void)? { get set }
    
    /// Completion block which will notify when the acccess token api finished loading
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveRefreshToken: ((Bool,String) -> Void)? { get set }

    /// Completion block which will notify when the user logged out
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///
    var didLoggedOut: ((Bool, String) -> Void)? { get set }

    /// Completion block which will notify when the enroll device api is finished loading
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///
    var didDeviceEnrolled: ((Bool, String) -> Void)?  { get set }
    
    /// To fetch the access token
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    func fetchAuthToken(code: String, pkce: AuthOPKCE?)
}
//MARK:- ViewModel
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
public class AuthenticationViewModel {
   
    private let client : OAuthClientProtocol
    
    public var didReceiveAccessToken: ((Bool,String) -> Void)?
    
    public var didReceiveRefreshToken: ((Bool, String) -> Void)?
    
    public var didDeviceEnrolled: ((Bool, String) -> Void)?

    public var didLoggedOut: ((Bool, String) -> Void)?

    var refreshTokenResponse: AccessToken? {
        didSet {
            self.didReceiveRefreshToken!(true,refreshTokenResponse?.access_token ?? "")
        }
    }
    var authResponse: AccessToken? {
        didSet {
            self.didReceiveAccessToken!(true,authResponse?.access_token ?? "")
        }
    }
    init(apiClient: OAuthClientProtocol = OAuthClient()) {
        self.client = apiClient
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
extension AuthenticationViewModel: AuthenticationViewModelProtocol {

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
                self?.enrollDevice()
            case .failure(let error):
                self?.didReceiveAccessToken!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }
        
    }
    internal func save() {
        do {
            if let accessToken = self.authResponse?.access_token {
                //try KeyChainWrapper.standard.delete(account: KeyChainStorageKeys.accessToken.rawValue)
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.accessToken.rawValue, data: accessToken.toData() ?? Data())
            }
            if let refreshToken = self.authResponse?.refresh_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.refreshToken.rawValue, data: refreshToken.toData() ?? Data())
            }
            if let expiresIn = self.authResponse?.expires_in {
                let date = Date().epirationDate(with: expiresIn)
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.access_token_expiresIn.rawValue, data: Data.init(from: date))
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
    func enrollDevice(){
        CyberArkAuthProvider.enrollDevice()
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
/// To send the refresh token
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
                    self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken")
                    return
                }
                self?.refreshTokenResponse = response
            case .failure(let error):
                self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }

    }
}
//MARK:- AuthenticationViewModelProtocol implementation
//MARK:- Enroll the device
extension AuthenticationViewModel {

    /// To close the current session
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func enrollDevice(code: String, refreshToken: String, pkce: AuthOPKCE?) {

        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getRefreshTokenEndpoint(code: code, refreshToken: refreshToken)
        
        client.endSession(with: endpoint) { [weak self] result in
                  switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didDeviceEnrolled!(false, "unable to fecth accesstoken")
                    return
                }
                self?.refreshTokenResponse = response
            case .failure(let error):
                self?.didDeviceEnrolled!(false, "unable to fecth accesstoken")
                print("the error \(error)")
            }
        }

    }
}
//MARK:- Logout/Close the Session
extension AuthenticationViewModel {
    /// To close the current session
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func logout() {
        do {
            //try KeyChainWrapper.standard.deleteAll()
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
            
        } catch {
            debugPrint("operation error")
        }
        self.didLoggedOut!(true, "unable to close the session")
    }
}
