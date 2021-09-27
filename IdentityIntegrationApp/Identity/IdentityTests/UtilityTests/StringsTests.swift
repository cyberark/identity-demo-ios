//
//  StringsTests.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 24/09/21.
//

import XCTest

class StringsTests: XCTestCase {
    var domain = "https://acme2.my.dev.idaptive.app"
    override func setUp() {
        
    }
    override func tearDown() {
        
    }

    func testValidate_String() {
        let value = domain.isValidURL
        XCTAssertTrue(value)
    }
    func testString_NotValidate() {
        let value = "test".isValidURL
        XCTAssertFalse(value)
    }
    func testValidate_Data() {
        let data = domain.toData()
        XCTAssertNotNil(data)
    }
    
    func testString_Endcoding() {
        let str = domain.encodeUrl()
        XCTAssertNotNil(str)
    }
    
    func testString_Decoding() {
        var str = domain.encodeUrl()
        str = domain.decodeUrl()
        XCTAssertNotNil(str)
    }
}
