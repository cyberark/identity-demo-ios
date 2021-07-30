//
//  MockCodeReader.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 30/07/21.
//


import UIKit
@testable import Identity

class MockQRCodeReader: QRCodeReaderProtocol {
    var completion: ((String) -> Void)?
    
    func startReading(completion: @escaping (String?) -> Void) {
        self.completion = completion
    }
  
    func stopReading() {}
    private(set) var videoPreview = CALayer()
}
