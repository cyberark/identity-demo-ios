//
//  QRCodeReaderBuilder.swift
//  QRCodeScanner
//
//  Created by Raviraju Vysyaraju on 09/07/21.
//
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
import AVFoundation
import UIKit

public typealias ResultHandler = (Result<Bool, APIError>) -> Void
public protocol AVCaptureDeviceProtocl {
    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
    func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void)
}

protocol QRCodeReaderAPIProtocol {
    func fetchQrCodeAccessToken(qrCode: String)
}
public protocol QRCodeReaderBuilderProtocol {
    func authenticateQrCode(presenter: UIViewController, completion: @escaping ResultHandler)
}

public class QRAuthenticationProvider {
    private var presenter: UIViewController?
    private var avCaptureDevice: AVCaptureDeviceProtocl!
    private var sharedApplication: UIApplicationProtocol?
    private var handler: ResultHandler!
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
            if error == nil, let value = authValue {
                print("Final QRAuthCode \(value)")
                UIViewController.showAlertOnRootView(with: self?.presenter, title: "QR Code", message: value)
                self?.handler(.success(true))
            } else {
                if let erroString = (error as? APIError)?.localizedDescription {
                    self?.showFailedAlert(message: erroString)
                }
                self?.handler(.failure((error as? APIError) ?? APIError.invalidData))
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
                self?.fetchQrCodeAccessToken(qrCode: code)
            }
            let presenterVC = self.presenter ?? UIApplication.shared.windows.last?.rootViewController
            presenterVC?.present(readerViewController, animated: true, completion: nil)
        }
    }
}

extension QRAuthenticationProvider {

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

extension QRAuthenticationProvider: QRCodeReaderBuilderProtocol, QRCodeReaderAPIProtocol {
    //compltion  error code , error message and success
    public func authenticateQrCode(presenter: UIViewController, completion: @escaping ResultHandler) {
        self.handler = completion
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
