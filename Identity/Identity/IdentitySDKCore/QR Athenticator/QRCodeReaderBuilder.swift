//
//  QRCodeReaderBuilder.swift
//  QRCodeScanner
//
//  Created by Raviraju Vysyaraju on 09/07/21.
//

import Foundation
import AVFoundation
import UIKit

public protocol QRCodeReaderBuilderProtocol {
    func authenticateQrCode(presenter: UIViewController)
    func fetchQrCodeAccessToken(code: String)
}

public class QRCodeReaderBuilder {
    private var presenter: UIViewController?
    
    public init(){
    }
    
    public var viewModel : QRAuthViewModel = {
        let viewModel = QRAuthViewModel()
        return viewModel
    }()
    
    
    private func navigateSettings() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
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
    
    private func launchQrCodeReader() {
        setupQrCodeReaderView()
    }
    private func setupQrCodeReaderView() {
        DispatchQueue.main.async {
            let readerViewController = QRCodeReaderViewController.qrCodeReaderView()
            readerViewController.codeReader = AVCodeReader()
            readerViewController.didFindQRCode = { [weak self] code in
                guard let code = code else {
                    self?.showFailedAlert(message: "QR code not found")
                    return
                }
                print("Raviraju QRCode \(code)")
                self?.fetchQrCodeAccessToken(code: code)
            }
            let presenterVC = self.presenter ?? UIApplication.shared.windows.last?.rootViewController
            presenterVC?.present(readerViewController, animated: true, completion: nil)
        }
    }
}

extension QRCodeReaderBuilder: QRCodeReaderBuilderProtocol {
    
    public func authenticateQrCode(presenter: UIViewController) {
        self.presenter = presenter
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.launchQrCodeReader()
        // The user has previously granted access to the camera.
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.launchQrCodeReader()
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
    
    public func fetchQrCodeAccessToken(code: String) {
        viewModel.fetchAuthToken(code: code)
        addObserver()
    }
    
}
