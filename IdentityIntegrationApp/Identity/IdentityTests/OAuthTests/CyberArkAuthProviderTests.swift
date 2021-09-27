//
//  CyberArkAuthProviderTests.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 16/09/21.
//

import XCTest
@testable import Identity

class CyberArkAuthProviderTests: XCTestCase {

    override func setUp() {
    }
    override func tearDown() {
    }

    func testWeblogin_Validate() {
        let config = dummyPlistValues()
        let vc = UIViewController()
        guard let account =  CyberArkAuthProvider.webAuth()?
                .set(clientId: config.clientId)
                .set(domain: config.domain)
                .set(redirectUri: config.redirectUri)
                .set(applicationID: config.applicationID)
                .set(presentingViewController: vc)
                .setCustomParam(key: "", value: "")
                .set(scope: config.scope)
                .set(webType: .sfsafari)
                .set(systemURL: config.systemurl)
                .build() else { return }

        CyberArkAuthProvider.login(account: account)
        
        XCTAssertNotNil(account)
        XCTAssertNotNil(CyberArkAuthProvider.webAuth)
        XCTAssertNotNil(CyberArkAuthProvider.webAuth())
    }
    
    func test_resume_accesstoken() {
        guard let url = URL(string: "https://acme2.my.dev.idaptive.app") else { return  }
        
        CyberArkAuthProvider.resume(url: url)
    }

    func dummyPlistValues() -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String,systemurl: String) {
        return (clientId: "Axis",
                domain: "https://acme2.my.dev.idaptive.app",
                domain_auth0: "https://acme2.my.dev.idaptive.app",
                scope: "All",
                redirectUri: "ciamsdkdemo://com.cyberark.ciamsdk",
                threshold: 60,
                applicationID: "OAuthTest",
                logouturi: "identitysdklogout://com.cyberark.identity",
                systemurl: "https://aaj7617.my.dev.idaptive.app")
    }
    
    func testRetriveParameter_FromValidUrl() {
        let url = URL(string: "ciamsdkdemo://com.cyberark.ciamsdk/?responseType=code&code=BirRoZjwr336qrg2nTjfb0_iICxr8mRHuHZaUtv6Jts1")
        let code = url?.queryParameter(with:"code")
        XCTAssertNotNil(code)
        XCTAssertEqual(code, "BirRoZjwr336qrg2nTjfb0_iICxr8mRHuHZaUtv6Jts1")
    }
    
    func testRetriveParameter_FromNotValidUrl() {
        let url = URL(string: "ciamsdkdemo://com.cyberark.ciamsdk")
        let code = url?.queryParameter(with:"code")
        XCTAssertNil(code)
    }

    func testIdentityOAuth_oAuth_accessDeniedError() {
        let uri = URL(string: "www.google.com")?.absoluteString
        let error = IdentityOAuthError.oAuth_accessDenied(uri)
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_invalidRequestError() {
        let uri = URL(string: "www.google.com")?.absoluteString
        let error = IdentityOAuthError.oAuth_invalidRequest(uri)
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_invalidError() {
        let error = IdentityOAuthError.oAuth_invalid("test")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_invalidGrantError() {
        let error = IdentityOAuthError.oAuth_invalidGrant("grant")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_unauthorizedError() {
        let error = IdentityOAuthError.oAuth_unauthorized("oAuth_unauthorized")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_unsupportedGrantTypeError() {
        let error = IdentityOAuthError.oAuth_unsupportedGrantType("unsupportedGrantType")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_unsupportedResponseTypeError() {
        let error = IdentityOAuthError.oAuth_unsupportedResponseType("unsupportedResponseType")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_invalidScopeError() {
        let error = IdentityOAuthError.oAuth_invalidScope("oAuth_invalidScope")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_missingOrInvalidRedirectURIError() {
        let error = IdentityOAuthError.oAuth_missingOrInvalidRedirectURI("InvalidRedirectURI")
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_oAuth_invalidPKCEStateError() {
        let error = IdentityOAuthError.oAuth_invalidPKCEState
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIdentityOAuth_unknownError() {
        let error = IdentityOAuthError.unknown
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }
    
    func testIIdentitySDKError_unknownError() {
        let error = IdentitySDKError.unknownError
        XCTAssertNotNil(error)
        XCTAssertNotNil(error.localizedDescription)
    }

    func testIIdentitySDKError_emptyConfigurationError() {
        let error = IdentitySDKError.emptyConfiguration
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Invalid configuration: configuration Dictionary is missing")
    }
    
    func testIIdentitySDKError_invalidConfigurationError() {
        let error = IdentitySDKError.invalidConfiguration
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Invalid Configuration")
    }
    
    func testIIdentitySDKError_requestFailedError() {
        let error = IdentitySDKError.requestFailed
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Request Failed")
    }
    
    func testIIdentitySDKError_invalidDataError() {
        let error = IdentitySDKError.invalidData
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Invalid Data")
    }
    
    func testIIdentitySDKError_invalidurlError() {
        let error = IdentitySDKError.invalidurl
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "Invalid URL")
    }
    //CyberArkBrowserError
    func testCyberArkBrowserError_failureError() {
        let error = CyberArkBrowserError.failure
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "External failure")
    }
    
    func testCyberArkBrowserError_inprogressError() {
        let error = CyberArkBrowserError.inprogress
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "The operation is progress")
    }
    
    func testCyberArkBrowserError_cancelledError() {
        let error = CyberArkBrowserError.cancelled
        XCTAssertNotNil(error)
        XCTAssertEqual(error.localizedDescription, "User Cancelled the operation")
    }
    
    //URLRequest
    
    func testURLRequest_ValidUrl() {
        let request = URLRequest(urlString: "www.google.com")
        XCTAssertNotNil(request)
    }
    
    func testURLRequest_NotValidUrl() {
        let request = URLRequest(urlString: "")
        XCTAssertNil(request)
    }
    
    //UIColor
    
    func testColor_WithValues() {
        let color = UIColor(red: 255, green: 255, blue: 255)
        XCTAssertNotNil(color)
    }
    
    func testColor_rgbNumber() {
        let color = UIColor(rgb: 10)
        XCTAssertNotNil(color)
    }
    //APIError
    func testAPIError_requestFailed() {
        let error = APIError.requestFailed
        XCTAssertEqual(error.localizedDescription, "Request Failed")
    }
    
    func testAPIError_jsonConversionFailure() {
        let error = APIError.jsonConversionFailure
        XCTAssertEqual(error.localizedDescription, "JSON Conversion Failure")
    }
    
    func testAPIError_invalidData() {
        let error = APIError.invalidData
        XCTAssertEqual(error.localizedDescription, "Invalid Data")
    }
    
    func testAPIError_responseUnsuccessful() {
        let error = APIError.responseUnsuccessful
        XCTAssertEqual(error.localizedDescription, "Response Unsuccessful")
    }
    
    func testAPIError_jsonParsingFailure() {
        let error = APIError.jsonParsingFailure
        XCTAssertEqual(error.localizedDescription, "JSON Parsing Failure")
    }
    
    func testAPIError_unauthorized() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.localizedDescription, "unauthorized")
    }
    
    func testIsConnectedToNetwork() {
        let result = Reachability.isConnectedToNetwork()
        XCTAssertTrue(result)
    }
}
