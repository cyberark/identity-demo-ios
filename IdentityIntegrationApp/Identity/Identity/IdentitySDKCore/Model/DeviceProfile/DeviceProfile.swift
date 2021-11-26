
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

public class DeviceProfile : BaseAPIResponse {
    
    let deviceInfo : DeviceInfo?
    
    enum CodingKeys: String, CodingKey {
        case deviceInfo = "Result"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deviceInfo = try values.decodeIfPresent(DeviceInfo.self, forKey: .deviceInfo)
        try super.init(from: decoder)
    }
    
}
struct DeviceInfo : Codable {

        let columns : [Column]?
        let count : Int?
        let fullCount : Int?
        let isAggregate : Bool?
        let results : [InnerResult]?
        let returnID : String?

        enum CodingKeys: String, CodingKey {
                case columns = "Columns"
                case count = "Count"
                case fullCount = "FullCount"
                case isAggregate = "IsAggregate"
                case results = "Results"
                case returnID = "ReturnID"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                columns = try values.decodeIfPresent([Column].self, forKey: .columns)
                count = try values.decodeIfPresent(Int.self, forKey: .count)
                fullCount = try values.decodeIfPresent(Int.self, forKey: .fullCount)
                isAggregate = try values.decodeIfPresent(Bool.self, forKey: .isAggregate)
                results = try values.decodeIfPresent([InnerResult].self, forKey: .results)
                returnID = try values.decodeIfPresent(String.self, forKey: .returnID)
        }

}

struct InnerResult : Codable {

        let entities : [Entity]?
        let row : Row?

        enum CodingKeys: String, CodingKey {
                case entities = "Entities"
                case row = "Row"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                entities = try values.decodeIfPresent([Entity].self, forKey: .entities)
                row = try Row(from: decoder)
        }

}
struct Row : Codable {

        let accountName : String?
        let algorithm : String?
        let base32Secret : String?
        let base64Secret : String?
        let digits : Int?
        let hexSecret : String?
        let iD : String?
        let intervalDelta : Int?
        let isCma : Bool?
        let issuer : String?
        let period : Int?
        let type : String?
        let usage : String?
        let userPrincipalName : String?
        let userUuid : String?
        let uuid : String?
        let version : Int?

        enum CodingKeys: String, CodingKey {
                case accountName = "AccountName"
                case algorithm = "Algorithm"
                case base32Secret = "Base32Secret"
                case base64Secret = "Base64Secret"
                case digits = "Digits"
                case hexSecret = "HexSecret"
                case iD = "ID"
                case intervalDelta = "IntervalDelta"
                case isCma = "IsCma"
                case issuer = "Issuer"
                case period = "Period"
                case type = "Type"
                case usage = "Usage"
                case userPrincipalName = "UserPrincipalName"
                case userUuid = "UserUuid"
                case uuid = "Uuid"
                case version = "Version"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                accountName = try values.decodeIfPresent(String.self, forKey: .accountName)
                algorithm = try values.decodeIfPresent(String.self, forKey: .algorithm)
                base32Secret = try values.decodeIfPresent(String.self, forKey: .base32Secret)
                base64Secret = try values.decodeIfPresent(String.self, forKey: .base64Secret)
                digits = try values.decodeIfPresent(Int.self, forKey: .digits)
                hexSecret = try values.decodeIfPresent(String.self, forKey: .hexSecret)
                iD = try values.decodeIfPresent(String.self, forKey: .iD)
                intervalDelta = try values.decodeIfPresent(Int.self, forKey: .intervalDelta)
                isCma = try values.decodeIfPresent(Bool.self, forKey: .isCma)
                issuer = try values.decodeIfPresent(String.self, forKey: .issuer)
                period = try values.decodeIfPresent(Int.self, forKey: .period)
                type = try values.decodeIfPresent(String.self, forKey: .type)
                usage = try values.decodeIfPresent(String.self, forKey: .usage)
                userPrincipalName = try values.decodeIfPresent(String.self, forKey: .userPrincipalName)
                userUuid = try values.decodeIfPresent(String.self, forKey: .userUuid)
                uuid = try values.decodeIfPresent(String.self, forKey: .uuid)
                version = try values.decodeIfPresent(Int.self, forKey: .version)
        }

}
struct Entity : Codable {

        let isForeignKey : Bool?
        let key : String?
        let type : String?

        enum CodingKeys: String, CodingKey {
                case isForeignKey = "IsForeignKey"
                case key = "Key"
                case type = "Type"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                isForeignKey = try values.decodeIfPresent(Bool.self, forKey: .isForeignKey)
                key = try values.decodeIfPresent(String.self, forKey: .key)
                type = try values.decodeIfPresent(String.self, forKey: .type)
        }

}
struct Column : Codable {

        let dDName : String?
        let dDTitle : String?
        let descriptionField : String?
        let foreignKey : Bool?
        let format : String?
        let isHidden : Bool?
        let name : String?
        let tableKey : String?
        let tableName : String?
        let title : String?
        let type : Int?
        let width : Int?

        enum CodingKeys: String, CodingKey {
                case dDName = "DDName"
                case dDTitle = "DDTitle"
                case descriptionField = "Description"
                case foreignKey = "ForeignKey"
                case format = "Format"
                case isHidden = "IsHidden"
                case name = "Name"
                case tableKey = "TableKey"
                case tableName = "TableName"
                case title = "Title"
                case type = "Type"
                case width = "Width"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                dDName = try values.decodeIfPresent(String.self, forKey: .dDName)
                dDTitle = try values.decodeIfPresent(String.self, forKey: .dDTitle)
                descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
                foreignKey = try values.decodeIfPresent(Bool.self, forKey: .foreignKey)
                format = try values.decodeIfPresent(String.self, forKey: .format)
                isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden)
                name = try values.decodeIfPresent(String.self, forKey: .name)
                tableKey = try values.decodeIfPresent(String.self, forKey: .tableKey)
                tableName = try values.decodeIfPresent(String.self, forKey: .tableName)
                title = try values.decodeIfPresent(String.self, forKey: .title)
                type = try values.decodeIfPresent(Int.self, forKey: .type)
                width = try values.decodeIfPresent(Int.self, forKey: .width)
        }

}


public class DeviceProfileInfo : BaseAPIResponse {
    
    let info : Info?
    
    enum CodingKeys: String, CodingKey {
        case info = "Result"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        info = try values.decodeIfPresent(Info.self, forKey: .info)
        try super.init(from: decoder)
    }
    
}
struct Info : Codable {
        
    let accountName : String?
    let counter : Int?
    let digits : Int?
    let hmacAlgorithm : Int?
    let isCma : Bool?
    let issuer : String?
    let oathProfileUuid : String?
    let oathType : Int?
    let oTPCodeExpiryInterval : Int?
    let oTPCodeMinLength : Int?
    let oTPKey : String?
    let oTPKeyVersion : Int?
    let period : Int?
    let secretKey : String?
    let secretVersion : Int?
    let status : Int?

    enum CodingKeys: String, CodingKey {
            case accountName = "AccountName"
            case counter = "Counter"
            case digits = "Digits"
            case hmacAlgorithm = "HmacAlgorithm"
            case isCma = "IsCma"
            case issuer = "Issuer"
            case oathProfileUuid = "OathProfileUuid"
            case oathType = "OathType"
            case oTPCodeExpiryInterval = "OTPCodeExpiryInterval"
            case oTPCodeMinLength = "OTPCodeMinLength"
            case oTPKey = "OTPKey"
            case oTPKeyVersion = "OTPKeyVersion"
            case period = "Period"
            case secretKey = "SecretKey"
            case secretVersion = "SecretVersion"
            case status = "Status"
    }

    init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            accountName = try values.decodeIfPresent(String.self, forKey: .accountName)
            counter = try values.decodeIfPresent(Int.self, forKey: .counter)
            digits = try values.decodeIfPresent(Int.self, forKey: .digits)
            hmacAlgorithm = try values.decodeIfPresent(Int.self, forKey: .hmacAlgorithm)
            isCma = try values.decodeIfPresent(Bool.self, forKey: .isCma)
            issuer = try values.decodeIfPresent(String.self, forKey: .issuer)
            oathProfileUuid = try values.decodeIfPresent(String.self, forKey: .oathProfileUuid)
            oathType = try values.decodeIfPresent(Int.self, forKey: .oathType)
            oTPCodeExpiryInterval = try values.decodeIfPresent(Int.self, forKey: .oTPCodeExpiryInterval)
            oTPCodeMinLength = try values.decodeIfPresent(Int.self, forKey: .oTPCodeMinLength)
            oTPKey = try values.decodeIfPresent(String.self, forKey: .oTPKey)
            oTPKeyVersion = try values.decodeIfPresent(Int.self, forKey: .oTPKeyVersion)
            period = try values.decodeIfPresent(Int.self, forKey: .period)
            secretKey = try values.decodeIfPresent(String.self, forKey: .secretKey)
            secretVersion = try values.decodeIfPresent(Int.self, forKey: .secretVersion)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
    }

}
