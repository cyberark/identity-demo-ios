//
//  QRAuthEndPoint.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 13/07/21.
//

import Foundation

struct QRAuthEndPoint {
    func endpoint(code: String, access_token: String) -> Endpoint {
        let accessToken = "Bearer \(access_token)"
        debugPrint("AccessCode for qrcode endpoint \(accessToken)")
        let headers = ["X-IDAP-NATIVE-CLIENT" : "true",
                       "Authorization" : accessToken]
        let queryItems = [URLQueryItem]()
        let parameters: [String: String] = [:]
        if let body = try? JSONSerialization.data(withJSONObject: parameters) {
            return Endpoint(path: nil,
                            httpMethod: .post,
                            headers: headers,
                            body: body,
                            queryItems: queryItems,
                            dataType: .JSON,
                            base: code)
        }
        return Endpoint(path: nil,
                        httpMethod: .post,
                        headers: headers,
                        body: nil,
                        queryItems: queryItems,
                        dataType: .JSON,
                        base: code)
    }
}


