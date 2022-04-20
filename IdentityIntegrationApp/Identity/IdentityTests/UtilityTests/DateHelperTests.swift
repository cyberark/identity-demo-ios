
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

class DateHelperTests: XCTestCase {

    override func setUp() {
        
    }
    override func tearDown() {
        
    }
    
    func testDate_Equal() {
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = someDateTime.isEqualTo(someDateTime)
        XCTAssertTrue(value)
    }

    func testDate_NotEqual() {
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = someDateTime.isEqualTo(Date())
        XCTAssertFalse(value)
    }
    
    func testDate_isGreaterThan() {
        let today = Date()
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = today.isGreaterThan(someDateTime)
        XCTAssertTrue(value)
    }
    
    func testDate_NotGreaterThanCurrentDate() {
        let today = Date()
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = someDateTime.isGreaterThan(today)
        XCTAssertFalse(value)
    }
    
    func testDate_NotSmallerThanCurrentDate() {
        let today = Date()
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = today.isSmallerThan(someDateTime)
        XCTAssertFalse(value)
    }
    
    func testDate_isSmallerThanCurrentDate() {
        let today = Date()
        let someDateTime = Date(timeIntervalSinceReferenceDate: -123456789.0)
        let value = someDateTime.isSmallerThan(today)
        XCTAssertTrue(value)
    }
    
    func testEpirationDate() {
        let today = Date()
        let date = today.epirationDate(with: 1000)
        XCTAssertNotNil(date)
    }
     
    func testIsAccessTokenExpired() {
        let str = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkYxMTg1RTAwQkIwRDk5NzBGREIxRTJDNTg0QUE5N0NFMEU2MDdCNUQiLCJ4NXQiOiI4UmhlQUxzTm1YRDlzZUxGaEtxWHpnNWdlMTAiLCJhcHBfaWQiOiJ0ZXN0YXBwbGljYXRpb25JRCJ9.eyJhdXRoX3RpbWUiOjE2Mjk5OTEyNDksImlzcyI6Imh0dHBzOi8vYWFlNTk1My5teS5pZGFwdGl2ZS5xYS8iLCJpYXQiOjE2Mjk5OTEyNTIsImF1ZCI6ImZjMzc2Y2Q2LWZlNTAtNDIzZC1iODkwLWI5NmEyMTEzMmZlYSIsInVuaXF1ZV9uYW1lIjoiZGVtb2FjY291bnRAdGVzdHRlbmFudDEiLCJleHAiOjE2MzAwMDkyNTIsInN1YiI6ImQ5YzZjZjFiLTMxY2MtNDQ0Yi1iOTgxLWVhYWM1ZDkxYWI1MyIsInNjb3BlIjoiQWxsIn0.EGJg71Hr-bIId4Qkmy4_vXS0wFXZgineMkqbEj_D5A6nIq-HaofIYD4ZCfUyDU-TpjGtgVPJsBLGcuGl8WLUR3N22e72i3aYYb6FXNs4-7_L6NtwKap6pOLBpghQEp0EFJ_V3333tHEGeGpeR3P9kdu6Z7UBirJLwSLU3CMviSPMBqMF6FnU8x6ET3ENF_xZhqnmKsGpRhFaQrzrifbEXviYr_q6PqENnI_qJdt9PDyiJa0PlBgjauoiRZqaYcODx7EMh3_JD3qh8660KFS_-smk1-jRdImXOUXqpBoKn51NyccBXFw5DZ93qxtbNc6C1-jLK5IvQhSybPIGfsZjnQ"
        let isValid = Date().isAccessTokenExpired(with: str.toData())
        XCTAssertFalse(isValid)
    }
    
    func testIsAccessTokenExpired_NotValidToken() {
        let isValid = Date().isAccessTokenExpired(with: nil)
        XCTAssertFalse(isValid)
    }
}
