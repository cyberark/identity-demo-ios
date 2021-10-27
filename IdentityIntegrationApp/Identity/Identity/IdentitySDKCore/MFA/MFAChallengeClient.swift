//
//  MFAChallengeClient.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 12/10/21.
//

import Foundation

/*
/// ProfileClientProtocol
/// Protocol for getting the profile
///
 */
protocol MFAChallengeClientProtocol {
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - endpoint: endpoint
    ///   - completion: completion
     */
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
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - accesstoken: accesstoken
    ///   - baseURL: baseURL
    ///   - completion: completion
     */
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
