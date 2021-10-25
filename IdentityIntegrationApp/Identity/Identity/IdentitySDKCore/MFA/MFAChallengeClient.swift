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
    func handleMFAChallenge(from isAccepted: Bool, accesstoken: String, baseURL: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void)
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
    func handleMFAChallenge(from isAccepted: Bool, accesstoken: String, baseURL: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void) {
        let endpoint: Endpoint = MFAChallengeEndpoint().getMFAChallengeEndpoint(accesstoken: accesstoken, baseURL: baseURL, isUserAccepted: isAccepted, otpCode: "", optKeyVersion: "", otpCodeExpiryInterval: "", oathProfileUuid: "", otpTimestamp: "", challengeAnswer: "")
        let request = endpoint.request
        fetch(with: request, decode: { json -> EnrollResponse? in
            guard let acccessToken = json as? EnrollResponse else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
