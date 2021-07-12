//
//  OAuthClient.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation

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
extension OAuthClient {
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
