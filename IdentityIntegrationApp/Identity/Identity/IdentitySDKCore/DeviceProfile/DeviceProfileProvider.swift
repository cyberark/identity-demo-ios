//
//  DeviceProfileProvider.swift
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
