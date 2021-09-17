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
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        XCTAssertNotNil(CyberArkAuthProvider.viewmodel())
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
}

