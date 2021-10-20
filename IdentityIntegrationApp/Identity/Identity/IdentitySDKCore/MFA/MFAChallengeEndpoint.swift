//
//  MFAChallengeEndpoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 12/10/21.
//

import Foundation

/*
/// This class constructs the URL Request
/// Push token
///
*/

enum MFAChallengeHeader: String {
    case otpCode = "otpCode"
    case optKeyVersion = "optKeyVersion"
    case otpCodeExpiryInterval = "otpCodeExpiryInterval"
    case userAccepted = "userAccepted"
    case oathProfileUuid = "oathProfileUuid"
    case otpTimestamp = "otpTimestamp"
    case challengeAnswer = "challengeAnswer"

}
internal class MFAChallengeEndpoint {
    
    init () {
    }
}
extension MFAChallengeEndpoint {
    
    /// To get the Refresh token
    /// - Parameters:
    ///   - code: code
    ///   - refreshToken: Refresh token
    /// - Returns: Endpoint
    func getMFAChallengeEndpoint(accesstoken: String, baseURL: String, isUserAccepted: Bool, otpCode: String, optKeyVersion: String, otpCodeExpiryInterval: String, oathProfileUuid: String, otpTimestamp: String, challengeAnswer: String) -> Endpoint {
                
        let post = [
            MFAChallengeHeader.otpCode.rawValue: otpCode,
            MFAChallengeHeader.optKeyVersion.rawValue: optKeyVersion,
            MFAChallengeHeader.otpCodeExpiryInterval.rawValue: otpCodeExpiryInterval,
            MFAChallengeHeader.userAccepted.rawValue: isUserAccepted ? "True" : "False",
            MFAChallengeHeader.oathProfileUuid.rawValue: oathProfileUuid,
            MFAChallengeHeader.otpTimestamp.rawValue: otpTimestamp,
            MFAChallengeHeader.challengeAnswer.rawValue: challengeAnswer
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
        
        let path = "/SubmitOtpCode"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
