
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

import UIKit


class QRCodeReaderViewController: UIViewController {

    @IBOutlet weak var videoPreview: UIView!
    private var videoLayer: CALayer!

    var codeReader: QRCodeReaderProtocol!

    var didFindQRCode: ((String?) -> Void)?

    override func viewDidLoad() {
        videoLayer = codeReader.videoPreview
        videoPreview.layer.addSublayer(videoLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer.frame = videoPreview.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeReader.startReading { [weak self] (code) in
            self?.fetchQRCode(for: code)
        }
    }
    
    class func qrCodeReaderView() -> QRCodeReaderViewController {
        let vc = QRCodeReaderViewController.loadFromNib()
        return vc
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        codeReader.stopReading()
    }
    
    @IBAction func closeScannerView(_ sender: Any) {
        self.dismiss(animated: true, completion:  nil)
    }
}

//MARK: Data Source
extension QRCodeReaderViewController {
    func fetchQRCode(for code: String?) {
        self.dismiss(animated: true) {
            self.didFindQRCode?(code)
        }
    }
}
