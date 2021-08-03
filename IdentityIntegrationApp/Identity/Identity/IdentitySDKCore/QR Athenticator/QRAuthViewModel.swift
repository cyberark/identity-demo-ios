//
//  QRAuthViewModel.swift
//  QRScanner
//
//  Created by Raviraju Vysyaraju on 08/07/21.
//

import Foundation


protocol QRAuthViewModelProtocol {
    func fetchQRAuthToken(code: String)
    var didReceiveAuth: ((Error?, String?) -> Void)? { get set }
}
public class QRAuthViewModel {
    private let apiServiceClient : QRCodeAuthClientProtocol
    public var didReceiveAuth: ((Error?, String?) -> Void)?
    
    init( apiService: QRCodeAuthClientProtocol = QRCodeAuthClient()) {
        self.apiServiceClient = apiService
    }
    var authResponse: QRAuthModel? {
        didSet {
            print("QR Auth response", authResponse?.result?.auth ?? "")
            if let didReceive = self.didReceiveAuth {
                didReceive(nil, authResponse?.result?.auth)
            }
            
        }
    }
}
extension QRAuthViewModel: QRAuthViewModelProtocol {

    func fetchQRAuthToken(code: String) {
        do {
            guard let access_token = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue)?.toString() else {
                print("Not available accesstoken")
                return
            }
            let endPoint: Endpoint = QRAuthEndPoint().endpoint(code: code, access_token: access_token)
            apiServiceClient.featchQRAuth(from: endPoint) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data else {
                        print("Response Data not valid")
                        if let receivedAuth = self?.didReceiveAuth {
                            receivedAuth(APIError.invalidData, nil)
                        }
                        
                        return
                    }
                    print("QRAuthToken \(String(describing: response.result?.auth))")
                    self?.authResponse = response
                case .failure(let error):
                    print(false, error.localizedDescription)
                    if let didReceive = self?.didReceiveAuth {
                        didReceive(error, nil)
                    }
                }
            }
            
        } catch  {
        }
    }
}
