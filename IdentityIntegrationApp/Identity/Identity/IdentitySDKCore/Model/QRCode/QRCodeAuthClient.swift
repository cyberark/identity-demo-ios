
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
protocol QRCodeAuthClientProtocol {
    
    func performQRAuthentication(from qrCode: String, access_token: String, completion: @escaping (Result<QRAuthModel?, APIError>) -> Void)
}
class QRCodeAuthClient: APIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    convenience init() {
        self.init(configuration: .default)
    }
}

extension QRCodeAuthClient: QRCodeAuthClientProtocol {
    func performQRAuthentication(from qrCode: String, access_token: String, completion: @escaping (Result<QRAuthModel?, APIError>) -> Void) {
        let endPoint: Endpoint = QRAuthEndPoint().endpoint(code: qrCode, access_token: access_token)
        let request = endPoint.request
        fetch(with: request, decode: { json -> QRAuthModel? in
            guard let acccessToken = json as? QRAuthModel else { return  nil }
            return acccessToken
        }, completion: completion)
    }
}
