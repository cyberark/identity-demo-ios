
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

class AuthenticationViewModelTests: XCTestCase {
    
    var suitViewModel: AuthenticationViewModel!
    
    var mockAPIService: MockAuthViewModelApiService!
    var pkce = AuthOPKCE()

    override func setUp() {
        super.setUp()
        deleteGranCode()
        saveGrantCode()
        mockAPIService = MockAuthViewModelApiService()
        suitViewModel = AuthenticationViewModel(apiClient: mockAPIService)
    }
    
    override func tearDown() {
        suitViewModel = nil
        mockAPIService = nil
        suitViewModel = nil
        deleteGranCode()
        super.tearDown()
    }

    func deleteGranCode() {
        do {
            let keyChain = KeyChainWrapper.standard
            try keyChain.delete(key: KeyChainStorageKeys.grantCode.rawValue)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func saveGrantCode() {
        do {
            let keyChain = KeyChainWrapper.standard
            let data = "grantCode".toData() ?? Data()
            try keyChain.save(key: KeyChainStorageKeys.grantCode.rawValue, data: data)
        } catch {
            debugPrint("error: \(error)")
        }
    }
    func testFetchAuthToken_Success() {
        let delayExpectation = expectation(description: "Waiting for QR Auth request failed")
        // Fulfill the expectation after 2 seconds
        DispatchQueue.main.async {
            delayExpectation.fulfill()
        }

        mockAPIService.didReceiveAccessToken = { (status, message) in
            XCTAssertNotNil(status)
            XCTAssertNotNil(message)
        }
        suitViewModel.fetchAuthToken(code: "test", pkce: pkce)
        waitForExpectations(timeout: 2)
        mockAPIService.fetchSuccess()
    }
    
}
class MockAuthViewModelApiService: OAuthClientProtocol {
   
    public var didReceiveAccessToken: ((Bool,String) -> Void)?
    
    public var didReceiveRefreshToken: ((Bool, String) -> Void)?
    
    public var didDeviceEnrolled: ((Bool, String) -> Void)?

    public var didLoggedOut: ((Bool, String) -> Void)?

    var accessTokenCompletionClosure: ((Result<AccessToken?, APIError>) -> Void?)? = nil
        
    var endSessionCompletionClosure: ((Result<AccessToken?, APIError>) -> Void?)? = nil
    
    func fetchAccessToken(from endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        
    }
    
    func endSession(with endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        endSessionCompletionClosure = completion
    }
    
    func fetchAuthToken(code: String, pkce: AuthOPKCE?) {
        
    }

    func fetchAccessToken(from pkce: AuthOPKCE, code: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        accessTokenCompletionClosure = completion
    }
    
    func fetchRefreshToken(with pkce: AuthOPKCE, code: String, refreshToken: String, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        
    }
    
    func updateDeviceToken(with deviceToken: Data, baseURL: String, completion: @escaping (Result<BaseAPIResponse?, APIError>) -> Void) {
        
    }
    
    func fetchSuccess() {
        if let handler = didReceiveAccessToken {
            handler(true, "")
        }
    }
    
    func fetchFail(error: APIError?) {
        if let handler = didReceiveAccessToken {
            handler(false, "failed")
        }
    }
}
class MockOAUthAPIServiceGenerator {
    func stubAuthModel() -> AccessToken? {
        let value = "{\"access_token\":\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkYxMTg1RTAwQkIwRDk5NzBGREIxRTJDNTg0QUE5N0NFMEU2MDdCNUQiLCJ4NXQiOiI4UmhlQUxzTm1YRDlzZUxGaEtxWHpnNWdlMTAiLCJhcHBfaWQiOiJ0ZXN0YXBwbGljYXRpb25JRCJ9.eyJhdXRoX3RpbWUiOjE2Mjk5OTEyNDksImlzcyI6Imh0dHBzOi8vYWFlNTk1My5teS5pZGFwdGl2ZS5xYS8iLCJpYXQiOjE2Mjk5OTEyNTIsImF1ZCI6ImZjMzc2Y2Q2LWZlNTAtNDIzZC1iODkwLWI5NmEyMTEzMmZlYSIsInVuaXF1ZV9uYW1lIjoiZGVtb2FjY291bnRAdGVzdHRlbmFudDEiLCJleHAiOjE2MzAwMDkyNTIsInN1YiI6ImQ5YzZjZjFiLTMxY2MtNDQ0Yi1iOTgxLWVhYWM1ZDkxYWI1MyIsInNjb3BlIjoiQWxsIn0.EGJg71Hr-bIId4Qkmy4_vXS0wFXZgineMkqbEj_D5A6nIq-HaofIYD4ZCfUyDU-TpjGtgVPJsBLGcuGl8WLUR3N22e72i3aYYb6FXNs4-7_L6NtwKap6pOLBpghQEp0EFJ_V3333tHEGeGpeR3P9kdu6Z7UBirJLwSLU3CMviSPMBqMF6FnU8x6ET3ENF_xZhqnmKsGpRhFaQrzrifbEXviYr_q6PqENnI_qJdt9PDyiJa0PlBgjauoiRZqaYcODx7EMh3_JD3qh8660KFS_-smk1-jRdImXOUXqpBoKn51NyccBXFw5DZ93qxtbNc6C1-jLK5IvQhSybPIGfsZjnQ\",\"token_type\":\"Bearer\",\"refresh_token\":\"-rTZOneIc0yT-wKoFWH6HHlvbgKs56z7DZ4DNIjvxr01\",\"expires_in\":18000,\"scope\":\"All\"}"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = value.toData() {
            let authModel = try! decoder.decode(AccessToken.self, from: data)
            return authModel
        }
        return nil
    }
}
