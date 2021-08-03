//
//  String+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 07/07/21.
//

import Foundation

extension String {
    /// Encode the string
    /// - Returns: encoded string
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    /// Decodes the String
    /// - Returns: the decoded string
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
    func toData() -> Data? {
        return self.data(using: .utf8)
    }
}
