//
//  OAuthEndPointTests.swift
//  IdentityTests
//
//  Created by Mallikarjuna Punuru on 10/08/21.
//

import XCTest
@testable import Identity

class OAuthEndPointTests: XCTestCase {

    var mockEndPoint: OAuthEndPoint?
    var pkce: AuthOPKCE?

    override func setUp() {
        super.setUp()
        configValues()
    }
    override func tearDown() {
        super.tearDown()
        mockEndPoint = nil
    }
    func configValues(){
        pkce = AuthOPKCE()
        mockEndPoint = OAuthEndPoint(pkce: pkce)
        mockEndPoint?.clientId = "clientId"
        mockEndPoint?.domain = "domain"
        mockEndPoint?.scope = "scope"
        mockEndPoint?.redirectUri = "redirectUri"
        mockEndPoint?.threshold = 60
        mockEndPoint?.pkce = pkce
        mockEndPoint?.applicationID = "applicationID"
        mockEndPoint?.logoutUri = "/logoutUri"
    }
    /// To get the autherization endpoint
    /// - Returns: Endpoint
    func test_Authorization_Endpoint() {
        let endpoint = mockEndPoint?.getAuthorizationEndpoint()
        XCTAssertNotNil(endpoint?.queryItems)
        XCTAssertEqual(endpoint?.queryItems!.count, 6)
        XCTAssertEqual(endpoint?.queryItems?[0].value, OAuth2Header.code.rawValue)
        XCTAssertEqual(endpoint?.queryItems?[1].value, "clientId")
        XCTAssertEqual(endpoint?.queryItems?[2].value, "scope")
        XCTAssertEqual(endpoint?.queryItems?[3].value, "redirectUri")
        XCTAssertEqual(endpoint?.queryItems?[4].value, self.pkce?.challenge)
        XCTAssertEqual(endpoint?.queryItems?[5].value, self.pkce?.method)
    }
    /// To get the access token from the auth code
    /// - Parameter code: code
    /// - Returns: Endpoint
    func test_Authentication_Endpoint() {
        let endpoint = mockEndPoint?.getAuthenticationEndpoint(code: "code")
        XCTAssertNotNil(endpoint?.body)
    }
    
    /// To Close the session
    /// - Returns: Endpoint
    func test_Close_Session_Endpoint() {
        let endpoint = mockEndPoint?.getCloseSessionEndpoint()
        XCTAssertNotNil(endpoint?.queryItems)
        XCTAssertEqual(endpoint?.queryItems!.count, 1)
        XCTAssertEqual(endpoint?.queryItems?[0].value, mockEndPoint?.redirectUri)

    }
    
    /// To get the Refresh token
    /// - Parameters:
    ///   - code: code
    ///   - refreshToken: Refresh token
    /// - Returns: Endpoint
    func test_Refresh_Token_Endpoint() {
        let endpoint = mockEndPoint?.getRefreshTokenEndpoint(code: "code", refreshToken: "refreshtoken")
        XCTAssertNotNil(endpoint?.body)
    }
}
