//
//  ProfileClient.swift
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
protocol ProfileClientProtocol {
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - endpoint: endpoint
    ///   - completion: completion
     */
    func getDeviceProfile(from accesstoken: String, baseURL: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void)
}
/*
/// EnrollmentClient
/// for enroll device
///
 */
class ProfileClient: APIClient {
    
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
extension ProfileClient: ProfileClientProtocol {
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - accesstoken: accesstoken
    ///   - baseURL: baseURL
    ///   - completion: completion
     */
    func getDeviceProfile(from accesstoken: String, baseURL: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void) {
        let endpoint: Endpoint = ProfileEndpoint().getProfileEndPoint(accesstoken: accesstoken, baseURL: baseURL)
        let request = endpoint.request
        fetch(with: request, decode: { json -> EnrollResponse? in
            guard let acccessToken = json as? EnrollResponse else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
