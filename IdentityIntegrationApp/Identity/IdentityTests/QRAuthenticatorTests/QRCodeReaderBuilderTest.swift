
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
        let mockSut = QRAuthenticationProvider(captureDevice: mockAVdevice, application: mockApplication)
        let vc = MockPresentingViewController()
        mockSut.authenticateWithQRCode(presenter: vc, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        })
        XCTAssertFalse(mockApplication.canopenUrl)
    }
    
    func test_authenticateQrCode_Authorized_CanNavigateQrReaderVC() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .authorized
        let mockSut = QRAuthenticationProvider(captureDevice: mockAVdevice)
        let vc = MockPresentingViewController()
        mockSut.authenticateWithQRCode(presenter: vc, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        })
        
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
        let mockSut = QRAuthenticationProvider(captureDevice: mockAVdevice)
        let vc = MockPresentingViewController()
        mockSut.authenticateWithQRCode(presenter: vc, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        })
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
        let mockSut = QRAuthenticationProvider(captureDevice: mockAVdevice)
        let vc = UIViewController()
        mockSut.authenticateWithQRCode(presenter: vc, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        })
        XCTAssertNil(vc.presentedViewController)
    }
    
    func test_authenticateQrCode_Authorizdenied_CanNavigateSettings() {
        let mockAVdevice = MockAVCaptureDevice()
        mockAVdevice.authorizeStatus = .denied
        let mockApplication = MockUIApplication()
        let mockSut = QRAuthenticationProvider(captureDevice: mockAVdevice, application: mockApplication)
        let vc = MockPresentingViewController()
        mockSut.authenticateWithQRCode(presenter: vc, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        })
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
        mockSut.fetchAccessTokenWithQRCode(qrCode: "code")
        waitForExpectations(timeout: 2)
        do {
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
        } catch {
            debugPrint("error: \(error)")
        }
    }
}
class MockQRCodeReaderBuilder: QRAuthenticationProvider {
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
