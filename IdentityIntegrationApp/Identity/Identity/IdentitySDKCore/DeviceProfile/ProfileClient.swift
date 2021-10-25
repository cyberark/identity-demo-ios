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
    func getDeviceProfile(from accesstoken: String, baseURL: String, completion: @escaping (Result<DeviceProfileInfo?, APIError>) -> Void)
    
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - accesstoken: accesstoken
    ///   - baseURL: baseURL
    ///   - completion: completion
     */
    func getDeviceProfile(with aspxToken: String, baseURL: String, completion: @escaping (Result<DeviceProfile?, APIError>) -> Void)

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
    func getDeviceProfile(from accesstoken: String, baseURL: String, completion: @escaping (Result<DeviceProfileInfo?, APIError>) -> Void) {
        let endpoint: Endpoint = ProfileEndpoint().getProfileEndPoint(accesstoken: accesstoken, baseURL: baseURL)
        let request = endpoint.request
        fetch(with: request, decode: { json -> DeviceProfileInfo? in
            guard let acccessToken = json as? DeviceProfileInfo else { return  nil }
            return acccessToken
        }, completion: completion)
    }
    /*
    /// To get the device profile the device
    /// - Parameters:
    ///   - accesstoken: accesstoken
    ///   - baseURL: baseURL
    ///   - completion: completion
     */
    func getDeviceProfile(with aspxToken: String, baseURL: String, completion: @escaping (Result<DeviceProfile?, APIError>) -> Void) {
        let endpoint: Endpoint = ProfileEndpoint().getProfileEndPoint(aspxToken: aspxToken, baseURL: baseURL)
        let request = endpoint.request
        fetch(with: request, decode: { json -> DeviceProfile? in
            guard let acccessToken = json as? DeviceProfile else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
