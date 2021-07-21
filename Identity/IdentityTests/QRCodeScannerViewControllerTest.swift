//
//  QRCodeScannerViewControllerTest.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 21/07/21.
//

import XCTest
@testable import Identity

class QRCodeScannerViewControllerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    func test_toshow_viewcontroller() {
        let vc = QRCodeScannerViewController.showScannerView() { _ in }
        XCTAssertNotNil(vc)
    }
    
    func test_toshow_rootviewcontroller() {
        let vc = QRCodeScannerViewController.showScannerView() { _ in }
        UIApplication.shared.windows.last?.rootViewController?.present(vc, animated: true, completion: nil)
        XCTAssertTrue(((UIApplication.shared.windows.last?.rootViewController?.presentationController) == nil))
    }
    
    func test_capturedevice_notavailable() {
        let vc = QRCodeScannerViewController.showScannerView() { _ in }
        vc.viewDidLoad()
        XCTAssertNil(vc.qrCodePreview)
    }
}
