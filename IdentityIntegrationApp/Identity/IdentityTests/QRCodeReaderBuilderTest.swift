//
//  QRCodeReaderBuilderTest.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 30/07/21.
//

import XCTest
import AVFoundation
@testable import Identity

class QRCodeReaderBuilderTest: XCTestCase {

    override func setUp() {
        
    }
    override func tearDown() {
        
    }
    
    func test_authenticateQrCode_Restricted_CannotNavigateSettings() {
        let mockAVdevice = MockAVCaptureDevice()
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc)
        XCTAssertFalse(mockSut.navigateSetting)
    }
    
    func test_authenticateQrCode_Authorized_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .authorized
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc)
        XCTAssertFalse(mockSut.navigateSetting)
        XCTAssertNil(vc.presentedViewController)
    }
    
    func test_authenticateQrCode_AuthorizGranted_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .notDetermined
        mockAVdevice.access = true
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc)
        XCTAssertFalse(mockSut.navigateSetting)
        XCTAssertNil(vc.presentedViewController)
    }
    
    func test_authenticateQrCode_AuthorizNotGranted_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .notDetermined
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc)
        XCTAssertTrue(mockSut.navigateSetting)
        XCTAssertNil(vc.presentedViewController)
    }
    
    func test_authenticateQrCode_Authorizdenied_CanNavigateSettings() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .denied
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc)
        XCTAssertTrue(mockSut.navigateSetting)
        XCTAssertNil(vc.presentedViewController)
    }

}
class MockQRCodeReaderBuilder: QRCodeReaderBuilder {
    var navigateSetting = false
    var qrAuthToken: String? = nil
    override func navigateSettings() {
        navigateSetting = true
    }
}

class MockAVCaptureDevice: AVCaptureDeviceProtocl {
    var access: Bool = false
    var authorizeStatus: AVAuthorizationStatus  = .restricted
    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        return authorizeStatus
    }
    
    func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void) {
        handler(access)
    }
}
