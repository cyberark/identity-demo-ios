
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

class MFAChallendgeEndpointTests: XCTestCase {

    var mockEndPoint: MFAChallengeEndpoint?

    override func setUp() {
        super.setUp()
        configValues()
    }
    override func tearDown() {
        super.tearDown()
        mockEndPoint = nil
    }
    func configValues(){
    }
    /// To get the autherization endpoint
    /// - Returns: Endpoint
    func test_Enroll_Device_Endpoint() {
    }
}
