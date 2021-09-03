
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
/// QRAuthEndPoint
/// It will create the QR authentication endpoint
/// QRAuthEndPoint
 */

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


