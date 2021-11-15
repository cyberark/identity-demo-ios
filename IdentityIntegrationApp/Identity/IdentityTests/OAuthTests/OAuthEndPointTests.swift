
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
        XCTAssertEqual(endpoint?.queryItems!.count, 7)
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
