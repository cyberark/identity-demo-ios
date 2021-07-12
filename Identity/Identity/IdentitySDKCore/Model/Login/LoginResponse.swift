//
//  LoginResponse.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 28/06/21.
//

import Foundation

struct LoginResponse: Codable {
    let result: String?
}

struct LoginRequest: Codable {
    let userName: String?
    let password: String?

}
