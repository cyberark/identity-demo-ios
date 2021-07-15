//
//  QRCodeAuthClient.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 13/07/21.
//

import Foundation
class QRCodeAuthClient: APIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    convenience init() {
        self.init(configuration: .default)
    }
}

extension QRCodeAuthClient {
    func featchQRAuth(from endpoint: Endpoint, completion: @escaping (Result<QRAuthModel?, APIError>) -> Void) {
        let request = endpoint.request
        print("endpoint request \(request)")
        fetch(with: request, decode: { json -> QRAuthModel? in
            guard let acccessToken = json as? QRAuthModel else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
