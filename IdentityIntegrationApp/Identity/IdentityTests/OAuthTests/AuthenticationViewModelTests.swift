//
//  AuthenticationViewModelTests.swift
//  IdentityTests
//
//  Created by Mallikarjuna Punuru on 10/08/21.
//

import XCTest
@testable import Identity

class AuthenticationViewModelTests: XCTestCase {
    
    var suitViewModel: AuthenticationViewModel!
    
    var mockAPIService: MockAuthViewModelApiService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAuthViewModelApiService()
        suitViewModel = AuthenticationViewModel(apiClient: mockAPIService)
    }
    
    override func tearDown() {
        suitViewModel = nil
        mockAPIService = nil
        suitViewModel = nil
        super.tearDown()
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        accessTokenCompletionClosure = completion
    }
    
    func endSession(with endpoint: Endpoint, completion: @escaping (Result<AccessToken?, APIError>) -> Void) {
        endSessionCompletionClosure = completion
    }
    
    func fetchAuthToken(code: String, pkce: AuthOPKCE?) {
        
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
class mockAPIServiceGenerator {
    func stubAuthModel() -> QRAuthModel? {
        let auth = "sample_auth"
        let value = "{\"success\":true,\"Result\":{\"AuthLevel\":\"Normal\",\"DisplayName\":\"Raviraju\",\"Auth\":\"\(auth)\",\"UserId\":\"b86b97dc-9ec0-4997-9568-42ecba1eafdb\",\"EmailAddress\":\"raviraju.vysyaraju@cyberark.com\",\"UserDirectory\":\"CDS\",\"PodFqdn\":\"aaj7479.my.dev.idaptive.app\",\"User\":\"raviraju@aaj7479.com\",\"CustomerID\":\"AAJ7479\",\"SystemID\":\"AAJ7479\",\"SourceDsType\":\"CDS\",\"Summary\":\"LoginSuccess\"},\"Message\":null,\"MessageID\":null,\"Exception\":null,\"ErrorID\":null,\"ErrorCode\":null,\"IsSoftError\":false,\"InnerExceptions\":null}"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = value.toData() {
            let authModel = try! decoder.decode(QRAuthModel.self, from: data)
            return authModel
        }
        return nil
    }
}
