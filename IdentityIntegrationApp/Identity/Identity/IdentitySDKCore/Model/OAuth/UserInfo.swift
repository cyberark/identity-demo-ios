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

public struct UserInfo: Codable {
    public let auth_time: Double?
    public let given_name: String?
    public let name: String?
    public let email: String?
    public let family_name: String?
    public let preferred_username: String?
    public let unique_name: String?
    public let email_verified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case auth_time = "auth_time"
        case given_name = "given_name"
        case name = "name"
        case email = "email"
        case family_name = "family_name"
        case preferred_username = "preferred_username"
        case unique_name = "unique_name"
        case email_verified = "email_verified"

    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        auth_time = try values.decodeIfPresent(Double.self, forKey: .auth_time)
        given_name = try values.decodeIfPresent(String.self, forKey: .given_name)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        family_name = try values.decodeIfPresent(String.self, forKey: .family_name)
        preferred_username = try values.decodeIfPresent(String.self, forKey: .preferred_username)
        unique_name = try values.decodeIfPresent(String.self, forKey: .unique_name)
        email_verified = try values.decodeIfPresent(Bool.self, forKey: .email_verified)
    }
}
