
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
public protocol DeviceProfileProviderProtocol {
    /*
    /// getDeviceProfile
    /// - Parameter baseURL: base URL
     */
    func getDeviceProfile(baseURL: String)
    /*
    /// Callback when MFA is done
    /// Handler for the enrollment api response
     */
    var didReceiveProfileApiResponse: ((Bool,String) -> Void)? { get set }

}
/*
/// A class resposible for Enrollment entry Point
 */
public class DeviceProfileProvider: DeviceProfileProviderProtocol {
   
    
    /// callback when enrollmentt is done
    public var didReceiveProfileApiResponse: ((Bool, String) -> Void)?

    //ViewModel
    internal var viewModel: DeviceProfileViewModel?
    
    /// initializers
    public init(){
        viewModel = DeviceProfileViewModel()
        addObserver()
    }
    /// Handler for the enrollment api response
    func addObserver(){
        viewModel?.didReceiveProfileApiResponse = { (result, accessToken) in
            self.didReceiveProfileApiResponse!(result, accessToken)
        }
    }
}
//MARK:-
extension DeviceProfileProvider {
    /// ViewModel
    /// - Returns: Viewmodel
    internal func viewmodel() -> DeviceProfileViewModel? {
        return viewModel
    }
    public func getDeviceProfile(baseURL: String) {
        viewmodel()?.getDeviceProfile(baseURL: baseURL)
    }
}
