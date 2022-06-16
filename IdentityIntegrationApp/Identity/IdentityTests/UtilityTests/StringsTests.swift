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
