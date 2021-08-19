//
//  EnrollmentClient.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 11/08/21.
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

/// Protocol for enroll device
///
protocol EnrollmentClientProtocol {
    
    /// Enroll device api handler
    /// - Parameters:
    ///   - endpoint: endpoint
    ///   - completion: completion
    func enrollDevice(from endpoint: Endpoint, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void)
}
class EnrollmentClient: APIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension EnrollmentClient: EnrollmentClientProtocol {
    func enrollDevice(from endpoint: Endpoint, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void) {
        let request = endpoint.request
        fetch(with: request, decode: { json -> EnrollResponse? in
            guard let acccessToken = json as? EnrollResponse else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
