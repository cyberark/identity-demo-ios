//
//  QRAuthViewModel.swift
//  QRScanner
//
//  Created by Raviraju Vysyaraju on 08/07/21.
//

import Foundation


protocol QRAuthViewModelProtocol {
    func fetchAuthToken(uri: String)
    var didReceiveAuth: ((Bool,String) -> Void)? { get set }
}
public class QRAuthViewModel {
    private let client = QRCodeAuthClient()
    public var didReceiveAuth: ((Bool,String) -> Void)?
    var authResponse: QRAuthModel? {
        didSet {
            print("QR Auth response", authResponse?.result?.auth ?? "")
            self.didReceiveAuth!(true, authResponse?.result?.auth ?? "")
        }
    }
}
extension QRAuthViewModel: QRAuthViewModelProtocol {
    func fetchAuthToken(uri: String) {
        do {
            guard let access_token = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue)?.toString() else {
                print("Not available accesstoken")
                return
            }
            let endPoint: Endpoint = QRAuthEndPoint().endpoint(code: uri, access_token: access_token)
            client.featchQRAuth(from: endPoint) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data else {
                        print("Unable to fecth QRAuthToken")
                        self?.didReceiveAuth!(false, "unable to fecth QRAuthToken")
                        return
                    }
                    print("QRAuthToken \(String(describing: response.result?.auth))")
                    self?.authResponse = response
                case .failure(let error):
                    print(false, "unable to fecth accesstoken")
                    self?.didReceiveAuth!(false, "unable to fecth QRAuthToken")
                    print("the error \(error)")
                }
            }
            
        } catch  {
        }
    }
}
