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
                QRCodeScannerViewController.showScannerView(with: self.presenter) { [weak self] result in
                    switch result {
                    case .success (let value):
                        print(value)
                        self?.fetchAccessToken(uri: value)
                        UIViewController.showAlertOnRootView(with: "Qrcode: ", message: value)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
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
    private func addObserver() {
        viewModel.didReceiveAuth = { result, authValue in
            if result {
                print("QRAuthCode \(authValue)")
                UIViewController.showAlertOnRootView(with: "Qrcode Auth", message: authValue)
            }
        }
    }
}
