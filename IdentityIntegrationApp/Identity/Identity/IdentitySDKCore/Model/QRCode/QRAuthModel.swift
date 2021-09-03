
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

struct QRAuthModel : Codable {
    let errorCode : String?
    let errorID : String?
    let exception : String?
    let innerExceptions : String?
    let isSoftError : Bool?
    let message : String?
    let messageID : String?
    let result : QRAuthResultModel?
    let success : Bool?
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case errorID = "ErrorID"
        case exception = "Exception"
        case innerExceptions = "InnerExceptions"
        case isSoftError = "IsSoftError"
        case message = "Message"
        case messageID = "MessageID"
        case result = "Result"
        case success = "success"
    }
}


