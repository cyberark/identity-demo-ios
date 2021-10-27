//
//  MFAViewModel.swift
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
internal protocol MFAViewModelProtocol {
    /// Completion block which will notify when the mfa response api is finished loading
    /// To get the mfa response
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveMFAApiResponse: ((Bool,String) -> Void)? { get set }
    
    /// To handleMFA device
    /// - Parameter baseURL: baseURL
    func handleMFA(isAccepted: Bool, challenge: String, baseURL: String, withCompletionHandler completionHandler:
                   CheckNotificationResult?)
}
/*
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
 */
 internal class MFAViewModel {
    
    /// EnrollmentClientProtocol
    private let client : MFAChallengeClientProtocol
    
    /// Callback when enrollment is done
    var didReceiveMFAApiResponse: ((Bool, String) -> Void)?

    ///EnrollResponse
    var enrollResponse: EnrollResponse? {
        didSet {
            self.didReceiveMFAApiResponse!(true, "")
        }
    }
    
    /// Initializer
    /// - Parameter apiClient: apiClient
    init(apiClient: MFAChallengeClientProtocol = MFAChallengeClient()) {
        self.client = apiClient
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
//MARK:- Enroll the device
extension MFAViewModel: MFAViewModelProtocol {
    
    /// Enroll
    /// - Parameter baseURL: baseURL
    internal func handleMFA(isAccepted: Bool, challenge: String, baseURL: String, withCompletionHandler completionHandler:
                            CheckNotificationResult?) {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue), let accessToken = data.toString() else {
                return
            }
            client.handleMFAChallenge(from: isAccepted, accesstoken: accessToken, baseURL: baseURL, challenge: challenge) { [weak self] result in
                completionHandler?()
                switch result {
                case .success(let loginFeedResult):
                    guard let response = loginFeedResult else {
                        self?.didReceiveMFAApiResponse!(false, "unable to approve the identity")
                        return
                    }
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
                    self?.enrollResponse = response
                case .failure(let error):
                    self?.didReceiveMFAApiResponse!(false, "unable to approve the identity")
                    print("the error \(error)")
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}

