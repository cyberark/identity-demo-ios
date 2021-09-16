
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
/// EnrollmentViewModelProtocol
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
internal protocol EnrollmentViewModelProtocol {
    /// Completion block which will notify when the acccess token api is finished loading
    /// To get the accesstoken
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveEnrollmentApiResponse: ((Bool,String) -> Void)? { get set }
    
    /// To enroll device
    /// - Parameter baseURL: baseURL
    func enrollDevice(baseURL: String)
}
/*
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
 */
 internal class EnrollmentViewModel {
    
    /// EnrollmentClientProtocol
    private let client : EnrollmentClientProtocol
    
    /// Callback when enrollment is done
    var didReceiveEnrollmentApiResponse: ((Bool, String) -> Void)?

    ///EnrollResponse
    var enrollResponse: EnrollResponse? {
        didSet {
            self.didReceiveEnrollmentApiResponse!(true, "")
        }
    }
    
    /// Initializer
    /// - Parameter apiClient: apiClient 
    init(apiClient: EnrollmentClientProtocol = EnrollmentClient()) {
        self.client = apiClient
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
//MARK:- Enroll the device
extension EnrollmentViewModel: EnrollmentViewModelProtocol {
    
    /// Enroll
    /// - Parameter baseURL: baseURL
    internal func enrollDevice(baseURL: String) {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue), let accessToken = data.toString() else {
                return
            }
            client.enrollDevice(from: accessToken, baseURL: baseURL) { [weak self] result in
                switch result {
                case .success(let loginFeedResult):
                    guard let response = loginFeedResult else {
                        self?.didReceiveEnrollmentApiResponse!(false, "unable to enroll the device")
                        return
                    }
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
                    self?.enrollResponse = response
                case .failure(let error):
                    self?.didReceiveEnrollmentApiResponse!(false, "unable to enroll the device")
                    print("the error \(error)")
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}
