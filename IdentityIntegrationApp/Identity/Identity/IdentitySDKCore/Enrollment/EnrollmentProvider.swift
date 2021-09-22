
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
/// EnrollmentProviderProtocol
/// Class resposible for OAuth entry Point
/// Shared instance
/// A Protocol for th EnrollmentProvider
 */
public protocol EnrollmentProviderProtocol {
    /*
    /// Enroll
    /// - Parameter baseURL: base URL
     */
    func enroll(baseURL: String)
    /*
    /// Callback when enrollment is done
    /// Handler for the enrollment api response
     */
    var didReceiveEnrollmentApiResponse: ((Bool,String) -> Void)? { get set }

}
/*
/// A class resposible for OAuth entry Point
 */
public class EnrollmentProvider: EnrollmentProviderProtocol {
    
    /// callback when enrollmentt is done
    public var didReceiveEnrollmentApiResponse: ((Bool, String) -> Void)?

    //ViewModel
    internal var viewModel:EnrollmentViewModel?
    
    /// initializers
    public init(){
        viewModel = EnrollmentViewModel()
        addObserver()
    }
    /// Handler for the enrollment api response
    func addObserver(){
        viewModel?.didReceiveEnrollmentApiResponse = { (result, accessToken) in
            self.didReceiveEnrollmentApiResponse!(result, accessToken)
        }
    }
}
//MARK:-
extension EnrollmentProvider {
    /// ViewModel
    /// - Returns: Viewmodel
    internal func viewmodel() -> EnrollmentViewModel? {
        return viewModel
    }
    public func enroll(baseURL: String) {
        viewmodel()?.enrollDevice(baseURL: baseURL)
    }
}
