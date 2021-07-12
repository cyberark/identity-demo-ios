//
//  Bundle+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 05/07/21.
//

import Foundation

extension Bundle {
    static func getVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

}
