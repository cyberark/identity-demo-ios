//
//  SignupEndpoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 18/02/22.
//

import Foundation

/*
/// This class constructs the URL Request
/// Login  Header
///
*/

enum SignupHeader: String {
    case username = "Username"
    case password = "Password"
}
internal class SignupEndpoint {
    
    init () {
    }
}
extension SignupEndpoint {
        
    /// Login Endpoint
    /// - Parameters:
    ///   - sessionToken: sessionToken description
    ///   - baseURL: baseURL description
    ///   - userName: userName description
    ///   - password: password description
    /// - Returns: Endpoint
    func getSignupEndpoint(baseURL: String, userName: String, password: String) -> Endpoint {
                
        let post = [
            LoginHeader.username.rawValue: userName,
            LoginHeader.password.rawValue: password,
        ] as [String : Any]
        
        let jsonData = post.jsonData
        
        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"
        let path = "/api/BasicLogin"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
