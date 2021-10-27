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
    var deviceProfileResponse: DeviceProfileInfo? {
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
                    self?.deviceProfileResponse = response
                    self?.save()
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

extension DeviceProfileViewModel {
    /// Save the required parameters to the kaychain
    ///
    internal func save() {
        do {
            if let algorithm = self.deviceProfileResponse?.info?.hmacAlgorithm {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_HmacAlgorithm.rawValue, data: Data(from: algorithm) )
            }
            if let period = self.deviceProfileResponse?.info?.period {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_Period.rawValue, data: Data(from: period))
            }
            if let secretkey = self.deviceProfileResponse?.info?.secretKey {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_SecretKey.rawValue, data:  secretkey.toData() ?? Data())
            }
            if let secretkeyVersion = self.deviceProfileResponse?.info?.secretVersion {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_SecretKey_version.rawValue, data: Data.init(from: secretkeyVersion))
            }
            if let digits = self.deviceProfileResponse?.info?.digits {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_Digits.rawValue, data: Data.init(from: digits))
            }
            if let counter = self.deviceProfileResponse?.info?.counter {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_Counter.rawValue, data: Data.init(from: counter))
            }
            if let oathProfileUuid = self.deviceProfileResponse?.info?.oathProfileUuid {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.profile_uuid.rawValue, data: oathProfileUuid.toData() ?? Data())
            }

        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}
