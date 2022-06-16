
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

/*
/// AuthenticationViewModelProtocol
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
public protocol AuthenticationViewModelProtocol {
    
    /// Completion block which will notify when the acccess token api is finished loading
    /// To get the accesstoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)? { get set }
    
    /// Completion block which will notify when the acccess token api finished loading
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveRefreshToken: ((Bool,String, AccessToken?) -> Void)? { get set }

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
    
    
    /// Handle Pushtoken
    /// - Parameter token: token description
    func updatePushToken(token: Data, baseURL: String)
    
    
    /// Completion block which will notify when the userinfo api finished loading
    /// To get the refreshtoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveUserInfo: ((Bool,String, UserInfo?) -> Void)? { get set }


}
//MARK:- ViewModel
/*
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
 */
public class AuthenticationViewModel {
   
    private let client : OAuthClientProtocol
    
    public var didReceiveAccessToken: ((Bool,String, AccessToken?) -> Void)?
    
    public var didReceiveRefreshToken: ((Bool, String, AccessToken?) -> Void)?
    
    public var didReceiveUserInfo: ((Bool,String, UserInfo?) -> Void)?

    public var didDeviceEnrolled: ((Bool, String) -> Void)?

    public var didLoggedOut: ((Bool, String) -> Void)?

    var refreshTokenResponse: AccessToken? {
        didSet {
            self.didReceiveRefreshToken!(true,refreshTokenResponse?.access_token ?? "", refreshTokenResponse)
        }
    }
    var authResponse: AccessToken? {
        didSet {
            self.didReceiveAccessToken!(true,authResponse?.access_token ?? "", authResponse)
        }
    }
    var userInfoResponse: UserInfo? {
        didSet {
            self.didReceiveUserInfo!(true, "", userInfoResponse)
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
        client.fetchAccessToken(from: pkce ?? AuthOPKCE(), code: code) { [weak self] result in
            switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveAccessToken!(false, "unable to fecth accesstoken", nil)
                    return
                }
                self?.authResponse = response
               // self?.save()
            case .failure(let error):
                self?.didReceiveAccessToken!(false, "unable to fecth accesstoken", nil)
                print("the error \(error)")
            }
        }
        
    }
    
    /// Save the required parameters to the kaychain
    ///
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
    
}
//MARK:- AuthenticationViewModelProtocol implementation
/// To send the refresh token
extension AuthenticationViewModel {

    /// To close the current session
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func sendRefreshToken(code: String, refreshToken: String, pkce: AuthOPKCE?) {
        client.fetchRefreshToken(with: pkce ?? AuthOPKCE(), code: code, refreshToken: refreshToken) { [weak self] result in
            switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken", nil)
                    return
                }
                self?.refreshTokenResponse = response
            case .failure(let error):
                self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken", nil)
                print("the error \(error)")
            }
        }

    }
}

//MARK:- Logout/Close the Session
extension AuthenticationViewModel {
    /// To close the current session
    /// - Parameters:
    public func logout() {
        clearCachedData()
        self.didLoggedOut!(true, "unable to close the session")
    }
    func clearCachedData() {
        do {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnQRLaunch.rawValue)

            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isSessionCreated.rawValue)

            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
            
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_SecretKey.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_SecretKey.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_Period.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_uuid.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_Digits.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_Counter.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.profile_SecretKey_version.rawValue)
            
        } catch {
            debugPrint("error: \(error)")
        }
    }
}
//MARK:- Push token implementation
/// To send the refresh token
extension AuthenticationViewModel {

    /// To close the current session
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func updatePushToken(token: Data, baseURL: String) {
        
        client.updateDeviceToken(with: token, baseURL: baseURL) { [weak self] result in
            switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    //self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken", nil)
                    return
                }
                //self?.refreshTokenResponse = response
            case .failure(let error):
                //self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken", nil)
                print("the error \(error)")
            }
        }
    }
}

//MARK:- Push token implementation
/// To send the refresh token
extension AuthenticationViewModel {

    /// To fetchUserInfo
    /// - Parameters:
    ///   - code: code
    ///   - pkce: pkce
    public func fetchUserInfo(token: String, pkce: AuthOPKCE?) {
        
        client.fetchUserInfo(with: pkce ?? AuthOPKCE(), accessToken: token) { [weak self] result in
            switch result {
            case .success(let loginFeedResult):
                guard let response = loginFeedResult else {
                    self?.didReceiveUserInfo!(false, "unable to fecth the user info", nil)
                    return
                }
                self?.userInfoResponse = response
            case .failure(let error):
                self?.didReceiveRefreshToken!(false, "unable to fecth accesstoken", nil)
                print("the error \(error)")
            }
        }
    }
}

