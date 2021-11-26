
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

class MFAViewModelTests: XCTestCase {

    
    var suit: MFAViewModel!
    var mockAPIService: MockMFAApiService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockMFAApiService()
        suit = MFAViewModel(apiClient: mockAPIService)
    }
    
    override func tearDown() {
        suit = nil
        mockAPIService = nil
        super.tearDown()
    }

    func test_qrAuthApi_fail() {
        
        // Given a failed fetch with a certain failure
        let error = APIError.requestFailed
        
        // When
//        sut.fetchAuthToken(uri: "")
        suit.didReceiveMFAApiResponse = { (result, value) in
            XCTAssertFalse(result)
            XCTAssertEqual(value, "unable to approve the identity")

        }
        // Sut should display predefined error message
        suit.handleMFA(isAccepted: true, challenge: "aaa", baseURL: "aaa") {
            
        }
        mockAPIService.fetchFail(error: error )
    }
    
    
    func test_qrAuthApi_success() {
        
        // When
//        sut.fetchAuthToken(uri: "uri")
        
        // Sut should display predefined error message
        suit.didReceiveMFAApiResponse = { result, value in
            XCTAssertTrue(result)
            XCTAssertEqual(value, "")
        }
        // Sut should display predefined error message
        suit.handleMFA(isAccepted: true, challenge: "aaa", baseURL: "aaa") {
            
        }

        mockAPIService.fetchSuccess()
    }
    
    func test_qrAuthApi_success_InValidData() {
        suit.didReceiveMFAApiResponse = { error, value in
            XCTAssertNotNil(error)
            XCTAssertNil(value)
        }
        // Sut should display predefined error message
        suit.handleMFA(isAccepted: true, challenge: "aaa", baseURL: "aaa") {
            
        }
        mockAPIService.fetchSuccess_NilData()
    }
}

class MockMFAApiService: MFAChallengeClientProtocol {
    
    init() {
    }
    
    var completeAuthModel = StubMFAPushGenerator().stubAuthModel()
    var completeClosure: ((Result<EnrollResponse?, APIError>) -> Void?)? = nil
    
    
    func handleMFAChallenge(from isAccepted: Bool, accesstoken: String, baseURL: String, challenge: String, completion: @escaping (Result<EnrollResponse?, APIError>) -> Void) {
        completeClosure = completion
    }
    
    func fetchSuccess() {
        if let handler = completeClosure {
            handler(Result.success(completeAuthModel))
        }
    }
    
    func fetchSuccess_NilData() {
        if let handler = completeClosure {
            handler(Result.success(nil))
        }
    }
    
    func fetchFail(error: APIError?) {
        if let handler = completeClosure {
            handler(Result.failure(.invalidData))
        }
    }
    
}
class StubMFAPushGenerator {
    func stubAuthModel() -> EnrollResponse? {
        let value = "{\"success\":true,\"Result\":null,\"Message\":null,\"MessageID\":null,\"Exception\":null,\"ErrorID\":null,\"ErrorCode\":null,\"IsSoftError\":false,\"InnerExceptions\":null}"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = value.toData() {
            let authModel = try! decoder.decode(EnrollResponse.self, from: data)
            return authModel
        }
        return nil
    }
}

