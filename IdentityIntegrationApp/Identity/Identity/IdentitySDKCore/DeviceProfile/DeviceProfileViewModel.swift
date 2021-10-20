//
//  DeviceProfileViewModel.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 13/10/21.
//

import Foundation
/*
/// EnrollmentViewModelProtocol
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
internal protocol DeviceProfileViewModelProtocol {
    
    /// To getDeviceProfile
    /// - Parameter baseURL: baseURL
    func getDeviceProfile(baseURL: String)

    /// Completion block which will notify when the mfa response api is finished loading
    /// To get the mfa response
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveProfileApiResponse: ((Bool,String) -> Void)? { get set }
    
}
/*
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
 */
internal class DeviceProfileViewModel {
    
    /// EnrollmentClientProtocol
    private let client : ProfileClientProtocol
    
    /// Callback when enrollment is done
    var didReceiveProfileApiResponse: ((Bool, String) -> Void)?

    ///EnrollResponse
    var enrollResponse: EnrollResponse? {
        didSet {
            self.didReceiveProfileApiResponse!(true, "")
        }
    }
    
    /// Initializer
    /// - Parameter apiClient: apiClient
    init(apiClient: ProfileClientProtocol = ProfileClient()) {
        self.client = apiClient
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
//MARK:- Enroll the device
extension DeviceProfileViewModel: DeviceProfileViewModelProtocol {
    /// Enroll
    /// - Parameter baseURL: baseURL
    func getDeviceProfile(baseURL: String) {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue), let accessToken = data.toString() else {
                return
            }
            client.getDeviceProfile(from: accessToken, baseURL: baseURL) { [weak self] result in
                switch result {
                case .success(let loginFeedResult):
                    guard let response = loginFeedResult else {
                        self?.didReceiveProfileApiResponse!(false, "unable to enroll the device")
                        return
                    }
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
                    self?.enrollResponse = response
                case .failure(let error):
                    self?.didReceiveProfileApiResponse!(false, "unable to enroll the device")
                    print("the error \(error)")
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}

