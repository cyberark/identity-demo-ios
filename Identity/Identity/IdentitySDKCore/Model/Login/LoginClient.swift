//
//  LoginClient.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 28/06/21.
//

import Foundation


enum LoginEndPoint: String {
    
    case loginAPI = "/login"
    
    func getAPIEndpoint(loginRequest: LoginRequest) -> Endpoint {
        
        /*
        // Body as string
        let bodyString = "yourParameterString"
        let body = bodyString.data(using: .utf8) */
        
        let parameters = loginRequest.toDictionary
        
        let queryItems = [URLQueryItem(name: "keyName", value: "ValueName") ]
                        
        // Headers
        let headers: [String: String] = [ "Header-key1": "value1",
                                          "Header-key2": "value2" ]

        
        if let body = try? JSONSerialization.data(withJSONObject: parameters) {
            return Endpoint(path: self.rawValue, httpMethod: .post, headers: headers, body: body, queryItems: queryItems, dataType: .JSON)
        }

        // Query item
        
        return Endpoint(path: self.rawValue, httpMethod: .post, headers: headers, body: nil, queryItems: queryItems, dataType: .JSON)
    }
}

class LoginClient: APIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension LoginClient {
    func doLogin(from endpoint: Endpoint, completion: @escaping (Result<LoginResponse?, APIError>) -> Void) {
        let request = endpoint.request
        fetch(with: request, decode: { json -> LoginResponse? in
            guard let movieFeedResult = json as? LoginResponse else { return  nil }
            return movieFeedResult
        }, completion: completion)
    }
}
