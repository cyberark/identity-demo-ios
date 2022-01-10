
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

public protocol LoginProviderProtocol {
    /*
    /// handleMFAChallenge
    /// - Parameter baseURL: base URL
     */
    func handleLogin(userName: String, password: String, baseURL: String, withCompletionHandler completionHandler:
                   CheckNotificationResult?)
    /*
    /// Callback when MFA is done
    /// Handler for the enrollment api response
     */
    var didReceiveLoginApiResponse: ((Bool,String?, String?) -> Void)? { get set}

}
/*
/// A class resposible for Enrollment entry Point
 */
public class LoginProvider: LoginProviderProtocol {
    
    /// callback when enrollmentt is done
    public var didReceiveLoginApiResponse: ((Bool, String?, String?) -> Void)?

    //ViewModel
    var viewModel: LoginViewModel?
    
    /// initializers
    public init(){
        viewModel = LoginViewModel()
        addObserver()
    }
    /// Handler for the enrollment api response
    func addObserver(){
        viewModel?.didReceiveLoginApiResponse = { (result, message, sessionToken) in
            self.didReceiveLoginApiResponse!(result, message, sessionToken)
        }
    }
}
//MARK:-
extension LoginProvider {
    /// ViewModel
    /// - Returns: Viewmodel
    internal func viewmodel() -> LoginViewModel? {
        return viewModel
    }
    public func handleLogin(userName: String, password: String, baseURL: String, withCompletionHandler completionHandler:
                     CheckNotificationResult?) {
        viewmodel()?.handleLogin(userName: userName, password: password, baseURL: baseURL, withCompletionHandler: completionHandler)
    }
}
