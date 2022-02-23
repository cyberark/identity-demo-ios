//
//  SignupClient.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 18/02/22.
//

import Foundation

/*
/// LoginClientProtocol
/// Protocol for getting the login authentication
///
 */
/// <#Description#>
protocol SignupClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: baseURL description
    ///   - userName: userName description
    ///   - password: password description
    ///   - completion: completion description
    func handleSignup(baseURL: String, userName: String, password: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void)
}
/*
/// LoginClient
///
///
 
 */
class SignupClient: APIClient {
    
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
extension SignupClient: SignupClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: <#baseURL description#>
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - completion: <#completion description#>
    func handleSignup(baseURL: String, userName: String, password: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void) {
        let endpoint: Endpoint = LoginEndpoint().getLoginEndpoint(baseURL: baseURL, userName: userName, password: password)
        let request = endpoint.request
        fetch(with: request, decode: { json -> LoginResponse? in
            guard let acccessToken = json as? LoginResponse else { return  nil }
            return acccessToken
        }, completion: completion)
        
    }
}
