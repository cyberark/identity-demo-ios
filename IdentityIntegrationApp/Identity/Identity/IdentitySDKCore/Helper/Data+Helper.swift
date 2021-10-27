
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
import CommonCrypto

public extension Data {
    
    var JSONObject: AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as AnyObject
        } catch let error as NSError {
            //debugPrint("Unable to parse the JSON : The error: \(error)")
            return nil
        }
    }
    
    static func make(fromJSONObject obj: AnyObject) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: obj, options: [])
        } catch let error as NSError {
            //debugPrint("Unable to convert to the the JSON : The error: \(error)")
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
extension Data {
    /// The data represented as a byte array
    public var bytes: Array<UInt8> {
        return Array(self)
    }

    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
}

extension Array where Element == UInt8 {

    init(reserveCapacity: Int) {
      self = Array<Element>()
      self.reserveCapacity(reserveCapacity)
    }

    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }

            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)

            switch c {
            case let c where c <= 57:
              v = c - 48
            case let c where c >= 65 && c <= 70:
              v = c - 55
            case let c where c >= 97:
              v = c - 87
            default:
              removeAll()
              return
            }

            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }

        if let b = buffer {
            append(b)
        }
      }

    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
          var s = String($1, radix: 16)
          if s.count == 1 {
            s = "0" + s
          }
          $0 += s
        }
    }
}
extension Data{
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
