//
//  QRAuthResultModel.swift
//  Identity
//
//  Created by Raviraju Vysyaraju on 13/07/21.
//

import Foundation

struct QRAuthResultModel : Codable {
    
    let auth : String?
    let authLevel : String?
    let customerID : String?
    let displayName : String?
    let emailAddress : String?
    let podFqdn : String?
    let sourceDsType : String?
    let summary : String?
    let systemID : String?
    let user : String?
    let userDirectory : String?
    let userId : String?
    
    enum CodingKeys: String, CodingKey {
        case auth = "Auth"
        case authLevel = "AuthLevel"
        case customerID = "CustomerID"
        case displayName = "DisplayName"
        case emailAddress = "EmailAddress"
        case podFqdn = "PodFqdn"
        case sourceDsType = "SourceDsType"
        case summary = "Summary"
        case systemID = "SystemID"
        case user = "User"
        case userDirectory = "UserDirectory"
        case userId = "UserId"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        auth = try values.decodeIfPresent(String.self, forKey: .auth)
        authLevel = try values.decodeIfPresent(String.self, forKey: .authLevel)
        customerID = try values.decodeIfPresent(String.self, forKey: .customerID)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        emailAddress = try values.decodeIfPresent(String.self, forKey: .emailAddress)
        podFqdn = try values.decodeIfPresent(String.self, forKey: .podFqdn)
        sourceDsType = try values.decodeIfPresent(String.self, forKey: .sourceDsType)
        summary = try values.decodeIfPresent(String.self, forKey: .summary)
        systemID = try values.decodeIfPresent(String.self, forKey: .systemID)
        user = try values.decodeIfPresent(String.self, forKey: .user)
        userDirectory = try values.decodeIfPresent(String.self, forKey: .userDirectory)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
    }
}
