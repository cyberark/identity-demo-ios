
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

import AVFoundation

/*
/// AVCodeReader
/// Responsible for the Qr scanner related operations
///
 */
class AVCodeReader: NSObject {
    fileprivate(set) var videoPreview = CALayer()

    fileprivate var captureSession: AVCaptureSession?
    fileprivate var didRead: ((String?) -> Void)?

    override init() {
        super.init()

        //Make sure the device can handle video
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }

        //session
        captureSession = AVCaptureSession()

        //input
        captureSession?.addInput(deviceInput)

        //output
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //interprets qr codes only
        captureMetadataOutput.metadataObjectTypes = [.qr]

        //preview
        guard let captureSession = captureSession else { return }
        let captureVideoPreview = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreview.videoGravity = .resizeAspectFill
        self.videoPreview = captureVideoPreview
    }
}

extension AVCodeReader: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = readableCode.stringValue else {
             return
        }

        //Vibrate the phone
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        stopReading()
        didRead?(code)
    }
}

extension AVCodeReader: QRCodeReaderProtocol {
    func startReading(completion: @escaping (String?) -> Void) {
        self.didRead = completion
        captureSession?.startRunning()
    }
    func stopReading() {
        captureSession?.stopRunning()
    }
}
