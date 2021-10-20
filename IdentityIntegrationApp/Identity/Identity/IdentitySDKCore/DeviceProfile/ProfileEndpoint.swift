//
//  ProfileEndpoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 11/10/21.
//

import Foundation

/*
/// This class constructs the URL Request
/// Push token
///
*/

enum ProfileHeader: String {
    case deviceid = "DeviceID"
}
internal class ProfileEndpoint {
    
    init () {
    }
}
extension ProfileEndpoint {
    
    /// To get the Refresh token
    /// - Parameters:
    ///   - code: code
    ///   - refreshToken: Refresh token
    /// - Returns: Endpoint
    func getProfileEndPoint(accesstoken: String, baseURL: String) -> Endpoint {
        
        let udid =  DeviceManager.shared.getUUID()

        let post = [
            PushTokenHeader.deviceid.rawValue: udid,
        ]
        
        let jsonData = post.jsonData
        
        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"
        do {
            if let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue), let accessToken = data.toString()  {
                let accessToken = "Bearer \(accessToken)"
                headers[HttpHeaderKeys.authorization.rawValue] = accessToken
            }
        } catch  {
        }
        
        let path = "/Oath/GetProfileListForDevice"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
