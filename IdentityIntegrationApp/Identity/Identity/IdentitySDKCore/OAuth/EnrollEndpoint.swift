//
//  EnrollEndpoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 23/07/21.
//

import Foundation

internal enum EnrollHeader: String {
    case versioncode = "VersionCode"
    case versionname = "VersionName"
    case mobilemanagerversion = "MobileManagerVersion"
    case name = "Name"
    case osversion = "OSVersion"
    case osname = "OSName"
    case modelname = "ModelName"
    case udid = "udid"
    case ostype = "osType"
    case vendorudid = "vendorUdid"
    case pkgname = "pkgname"
    case clientpackageid = "ClientPackageId"
    case clienturlscheme = "ClientUrlScheme"
}


/// This class constructs the URL Request
///  OAuth + PKCE web based login
///
fileprivate class EnrollEndPoint {
    
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

    init () {
        config()
    }
    
    /// Initial Configuration
    /// To get the configured values
    ///
    func config()  {

    }
}
extension OAuthEndPoint {
    
    /// To get the autherization endpoint
    /// - Returns: Endpoint
    func getEnrollDeviceEndpoint() -> Endpoint {
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
}
