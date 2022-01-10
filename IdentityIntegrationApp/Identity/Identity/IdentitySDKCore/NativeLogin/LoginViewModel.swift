
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
/// <#Description#>
internal protocol LoginViewModelProtocol {
    /// Completion block which will notify when the mfa response api is finished loading
    /// To get the mfa response
    /// - Parameters:
    ///   - Bool: result
    ///   - String: error or success message
    var didReceiveLoginApiResponse: ((Bool,String?, String?) -> Void)? { get set }
    
    /// Description
    /// - Parameters:
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - baseURL: <#baseURL description#>
    ///   - completionHandler: <#completionHandler description#>
    func handleLogin(userName: String, password: String, baseURL: String, withCompletionHandler completionHandler:
                   CheckNotificationResult?)
}
/*
/// AuthenticationViewModel
/// Responsible for the api client and all the data related operations
///
 */
 internal class LoginViewModel {
    
    /// EnrollmentClientProtocol
    private let client : LoginClientProtocol
    
    /// Callback when enrollment is done
    var didReceiveLoginApiResponse: ((Bool, String?, String?) -> Void)?

    ///EnrollResponse
    var loginResponse: LoginResponse? {
        didSet {
            self.didReceiveLoginApiResponse!(true, loginResponse?.errorMessage ?? "" , loginResponse?.loginInfo?.sessionUuid ?? "")
        }
    }
    
    /// Initializer
    /// - Parameter apiClient: apiClient
    init(apiClient: LoginClientProtocol = LoginClient()) {
        self.client = apiClient
    }
}
//MARK:- AuthenticationViewModelProtocol implementation
//MARK:- Enroll LoginViewModel device
extension LoginViewModel: LoginViewModelProtocol {
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - baseURL: <#baseURL description#>
    ///   - completionHandler: <#completionHandler description#>
    func handleLogin(userName: String, password: String, baseURL: String, withCompletionHandler completionHandler:
                     CheckNotificationResult?) {
        do {
            client.handleLogin(baseURL: baseURL, userName: userName, password: password) { [weak self] result in
                completionHandler?()
                switch result {
                case .success(let loginFeedResult):
                    guard let response: LoginResponse = loginFeedResult else {
                        self?.didReceiveLoginApiResponse!(false, loginFeedResult?.errorMessage ?? "", nil)
                        return
                    }
                    self?.loginResponse = response
                case .failure(let error):
                    self?.didReceiveLoginApiResponse!(false, "Unable to login", nil)
                    print("the error \(error)")
                }
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}

