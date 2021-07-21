//
//  QRCodeScannerBuilder.swift
//  QRCodeScanner
//
//  Created by Raviraju Vysyaraju on 09/07/21.
//

import Foundation
import AVFoundation
import UIKit

public class QRCodeScannerBuilder {
    private var presenter: UIViewController?
    public init(){
    }
    
    var viewModel : QRAuthViewModel = {
        let viewModel = QRAuthViewModel()
        return viewModel
    }()
    
    public func authenticate(qrCode: String? = nil, presenter: UIViewController) {
        self.presenter = presenter
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            launchScanner(with: qrCode)
        // The user has previously granted access to the camera.
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.launchScanner(with: qrCode)
                } else {
                    print("not granted")
                    self?.navigateSettings()
                }
            }
        case .denied:
            print("denied")
            navigateSettings()
        case .restricted:
            print("restricted")
        @unknown default:
            print("unknown")
        }
    }
    
    private func navigateSettings() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    private func launchScanner(with qrCoder: String? = nil) {
        guard let uri = qrCoder else {
            DispatchQueue.main.async {
                let qrVC = QRCodeScannerViewController.showScannerView() { [weak self] result in
                    switch result {
                    case .success (let value):
                        print(value)
                        self?.fetchAccessToken(uri: value)
                    case .failure(let error):
                        self?.showFailedAlert(message: "Invalid QR Code")
                        print(error.localizedDescription)
                    }
                }
                let presenterVC = self.presenter ?? UIApplication.shared.windows.last?.rootViewController
                presenterVC?.present(qrVC, animated: true, completion: nil)
                
            }
            return
        }
        self.fetchAccessToken(uri: uri)
    }
    
    private func fetchAccessToken(uri: String) {
        debugPrint("Make QR Code auth request \(uri)")
        viewModel.fetchAuthToken(uri: uri)
        addObserver()
    }
    private func showFailedAlert(message: String) {
        UIViewController.showAlertOnRootView(with: self.presenter, title: "QR Code", message: message)
    }
    private func addObserver() {
        viewModel.didReceiveAuth = { [weak self] result, authValue in
            if result {
                print("Final QRAuthCode \(authValue)")
                UIViewController.showAlertOnRootView(with: self?.presenter, title: "QR Code", message: authValue)
            } else {
                self?.showFailedAlert(message: "QR Api failed")
            }
        }
    }
}
