//
//  QRCodeReaderViewControllerTest.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 30/07/21.
//


import XCTest
@testable import Identity

class QRCodeReaderViewControllerTest: XCTestCase {

    var readerVC: QRCodeReaderViewController!
    var mockReader = MockQRCodeReader()

    override func setUp() {
        super.setUp()
        readerVC = QRCodeReaderViewController.loadFromNib()
        readerVC.codeReader = mockReader
        let window = UIWindow()
        window.rootViewController = readerVC
        window.makeKeyAndVisible()
    }

    func testItFiresRightEventWhenKnownCodeIsRead() {
        let exp = expectation(description: "calls didFindCard")

        //given
        var didFindCardWasCalled = false
        readerVC.didFindQRCode = { code in
            didFindCardWasCalled = true
            exp.fulfill()
        }
        //when
        mockReader.completion?("123")

        //then
        waitForExpectations(timeout: 3) { error in
            XCTAssert(didFindCardWasCalled)
            XCTAssertNil(error)
        }

    }

    func testItFiresRightEventWhenUnKnownCodeIsRead() {
        let exp = expectation(description: "calls didReadUnknownCode")

        //given
        var didReadUnknownCodeWasCalled = false
        readerVC.didFindQRCode = { _ in
            didReadUnknownCodeWasCalled = true
            exp.fulfill()
        }
        //when
        mockReader.completion?("ABC")

        //then
        waitForExpectations(timeout: 3) { error in
            XCTAssert(didReadUnknownCodeWasCalled)
            XCTAssertNil(error)
        }
        
    }

}
