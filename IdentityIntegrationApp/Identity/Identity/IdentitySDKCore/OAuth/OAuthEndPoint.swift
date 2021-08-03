//
//  IdentityAuth.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 05/07/21.
//

import Foundation


/// This class constructs the URL Request
///  OAuth + PKCE web based login
///

public class OAuthEndPoint {
    
    /// clientId configured in the server
    var clientId: String? = nil
    /// domain configured in the server
    var domain: String? = nil
    /// scope configured in the server
    var scope: String? = nil
    /// redirectUri configured in the server
    var redirectUri: String? = nil
    /// threshold configured in the server
    var threshold: Int? = 60
    /// pkce configured
    var pkce: AuthOPKCE?
    /// applicationID configured in the server
    var applicationID: String? = nil
    /// logoutUri configured in the server
    var logoutUri: String? = nil

    /*public convenience init(pkce: AuthOPKCE?) {
     self.init()
     self.pkce = pkce
     }*/
    init (pkce: AuthOPKCE?) {
        config()
        self.pkce = pkce
    }
    
    /// Initial Configuration
    /// To get the configured values
    /// 
    func config()  {
        guard
            let path = Bundle.main.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Seems like IdentityConfiguration.plist file is missing in the main bundle!")
            return
        }
        
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return
        }
        self.clientId = clientId
        self.domain = domain
        self.scope = scope
        self.redirectUri = redirectUri
        self.threshold = threshold
        self.applicationID = applicationID
        self.logoutUri = applicationID

    }
}
extension OAuthEndPoint {
    
    /// To get the autherization endpoint
    /// - Returns: Endpoint
    func getAuthorizationEndpoint() -> Endpoint {
        let parameters: [String: String] = [:]
    
        let queryItems = [URLQueryItem(name: OAuth2Header.responseType.rawValue, value: OAuth2Header.code.rawValue),
                          URLQueryItem(name: OAuth2Header.clientId.rawValue, value: self.clientId),
                          URLQueryItem(name: OAuth2Header.scope.rawValue, value: self.scope),
                          URLQueryItem(name: OAuth2Header.redirecUri.rawValue, value: self.redirectUri),
                          URLQueryItem(name: OAuth2Header.codeChallenge.rawValue, value: self.pkce?.challenge),
                          URLQueryItem(name: OAuth2Header.codeChallengeMethod.rawValue, value: self.pkce?.method)]
                        
        let headers: [String: String] = [:]
        let path = "/oauth2/authorize/\(applicationID ?? "")"

        if let body = try? JSONSerialization.data(withJSONObject: parameters) {
            return Endpoint(path:path, httpMethod: .get, headers: headers, body: body, queryItems: queryItems, dataType: .JSON, base: self.domain!)
        }
        return Endpoint(path: path, httpMethod: .get, headers: headers, body: nil, queryItems: queryItems, dataType: .JSON, base: self.domain!)
    }
    
    /// To get the access token from the auth code
    /// - Parameter code: code
    /// - Returns: Endpoint
    func getAuthenticationEndpoint(code: String) -> Endpoint {
        
        let postData = NSMutableData(data: "\(OAuth2Header.grantType.rawValue)=\(OAuth2Header.grantTypeAuthCode.rawValue)".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.code.rawValue)=\(code)".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.clientId.rawValue)=\(self.clientId ?? "")".data(using: String.Encoding.utf8)!)
        //postData.append("&\(OAuth2Header.scope.rawValue)=\(self.scope ?? "")".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.redirecUri.rawValue)=\(self.redirectUri ?? "")".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.codeVerifier.rawValue)=\(self.pkce?.verifier ?? "")".data(using: String.Encoding.utf8)!)
        //postData.append("&\(OAuth2Header.codeChallengeMethod.rawValue)=\(self.pkce?.method ?? "")".data(using: String.Encoding.utf8)!)
        
        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = HttpHeaderKeys.applicationfomrurlencoded.rawValue
        
        let path = "/oauth2/Token/\(applicationID ?? "")"
        
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: postData as Data, queryItems: queryItems, dataType: .JSON, base: self.domain!)
    }
    
    /// To Close the session
    /// - Returns: Endpoint
    func getCloseSessionEndpoint() -> Endpoint {
        let parameters: [String: String] = [:]
    
        let queryItems = [URLQueryItem(name: OAuth2Header.postLogoutRedirectUri.rawValue, value: self.redirectUri)]
                        
        let headers: [String: String] = [:]
        let path = "/oauth2/endsession"

        if let body = try? JSONSerialization.data(withJSONObject: parameters) {
            return Endpoint(path:path, httpMethod: .get, headers: headers, body: body, queryItems: queryItems, dataType: .JSON, base: self.domain!)
        }
        return Endpoint(path: path, httpMethod: .get, headers: headers, body: nil, queryItems: queryItems, dataType: .JSON, base: self.domain!)
    }
    
    /// To get the Refresh token
    /// - Parameters:
    ///   - code: code
    ///   - refreshToken: Refresh token
    /// - Returns: Endpoint
    func getRefreshTokenEndpoint(code: String, refreshToken: String) -> Endpoint {
        let postData = NSMutableData(data: "\(OAuth2Header.grantType.rawValue)=\(OAuth2Header.refreshToken.rawValue)".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.clientId.rawValue)=\(self.clientId ?? "")".data(using: String.Encoding.utf8)!)
        postData.append("&\(OAuth2Header.refreshToken.rawValue)=\(refreshToken)".data(using: String.Encoding.utf8)!)

        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = HttpHeaderKeys.applicationfomrurlencoded.rawValue
        
        let path = "/oauth2/Token/\(applicationID ?? "")"
        
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: postData as Data, queryItems: queryItems, dataType: .JSON, base: self.domain!)
    }
}
