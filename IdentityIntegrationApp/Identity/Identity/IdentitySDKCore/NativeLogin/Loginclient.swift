
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
/// LoginClientProtocol
/// Protocol for getting the login authentication
///
 */
/// <#Description#>
protocol LoginClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: <#baseURL description#>
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - completion: <#completion description#>
    func handleLogin(baseURL: String, userName: String, password: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void)
}
/*
/// LoginClient
///
///
 */
class LoginClient: APIClient {
    
    /// url session
    let session: URLSession
    
    /// initializer
    /// - Parameter configuration: configuration
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    /// initializer
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension LoginClient: LoginClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: <#baseURL description#>
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - completion: <#completion description#>
    func handleLogin(baseURL: String, userName: String, password: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void) {
        let endpoint: Endpoint = LoginEndpoint().getLoginEndpoint(baseURL: baseURL, userName: userName, password: password)
        let request = endpoint.request
        fetch(with: request, decode: { json -> LoginResponse? in
            guard let acccessToken = json as? LoginResponse else { return  nil }
            return acccessToken
        }, completion: completion)
        
    }
}
