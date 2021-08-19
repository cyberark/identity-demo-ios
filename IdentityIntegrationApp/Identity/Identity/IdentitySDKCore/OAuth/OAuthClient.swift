//
//  OAuthClient.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
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

protocol OAuthClientProtocol {
    func fetchAccessToken(from endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void)
    func endSession(with endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void)
}

class OAuthClient: APIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension OAuthClient: OAuthClientProtocol {
    func fetchAccessToken(from endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        let request = endpoint.request
        fetch(with: request, decode: { json -> AccessToken? in
            guard let acccessToken = json as? AccessToken else { return  nil }
            return acccessToken
        }, completion: completion)
    }
    func endSession(with endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        let request = endpoint.request
        fetch(with: request, decode: { json -> AccessToken? in
            guard let acccessToken = json as? AccessToken else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
