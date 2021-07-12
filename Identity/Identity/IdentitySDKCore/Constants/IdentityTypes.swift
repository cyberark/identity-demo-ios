//
//  Types.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 02/07/21.
//

import Foundation

public enum IdentityLoginType {
    case oidc
    case auth0
    case fido
}
public enum IdentityType: CaseIterable {
    case web
    case qrcode
    case totp
    case push
    case otp
}


