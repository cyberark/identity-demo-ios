//
//  Data+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//

import Foundation

public extension Data {
    
    var JSONObject: AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as AnyObject
        } catch let error as NSError {
            debugPrint("Unable to parse the JSON : The error: \(error)")
            return nil
        }
    }
    
    static func make(fromJSONObject obj: AnyObject) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: obj, options: [])
        } catch let error as NSError {
            debugPrint("Unable to convert to the the JSON : The error: \(error)")
            return nil
        }
    }
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
public extension Data {
    func encodeBase64URLSafe() -> String? {
        return self
            .base64EncodedString(options: [])
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }
}

