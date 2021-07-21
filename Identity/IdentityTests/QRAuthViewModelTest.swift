//
//  QRAuthViewModelTest.swift
//  IdentityTests
//
//  Created by Raviraju Vysyaraju on 19/07/21.
//

import XCTest
@testable import Identity

class QRAuthViewModelTest: XCTestCase {

    
    var sut: QRAuthViewModel!
    var mockAPIService: MockQRApiService!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockQRApiService()
        sut = QRAuthViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_qrAuthApi_fail() {
        
        // Given a failed fetch with a certain failure
        let error = APIError.requestFailed
        
        // When
//        sut.fetchAuthToken(uri: "")
        
        sut.didReceiveAuth = { result, value in
            XCTAssertEqual(result, false)
            XCTAssertEqual(value, error.localizedDescription)
        }
        // Sut should display predefined error message
        mockAPIService.featchQRAuth(from: Endpoint(httpMethod: .get, dataType: .JSON)) { [self] result in
            switch result {
            case .success( _):
                break
            case .failure( _):
                sut.didReceiveAuth!(false, error.localizedDescription)
            }
        }
        
        mockAPIService.fetchFail(error: error )
    }
    
    
    func test_qrAuthApi_success() {
        
        // When
//        sut.fetchAuthToken(uri: "uri")
        
        // Sut should display predefined error message
        sut.didReceiveAuth = { result, value in
            XCTAssertEqual(result, true)
            XCTAssertEqual(value, "sample_auth")
        }
        
        mockAPIService.featchQRAuth(from: Endpoint(httpMethod: .get, dataType: .JSON)) { [self] result in
            switch result {
            case .success(let data):
                guard let response = data else {
                    print("Test Response Data not valid")
                    sut.didReceiveAuth!(false, "Response Data not valid")
                    return
                }
                print("Test QRAuthToken \(String(describing: response.result?.auth))")
                sut.authResponse = response
            case .failure( _):
                break;
            }
        }
        //
        mockAPIService.fetchSuccess()
    }
    
    func test_qrAuthApi_success_InValidData() {
        
        // When
        sut.fetchAuthToken(uri: "")
        
        sut.didReceiveAuth = { result, value in
            XCTAssertEqual(result, false)
            XCTAssertEqual(value, "Response Data not valid")
        }
        
        mockAPIService.featchQRAuth(from: Endpoint(httpMethod: .get, dataType: .JSON)) { [self] result in
            switch result {
            case .success(let data):
                guard let response = data else {
                    sut.didReceiveAuth!(false, "Response Data not valid")
                    return
                }
                sut.authResponse = response
            case .failure( _):
                break;
            }
        }
        mockAPIService.fetchSuccess_NilData()
    }
}

class MockQRApiService: QRCodeAuthClientProtocol {
    init() {
        
    }
    
    var completeAuthModel: QRAuthModel? = StubQrAPIAuthGenerator().stubAuthModel()
    var completeClosure: ((Result<QRAuthModel?, APIError>) -> Void?)? = nil
    
    func featchQRAuth(from endpoint: Endpoint, completion: @escaping (Result<QRAuthModel?, APIError>) -> Void) {
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
class StubQrAPIAuthGenerator {
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
