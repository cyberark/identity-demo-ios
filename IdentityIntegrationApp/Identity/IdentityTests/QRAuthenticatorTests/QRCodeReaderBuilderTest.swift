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
        let mockApplication = MockUIApplication()
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice, application: mockApplication)
        let vc = MockPresentingViewController()
        mockSut.authenticateQrCode(presenter: vc) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
        XCTAssertFalse(mockApplication.canopenUrl)
    }
    
    func test_authenticateQrCode_Authorized_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .authorized
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = MockPresentingViewController()
        mockSut.authenticateQrCode(presenter: vc) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
        
        let delayExpectation = expectation(description: "Waiting for QRVC is open")

        // Fulfill the expectation after 2 seconds
        DispatchQueue.main.async {
            delayExpectation.fulfill()
        }

        // Wait for the expectation to be fulfilled, if it takes more than
        waitForExpectations(timeout: 2)
        XCTAssertNotNil(vc.presentViewControllerTarget)
    }
    
    func test_authenticateQrCode_AuthorizGranted_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .notDetermined
        mockAVdevice.access = true
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = MockPresentingViewController()
        mockSut.authenticateQrCode(presenter: vc) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
        let delayExpectation = expectation(description: "Waiting for QRVC is open")

        // Fulfill the expectation after 2 seconds
        DispatchQueue.main.async {
            delayExpectation.fulfill()
        }

        // Wait for the expectation to be fulfilled, if it takes more than
        waitForExpectations(timeout: 2)
        XCTAssertNotNil(vc.presentViewControllerTarget)
    }
    
    func test_authenticateQrCode_AuthorizNotGranted_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .notDetermined
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateQrCode(presenter: vc) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
        XCTAssertNil(vc.presentedViewController)
    }
    
    func test_authenticateQrCode_Authorizdenied_CanNavigateSettings() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .denied
        let mockApplication = MockUIApplication()
        let mockSut = MockQRCodeReaderBuilder(captureDevice: mockAVdevice, application: mockApplication)
        let vc = MockPresentingViewController()
        mockSut.authenticateQrCode(presenter: vc) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
        let delayExpectation = expectation(description: "Waiting for QRVC is open")

        // Fulfill the expectation after 2 seconds
        DispatchQueue.main.async {
            delayExpectation.fulfill()
        }

        // Wait for the expectation to be fulfilled, if it takes more than
        // 5 seconds, throw an error
        waitForExpectations(timeout: 2)
        XCTAssertTrue(mockApplication.canopenUrl)
    }
    
    func test_fetchQrCodeAccess_WithToken() {
        do {
            try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.grantCode.rawValue, data: "access_cde".toData() ?? Data())
        } catch {
            print("Unexpected error: \(error)")
        }
        let mockSut = MockQRCodeReaderBuilder()
        mockSut.viewModel = QRAuthViewModel()
        
        let delayExpectation = expectation(description: "Waiting for QR Auth request failed")
        // Fulfill the expectation after 2 seconds
        DispatchQueue.main.async {
            delayExpectation.fulfill()
        }
        // Wait for the expectation to be fulfilled, if it takes more than        
        mockSut.viewModel.didReceiveAuth = { error, authValue in
            XCTAssertNotNil(error)
            XCTAssertNil(authValue)
        }
        mockSut.fetchQrCodeAccessToken(qrCode: "code")
        waitForExpectations(timeout: 2)
        do {
            try KeyChainWrapper.standard.delete(account: KeyChainStorageKeys.grantCode.rawValue)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
class MockQRCodeReaderBuilder: QRCodeReaderBuilder {
    override init() { }
    var videoPreview: CALayer!
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

class MockPresentingViewController: UIViewController {
  var presentViewControllerTarget: UIViewController?

  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    presentViewControllerTarget = viewControllerToPresent
  }
}

class MockUIApplication: UIApplicationProtocol {
    var settingUrl: String = UIApplication.openSettingsURLString
    
    var canopenUrl: Bool = false
    func open(_ url: URL) {
        canopenUrl = true
    }
}
