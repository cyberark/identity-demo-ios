
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
import Foundation

/*
/// This class constructs the URL Request
/// Login  Header
///
*/

enum SignupHeader: String {
    case username = "Username"
    case password = "Password"
}
internal class SignupEndpoint {
    
    init () {
    }
}
extension SignupEndpoint {
        
    /// Login Endpoint
    /// - Parameters:
    ///   - sessionToken: sessionToken description
    ///   - baseURL: baseURL description
    ///   - userName: userName description
    ///   - password: password description
    /// - Returns: Endpoint
    func getSignupEndpoint(baseURL: String, userName: String, password: String) -> Endpoint {
                
        let post = [
            LoginHeader.username.rawValue: userName,
            LoginHeader.password.rawValue: password,
        ] as [String : Any]
        
        let jsonData = post.jsonData
        
        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"
        let path = "/api/BasicLogin"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
