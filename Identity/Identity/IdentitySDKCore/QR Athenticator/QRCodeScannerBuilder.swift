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
    
    public init(){
        
    }
    
    var viewModel : QRScannerViewModel = {
        let viewModel = QRScannerViewModel()
        return viewModel
    }()
    
    public func authenticate(with qrCoder: String? = nil, presenter: UIViewController? = nil) {
//        guard checkScanPermission() else {
//            print("user doen't have camera permission")
//            return
//        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            launchScanner(with: qrCoder, presenter: presenter)
        // The user has previously granted access to the camera.
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
                if granted {
                    launchScanner(with: qrCoder, presenter: presenter)
                }
            }
        case .denied:
            print("denied")

        case .restricted:
        print("denied")

        @unknown default:
            print("unknown")
        }
    }
        
   public func launchScanner(with qrCoder: String? = nil, presenter: UIViewController? = nil) {
        guard let uri = qrCoder else {
            QRCodeScannerBuilder.showScannerView(with: presenter) { [weak self] result in
                switch result {
                case .success (let value):
                    print(value)
                    UIViewController.showAlertOnRootView(with: "Qrcode: ", message: value)
                    self?.fetchAccessToken(uri: value)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            return
        }
        self.fetchAccessToken(uri: uri)
    }
    class func showScannerView(with presenter: UIViewController? = nil, completionHandler: @escaping ResultHandler) {
        let presenterVC = presenter ?? UIApplication.shared.windows.last?.rootViewController
        let vc = QRCodeScannerViewController.loadFromNib()
        vc.handler = completionHandler
        presenterVC?.present(vc, animated: true, completion: nil)
    }
    public func checkScanPermission() -> Bool{
        do {
            return try self.supportsMetadataObjectTypes()
        } catch let error as NSError {
            print(error.description)
            return false
        }
    }
    
    public func fetchAccessToken(uri: String) {
        viewModel.fetchAccessToken(uri: uri)
    }
}

extension QRCodeScannerBuilder {
    public func supportsMetadataObjectTypes(_ metadataTypes: [AVMetadataObject.ObjectType]? = nil) throws -> Bool {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            throw NSError(domain: "com.yannickloriot.error", code: -1001, userInfo: nil)
        }
        
        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        let output      = AVCaptureMetadataOutput()
        let session     = AVCaptureSession()
        
        session.addInput(deviceInput)
        session.addOutput(output)
        
        var metadataObjectTypes = metadataTypes
        
        if metadataObjectTypes == nil || metadataObjectTypes?.count == 0 {
            // Check the QRCode metadata object type by default
            metadataObjectTypes = [.qr]
        }
        
        let availableMetadataObjectTypes = output.availableMetadataObjectTypes
        for metadataObjectType in metadataObjectTypes! {
            if !(availableMetadataObjectTypes.contains(where: { $0 == metadataObjectType })) {
                return false
            }
        }
        
        return true
    }
    func accessCamera() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return true
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                }
            }
            return true
        case .denied: // The user has previously denied access.
            print("denied")
            return false

        case .restricted: // The user can't grant access due to restrictions.
            print("restricted")
            return false

        @unknown default:

            return false
        }
    }
}
