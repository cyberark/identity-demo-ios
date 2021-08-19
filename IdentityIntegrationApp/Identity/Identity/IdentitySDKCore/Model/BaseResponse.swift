//
//  BaseResponse.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 12/08/21.
//
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

/// Base Api response
/// Every model class should be derived from this class

public class BaseAPIResponse: Codable {
    
    let errorCode : String?
    let errorID : String?
    let exception : String?
    let innerExceptions : String?
    let isSoftError : Bool?
    let message : String?
    let messageID : String?
    let success : Bool?
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case errorID = "ErrorID"
        case exception = "Exception"
        case innerExceptions = "InnerExceptions"
        case isSoftError = "IsSoftError"
        case message = "Message"
        case messageID = "MessageID"
        case success = "success"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try values.decodeIfPresent(String.self, forKey: .errorCode)
        errorID = try values.decodeIfPresent(String.self, forKey: .errorID)
        exception = try values.decodeIfPresent(String.self, forKey: .exception)
        innerExceptions = try values.decodeIfPresent(String.self, forKey: .innerExceptions)
        isSoftError = try values.decodeIfPresent(Bool.self, forKey: .isSoftError)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        messageID = try values.decodeIfPresent(String.self, forKey: .messageID)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
    }
    
}
