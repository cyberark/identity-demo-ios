//
//  QRAuthModel.swift
//  QRScanner
//
//  Created by Raviraju Vysyaraju on 07/07/21.
//  Copyright © 2021 Raviraju Vysyaraju. All rights reserved.
//

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


