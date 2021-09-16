
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
/// OAuthClientProtocol
/// This class resposible for fetch access token
 */
protocol OAuthClientProtocol {
    
    /// To fetch the access tokn
    /// - Parameters:
    ///   - pkce: pkce
    ///   - code: code
    ///   - completion: completion
    func fetchAccessToken(from pkce: AuthOPKCE, code: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void)
    
    /// To get the refresh token
    /// - Parameters:
    ///   - pkce: pkce
    ///   - code: code
    ///   - refreshToken: refreshToken
    ///   - completion: completion
    func fetchRefreshToken(with pkce: AuthOPKCE, code: String, refreshToken: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void)
}

class OAuthClient: APIClient {
    
    
    /// Url session
    let session: URLSession
    
    /// Initializer
    /// - Parameter configuration: configuration
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    /// Initializer
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension OAuthClient: OAuthClientProtocol {
    
    /// To fetch the access tokn
    /// - Parameters:
    ///   - pkce: pkce
    ///   - code: code
    ///   - completion: completion
    func fetchAccessToken(from pkce: AuthOPKCE, code: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getAuthenticationEndpoint(code: code)
        let request = endpoint.request
        fetch(with: request, decode: { json -> AccessToken? in
            guard let acccessToken = json as? AccessToken else { return  nil }
            return acccessToken
        }, completion: completion)
    }
    /// To get the refresh token
    /// - Parameters:
    ///   - pkce: pkce
    ///   - code: code
    ///   - refreshToken: refreshToken
    ///   - completion: completion
    func fetchRefreshToken(with pkce: AuthOPKCE, code: String, refreshToken: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        let endpoint: Endpoint = OAuthEndPoint(pkce: pkce).getRefreshTokenEndpoint(code: code, refreshToken: refreshToken)
        let request = endpoint.request
        fetch(with: request, decode: { json -> AccessToken? in
            guard let acccessToken = json as? AccessToken else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
