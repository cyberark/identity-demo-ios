//
//  MFAProvider.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 13/10/21.
//

import Foundation
/*
/// MFAProviderProtocol
/// Class resposible for MFA entry Point
/// A Protocol for th MFAProviderProtocol
 */
public typealias CheckNotificationResult = () -> Void

public protocol MFAProviderProtocol {
    /*
    /// handleMFAChallenge
    /// - Parameter baseURL: base URL
     */
    func handleMFAChallenge(isAccepted: Bool, challenge: String, baseURL: String, withCompletionHandler completionHandler:
                            CheckNotificationResult?)
    /*
    /// Callback when MFA is done
    /// Handler for the enrollment api response
     */
    var didReceiveMFAApiResponse: ((Bool,String) -> Void)? { get set }

}
/*
/// A class resposible for Enrollment entry Point
 */
public class MFAChallengeProvider: MFAProviderProtocol {
    
    /// callback when enrollmentt is done
    public var didReceiveMFAApiResponse: ((Bool, String) -> Void)?

    //ViewModel
    internal var viewModel: MFAViewModel?
    
    /// initializers
    public init(){
        viewModel = MFAViewModel()
        addObserver()
    }
    /// Handler for the enrollment api response
    func addObserver(){
        viewModel?.didReceiveMFAApiResponse = { (result, accessToken) in
            self.didReceiveMFAApiResponse!(result, accessToken)
        }
    }
}
//MARK:-
extension MFAChallengeProvider {
    /// ViewModel
    /// - Returns: Viewmodel
    internal func viewmodel() -> MFAViewModel? {
        return viewModel
    }
    public func handleMFAChallenge(isAccepted: Bool, challenge: String, baseURL: String, withCompletionHandler completionHandler:
                                   CheckNotificationResult?) {
        viewmodel()?.handleMFA(isAccepted: isAccepted, challenge: challenge, baseURL: baseURL, withCompletionHandler: completionHandler)
    }
}
