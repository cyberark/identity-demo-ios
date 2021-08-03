import UIKit

protocol QRCodeReaderProtocol {
    func startReading(completion: @escaping (String?) -> Void)
    func stopReading()
    var videoPreview: CALayer {get}
}
