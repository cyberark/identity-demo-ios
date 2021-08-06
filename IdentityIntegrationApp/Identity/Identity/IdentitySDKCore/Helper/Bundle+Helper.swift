//
//  Bundle+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 05/07/21.
//

import Foundation

let CFBundleVersion = "CFBundleVersion"
let CFBundleShortVersionString = "CFBundleShortVersionString"
let CFBundleDisplayName = "CFBundleDisplayName"

extension Bundle {
    static func getVersion() -> String? {
        return Bundle.main.infoDictionary?[CFBundleVersion] as? String ?? "1.0"
    }
    static func getBuildNumber() -> String? {
        return Bundle.main.infoDictionary?[CFBundleShortVersionString] as? String ?? "1.0"
    }
    static func getBundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
    static func getdisplayName() -> String? {
        return Bundle.main.infoDictionary?[CFBundleDisplayName] as? String
    }
}
