//
//  QRCodeReaderBuilder.swift
//  QRCodeScanner
//
//  Created by Raviraju Vysyaraju on 09/07/21.
//

import Foundation
import AVFoundation
import UIKit

public protocol AVCaptureDeviceProtocl {
    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
    func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void)
}

public protocol QRCodeReaderBuilderProtocol {
    func authenticateQrCode(presenter: UIViewController)
    func fetchQrCodeAccessToken(qrCode: String)
}

public class QRCodeReaderBuilder {
    private var presenter: UIViewController?
    private var avCaptureDevice: AVCaptureDeviceProtocl!
    private var sharedApplication: UIApplicationProtocol?

    public init() {
        self.avCaptureDevice = QRAVCaptureDevice()
        self.sharedApplication = QRUIApplication()
    }
    public var viewModel : QRAuthViewModel = {
        let viewModel = QRAuthViewModel()
        return viewModel
    }()
    
    
    func navigateSettings() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                self.sharedApplication?.open(settingsURL)
            }
        }
    }
    
   
    private func showFailedAlert(message: String) {
        UIViewController.showAlertOnRootView(with: self.presenter, title: "QR Code", message: message)
    }
    private func addObserver() {
        viewModel.didReceiveAuth = { [weak self] error, authValue in
            guard error == nil, let value = authValue else {
                if let erroString = (error as? APIError)?.localizedDescription {
                    self?.showFailedAlert(message: erroString)
                }
                return
            }
            print("Final QRAuthCode \(value)")
            UIViewController.showAlertOnRootView(with: self?.presenter, title: "QR Code", message: value)
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
                self?.fetchQrCodeAccessToken(qrCode: code)
            }
            let presenterVC = self.presenter ?? UIApplication.shared.windows.last?.rootViewController
            presenterVC?.present(readerViewController, animated: true, completion: nil)
        }
    }
}

extension QRCodeReaderBuilder {

    convenience init (captureDevice: AVCaptureDeviceProtocl = QRAVCaptureDevice(), application: UIApplicationProtocol = QRUIApplication()) {
        self.init()
        self.sharedApplication = application
        self.avCaptureDevice = captureDevice
    }

    convenience init(captureDevice: AVCaptureDeviceProtocl = QRAVCaptureDevice()){
        self.init()
        self.avCaptureDevice = captureDevice
    }

}

extension QRCodeReaderBuilder: QRCodeReaderBuilderProtocol {
    
    public func authenticateQrCode(presenter: UIViewController) {
        self.presenter = presenter
        switch avCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.launchQrCodeReader()
        // The user has previously granted access to the camera.
        case .notDetermined: // The user has not yet been asked for camera access.
            avCaptureDevice.requestAccess(for: .video) { [weak self] granted in
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
    
    public func fetchQrCodeAccessToken(qrCode: String) {
        viewModel.fetchQRAuthToken(qrCode: qrCode)
        addObserver()
    }
    
}

public protocol UIApplicationProtocol {
    func open(_ url: URL)
}

struct QRUIApplication: UIApplicationProtocol {
    func open(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct QRAVCaptureDevice: AVCaptureDeviceProtocl {
    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: mediaType, completionHandler: handler)
    }
}
