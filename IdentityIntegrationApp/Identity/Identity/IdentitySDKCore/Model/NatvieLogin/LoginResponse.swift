
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


public class LoginResponse : BaseAPIResponse {
    
    let loginInfo: LoginInfo?
    let status: Bool?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case loginInfo = "Result"
        case status = "Success"
        case errorMessage = "ErrorMessage"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage)
        loginInfo = try values.decodeIfPresent(LoginInfo.self, forKey: .loginInfo)
        try super.init(from: decoder)
    }
    
}
struct LoginInfo : Codable {
    
    let sessionUuid : String?
    
    enum CodingKeys: String, CodingKey {
        case sessionUuid = "sessionUuid"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sessionUuid = try values.decodeIfPresent(String.self, forKey: .sessionUuid)
    }
    
}
