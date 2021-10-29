
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
