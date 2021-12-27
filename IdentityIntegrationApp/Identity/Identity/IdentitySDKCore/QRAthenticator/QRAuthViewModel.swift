
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
/// QRAuthViewModelProtocol
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
protocol QRAuthViewModelProtocol {
    func performQRAuthentication(qrCode: String)
    var didReceiveAuth: ((Error?, String?) -> Void)? { get set }
}
/*
/// QRAuthViewModel
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
public class QRAuthViewModel {
    private let apiServiceClient : QRCodeAuthClientProtocol
    public var didReceiveAuth: ((Error?, String?) -> Void)?
    
    init( apiService: QRCodeAuthClientProtocol = QRCodeAuthClient()) {
        self.apiServiceClient = apiService
    }
    var authResponse: QRAuthModel? {
        didSet {
            if let didReceive = self.didReceiveAuth {
                didReceive(nil, authResponse?.result?.auth)
            }
            
        }
    }
}
/*
/// QRAuthViewModel
/// Responsible for the api client and all the data related operations
/// Viewmodel protocol
 */
extension QRAuthViewModel: QRAuthViewModelProtocol {

    func performQRAuthentication(qrCode: String) {
        do {
            guard let access_token = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue)?.toString() else {
                print("Not available accesstoken")
                return
            }
            apiServiceClient.performQRAuthentication(from: qrCode, access_token: access_token) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data else {
                        print("Response Data not valid")
                        if let receivedAuth = self?.didReceiveAuth {
                            receivedAuth(APIError.invalidData, nil)
                        }
                        
                        return
                    }
                    self?.authResponse = response
                case .failure(let error):
                    print(false, error.localizedDescription)
                    if let didReceive = self?.didReceiveAuth {
                        didReceive(error, nil)
                    }
                }
            }
            
        } catch  {
            debugPrint("error: \(error)")
        }
    }
}
