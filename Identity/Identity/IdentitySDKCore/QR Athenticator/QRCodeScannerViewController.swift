//
//  QRCodeScannerViewController.swift
//  QRCodeScanner
//
//  Created by Raviraju Vysyaraju on 08/07/21.
//

import Foundation
import UIKit
import AVFoundation

enum ScannerError: Error {
    case inValidQrCode
    case cameraAccessfailed
    case accessTokenFailed
}

//protocol QRCodeScannerDelegate {
//    func onSuccess(qrCode: String)
//    func onFailure(error: Error)
//}
typealias ResultHandler = ( Result <String ,ScannerError > ) -> Void
class QRCodeScannerViewController: UIViewController {
    
    @IBOutlet weak var qrCodePreview: UIView!
//    var delegate: QRCodeScannerDelegate?
    var handler: ResultHandler?
    //    @IBOutlet var topbar: UIView!
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private let supportedCodeTypes: [AVMetadataObject.ObjectType] = [.upce,
                                                                     .code39,
                                                                     .code39Mod43,
                                                                     .code93,
                                                                     .code128,
                                                                     .ean8,
                                                                     .ean13,
                                                                     .aztec,
                                                                     .pdf417,
                                                                     .itf14,
                                                                     .dataMatrix,
                                                                     .interleaved2of5,
                                                                     .qr]
    
    @IBAction func closeScannerView(_ sender: Any) {
        self.dismiss(animated: true, completion:  nil)
    }
    class func showScannerView(with presenter: UIViewController? = nil, completionHandler: @escaping ResultHandler) {
        let presenterVC = presenter ?? UIApplication.shared.windows.last?.rootViewController
        let vc = QRCodeScannerViewController.loadFromNib()
        vc.handler = completionHandler
        presenterVC?.present(vc, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScanner()
    }
    private func setupScanner() {
        //        let failureError = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to initiate Scanner view."])
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            
            self.dismiss(animated: true) {
                print("Failed to get the camera device")
                self.cameraAccessFailed()
                
            }
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ {
            self.cameraAccessFailed()
            return
        }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            self.cameraAccessFailed()
            return
        }
        
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        else {
            self.cameraAccessFailed()
            return
        }
        
        guard qrCodePreview != nil else {
            self.cameraAccessFailed()
            return
        }
        
        self.captureVideoLayer()
        
        self.startScan()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    private func captureVideoLayer() {
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = qrCodePreview.bounds
    }
    private func cameraAccessFailed() {
        self.dismiss(animated: true) {
            if let handler = self.handler {
                handler(.failure(.cameraAccessfailed))
            }
        }
        return
    }
    
    func startScan() {
        // Start video capture.
        captureSession.startRunning()
    }
    func stopScan() {
        // stop video capture.
        captureSession.stopRunning()
    }
    private func handleOrientation() {
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.handleOrientation()
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let qrCode = readableObject.stringValue else {
                return
            }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.dismiss(animated: true) {
                if let handler = self.handler {
                    handler(.success(qrCode))
                }
            }
        }
    }
}
