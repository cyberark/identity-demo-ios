//
//  Data+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//
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

public extension Data {
    func toString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8) as String?
    }
}
