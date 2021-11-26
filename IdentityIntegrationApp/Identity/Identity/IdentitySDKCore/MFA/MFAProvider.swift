
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
    var viewModel: MFAViewModel?
    
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
