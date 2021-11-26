
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
/// ProfileClientProtocol
/// Protocol for getting the profile
///
 */
protocol MFAChallengeClientProtocol {
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
    func handleMFAChallenge(from isAccepted: Bool, accesstoken: String, baseURL: String, challenge: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void)
}
/*
/// EnrollmentClient
/// for enroll device
///
 */
class MFAChallengeClient: APIClient {
    
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
extension MFAChallengeClient: MFAChallengeClientProtocol {
    
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
    func handleMFAChallenge(from isAccepted: Bool, accesstoken: String, baseURL: String, challenge: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void) {
        
        do {
            guard let secretData = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_SecretKey.rawValue) else {
                return
            }
            guard let dataAlogorithm = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_HmacAlgorithm.rawValue) else {
                return
            }
            guard let dataPeriod = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_Period.rawValue) else {
                return
            }
            guard let datauuid = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_uuid.rawValue), let uuidString = datauuid.toString() else {
                return
            }
            guard let datadigits = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_Digits.rawValue) else {
                return
            }
            guard let dataCounter = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_Counter.rawValue) else {
                return
            }
            guard let dataversion = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.profile_SecretKey_version.rawValue)else {
                return
            }
            let algorithm = dataAlogorithm.to(type: Int.self)
            let period = dataPeriod.to(type: Int.self)
            let digits = datadigits.to(type: Int.self)
            let counter = dataCounter.to(type: Int.self)
            let version = dataversion.to(type: Int.self)
            let timeInterval = Date().getCurrentMillis()
            let otpGenerator = TOTPGenerator.init(secret: secretData, algorithm: algorithm, digits: digits, counter: UInt64(counter), period: period)
            let otp = otpGenerator?.generateOTP()
            let otpHash = otpGenerator?.sha256(data: otp?.toData() ?? Data())
            let endpoint: Endpoint = MFAChallengeEndpoint().getMFAChallengeEndpoint(accesstoken: accesstoken, baseURL: baseURL, isUserAccepted: isAccepted, otpCode: otp ?? "", optKeyVersion: version, otpCodeExpiryInterval: String(period), oathProfileUuid: uuidString, otpTimestamp: timeInterval, challengeAnswer: challenge)
            let request = endpoint.request
            fetch(with: request, decode: { json -> EnrollResponse? in
                guard let acccessToken = json as? EnrollResponse else { return  nil }
                return acccessToken
            }, completion: completion)
            
        } catch {
            print("Unexpected error: \(error)")
        }
      
    }
}
