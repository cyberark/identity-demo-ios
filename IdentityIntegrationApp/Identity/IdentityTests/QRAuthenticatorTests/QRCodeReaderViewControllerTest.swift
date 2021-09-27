
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

    func testQRCodeReaderViewController_viewDidLayoutSubviews() {
        readerVC.viewDidLayoutSubviews()
        XCTAssertNotNil(readerVC.videoPreview)
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
