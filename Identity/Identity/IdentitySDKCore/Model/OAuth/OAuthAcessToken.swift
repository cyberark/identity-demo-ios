//
//  OAuthAcessToken.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 08/07/21.
//

import Foundation

struct AccessToken: Codable {
    var access_token: String?
    var token_type: String?
    var expires_in: Int?
    var scope: String?
}
