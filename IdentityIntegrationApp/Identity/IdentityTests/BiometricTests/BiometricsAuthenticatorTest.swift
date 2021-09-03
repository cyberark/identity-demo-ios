
import XCTest
import LocalAuthentication
@testable import Identity

class BiometricsAuthenticatorTest: XCTestCase  {
    
    /// This doesn't really test anything, as the mock always returns true
    func testBiometric_canEvaluate_Policy() {
        let bm = BiometricsAuthenticator(context: LAContextMock())
        XCTAssertEqual(bm.canEvaluatePolicy(), true)
    }
    
    func testUser_CanAuthenticate_WithBiometric() {
        let bm = BiometricsAuthenticator(context: LAContextMock())
        let exp = expectation(description: "Auth User Exp")
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure: XCTFail()
            case .success(let success): XCTAssertTrue(success)
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_CanNot_Evaluate_Biometric() {
        let laMock = LAContextMock()
        laMock.canEval = false
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.biometryNotEnrolled
                XCTAssertEqual(err.hashValue, fail.hashValue)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)

    }
    
    func testUser_Biometric_AuthFailed_WithFallbackError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.userFallback)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.userFallback
                XCTAssertEqual(err.errorDescription, fail.errorDescription?.debugDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricEvaluate_Failed_AuthUnknon() {
        let laMock = LAContextMock()
        laMock.canEvaluatePolicy = false
        laMock.error = nil
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.unknown
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithAuthenticationFailedError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.authenticationFailed)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.authenticationFailed
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithUserCancelError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.userCancel)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.userCancel
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithBiometryNotAvailableError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.biometryNotAvailable)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.biometryNotAvailable
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithBiometryNotEnrolledError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.biometryNotEnrolled)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.biometryNotEnrolled
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithBiometryLockoutError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.biometryLockout)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.biometryLockout
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
    
    func testUser_BiometricAuthFailed_WithBiometryUnknownError() {
        let laMock = LAContextMock()
        laMock.canEval = true
        laMock.canEvaluatePolicy = false
        laMock.error = LAError(LAError.notInteractive)
        let exp = expectation(description: "Auth User Exp")
        let bm = BiometricsAuthenticator(context: laMock)
        bm.authenticateUser(completion: {ret in
            print (ret)
            switch ret {
            case .failure(let fail):
                let err = BiometricError.unknown
                XCTAssertEqual(err.errorDescription, fail.errorDescription)
            case .success: XCTFail()
            }
            exp.fulfill()
        })
        waitForExpectations(timeout: 2.0)
    }
}

class LAContextMock: LAContextProtocol {
    var canEval = true
    var canEvaluatePolicy = true
    var error: Error? = nil
    func canEvaluatePolicy(_: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEval
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        // returning nil implies that there are no errors, therefore we are authenticated
        reply(canEvaluatePolicy, error)
    }
}
