
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


public class EnrollResponse : BaseAPIResponse {
    
    let enrollInfo : EnrollInfo?
    
    enum CodingKeys: String, CodingKey {
        case enrollInfo = "Result"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enrollInfo = try values.decodeIfPresent(EnrollInfo.self, forKey: .enrollInfo)
        try super.init(from: decoder)
    }
    
}
struct EnrollInfo : Codable {
    
    let userCert : String?
    let welcomePageInfo : WelcomePageInfo?
    
    enum CodingKeys: String, CodingKey {
        case userCert = "UserCert"
        case welcomePageInfo = "WelcomePageInfo"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userCert = try values.decodeIfPresent(String.self, forKey: .userCert)
        welcomePageInfo = try WelcomePageInfo(from: decoder)
    }
    
}
struct WelcomePageInfo : Codable {
    
    let icon : String?
    let iconBackgroundColor : String?
    let iconUrl : String?
    let welcomeText : String?
    
    enum CodingKeys: String, CodingKey {
        case icon = "Icon"
        case iconBackgroundColor = "IconBackgroundColor"
        case iconUrl = "IconUrl"
        case welcomeText = "WelcomeText"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        iconBackgroundColor = try values.decodeIfPresent(String.self, forKey: .iconBackgroundColor)
        iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl)
        welcomeText = try values.decodeIfPresent(String.self, forKey: .welcomeText)
    }
    
}
