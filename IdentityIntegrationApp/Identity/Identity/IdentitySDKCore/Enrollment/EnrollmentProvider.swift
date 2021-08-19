//
//  EnrollmentManager.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 12/08/21.
//
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

/// Class resposible for OAuth entry Point
/// Shared instance
/// A Protocol for th EnrollmentProvider
internal protocol EnrollmentProviderProtocol {
    func enroll(baseURL: String)
}
/// A class resposible for OAuth entry Point
internal class EnrollmentProvider: EnrollmentProviderProtocol {
    
    //ViewModel
    internal var viewModel:EnrollmentViewModel?
    
    /// initializers
    init(){
        viewModel = EnrollmentViewModel()
        addObserver()
    }
    func addObserver(){
        viewModel?.didReceiveEnrollmentApiResponse = { (result, accessToken) in
            if result {
            }
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
    internal func enroll(baseURL: String) {
        viewmodel()?.enrollDevice(baseURL: baseURL)
    }
    internal func unEnroll(baseURL: String) {
        viewmodel()?.enrollDevice(baseURL: baseURL)
    }
}
