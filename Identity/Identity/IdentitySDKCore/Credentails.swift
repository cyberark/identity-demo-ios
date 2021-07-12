//
//  Credentails.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 02/07/21.
//

import Foundation

protocol JSONObjectPayload {
    init?(json: [String: Any])
}

public class Credentials: NSObject, JSONObjectPayload, NSSecureCoding {

    /// Token used that allows calling to the requested APIs (audience sent on Auth)
    @objc public let accessToken: String?
    /// Type of the access token
    @objc public let tokenType: String?
    /// When the access_token expires
    @objc public let expiresIn: Date?
    /// If the API allows you to request new access tokens and the scope `offline_access` was included on Auth
    @objc public let refreshToken: String?
    // Token that details the user identity after authentication
    @objc public let idToken: String?
    // Granted scopes, only populated when a requested scope or scopes was not granted and Auth is OIDC Conformant
    @objc public let scope: String?

    @objc public init(accessToken: String? = nil, tokenType: String? = nil, idToken: String? = nil, refreshToken: String? = nil, expiresIn: Date? = nil, scope: String? = nil) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.scope = scope
    }

    convenience required public init(json: [String: Any]) {
        var expiresIn: Date?

        if let value = json["expires_in"] {
            let string = String(describing: value)
            if let double = NumberFormatter().number(from: string)?.doubleValue {
                expiresIn = Date(timeIntervalSinceNow: double)
            }
        }

        self.init(accessToken: json["access_token"] as? String, tokenType: json["token_type"] as? String, idToken: json["id_token"] as? String, refreshToken: json["refresh_token"] as? String, expiresIn: expiresIn, scope: json["scope"] as? String)
    }

    // MARK: - NSSecureCoding

    convenience required public init?(coder aDecoder: NSCoder) {
        let accessToken = aDecoder.decodeObject(forKey: "accessToken")
        let tokenType = aDecoder.decodeObject(forKey: "tokenType")
        let idToken = aDecoder.decodeObject(forKey: "idToken")
        let refreshToken = aDecoder.decodeObject(forKey: "refreshToken")
        let expiresIn = aDecoder.decodeObject(forKey: "expiresIn")
        let scope = aDecoder.decodeObject(forKey: "scope")

        self.init(accessToken: accessToken as? String, tokenType: tokenType as? String, idToken: idToken as? String, refreshToken: refreshToken as? String, expiresIn: expiresIn as? Date, scope: scope as? String)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.accessToken, forKey: "accessToken")
        aCoder.encode(self.tokenType, forKey: "tokenType")
        aCoder.encode(self.idToken, forKey: "idToken")
        aCoder.encode(self.refreshToken, forKey: "refreshToken")
        aCoder.encode(self.expiresIn, forKey: "expiresIn")
        aCoder.encode(self.scope, forKey: "scope")
    }

    public static var supportsSecureCoding: Bool = true
}
