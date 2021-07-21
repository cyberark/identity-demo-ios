//
//  QRAuthEndPointTest.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 21/07/21.
//

import XCTest
@testable import Identity

class QRAuthEndPointTest: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    func test_validate_endpoint() {
        let endpoint = QRAuthEndPoint().endpoint(code: "qr_token", access_token: "access_token")
        XCTAssertEqual(endpoint.headers?["X-IDAP-NATIVE-CLIENT"], "true")
        XCTAssertEqual(endpoint.headers?["Authorization"], "Bearer access_token")
    }
}
