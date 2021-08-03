//
//  QRCodeReaderViewController.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 30/07/21.
//

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
