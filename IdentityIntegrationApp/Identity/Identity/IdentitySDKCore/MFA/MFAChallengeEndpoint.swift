
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
/// This class constructs the URL Request
/// MFA Challenge Header
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
        
    /// To handle the MFA
    /// - Parameters:
    ///   - accesstoken: accesstoken
    ///   - baseURL: baseURL
    ///   - isUserAccepted: isUserAccepted
    ///   - otpCode: otpCode
    ///   - optKeyVersion: optKeyVersion
    ///   - otpCodeExpiryInterval: otpCodeExpiryInterval
    ///   - oathProfileUuid: oathProfileUuid
    ///   - otpTimestamp: otpTimestamp
    ///   - challengeAnswer: challengeAnswer
    /// - Returns: Endpoint
    func getMFAChallengeEndpoint(accesstoken: String, baseURL: String, isUserAccepted: Bool, otpCode: String, optKeyVersion: Int, otpCodeExpiryInterval: String, oathProfileUuid: String, otpTimestamp: Int, challengeAnswer: String) -> Endpoint {
                
        let post = [
            MFAChallengeHeader.otpCode.rawValue: otpCode,
            MFAChallengeHeader.optKeyVersion.rawValue: optKeyVersion,
            MFAChallengeHeader.otpCodeExpiryInterval.rawValue: otpCodeExpiryInterval,
            MFAChallengeHeader.userAccepted.rawValue: isUserAccepted ? "True" : "False",
            MFAChallengeHeader.oathProfileUuid.rawValue: oathProfileUuid,
            MFAChallengeHeader.otpTimestamp.rawValue: otpTimestamp,
            MFAChallengeHeader.challengeAnswer.rawValue: challengeAnswer
        ] as [String : Any]
        
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
            debugPrint("error: \(error)")
        }
        
        let path = "/IosAppRest//SubmitOtpCode"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
