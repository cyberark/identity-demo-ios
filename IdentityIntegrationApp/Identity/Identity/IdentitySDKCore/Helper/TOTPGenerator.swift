
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
import CryptoKit
import CommonCrypto
//https://developer.apple.com/forums/thread/120918

public enum HMACAlgorithm: Int
{
    case Sha1 = 0
    case Sha256
    case Sha512
    case Md5
}

public class TOTPGenerator {
    
    var digits = 6
    var secret: Data?
    var counter: UInt64?
    var algorithm: Int?
    var period: Int?

    init?(
        secret: Data?,
        algorithm: Int?,
        digits: Int,
        counter: UInt64,
        period: Int?
    ) {
        self.digits = digits
        self.algorithm = algorithm
        self.counter = counter
        self.secret = secret ?? Data()
        self.period = period
        
    }
    func generateOTP() -> String {
        
        self.secret = convertToBase64(secret: self.secret ?? Data())
        
        let hmac = getAlgorithmData()
     
        // Get last 4 bits of hash as offset
        let offset = Int((hmac.last ?? 0x00) & 0x0f)
        
        // Get 4 bytes from the hash from [offset] to [offset + 3]
        let truncatedHMAC = Array(hmac[offset...offset + 3])
        
        // Convert byte array of the truncated hash to data
        let data =  Data(truncatedHMAC)
        
        // Convert data to UInt32
        var number = UInt32(strtoul(data.bytes.toHexString(), nil, 16))
        
        // Mask most significant bit
        number &= 0x7fffffff
        
        // Modulo number by 10^(digits)
        number = number % UInt32(pow(10, Float(digits)))

        // Convert int to string
        let strNum = String(number)
        
        // Return string if adding leading zeros is not required
        if strNum.count == digits {
            return strNum
        }
        
        // Add zeros to start of string if not present and return
        let prefixedZeros = String(repeatElement("0", count: (digits - strNum.count)))
        return (prefixedZeros + strNum)
    }
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    func convertToBase64(secret: Data) -> Data?  {
        let base64Data = secret.base64EncodedString()
        return base64Data.base64Decoded()
    }
    func getAlgorithmData() -> Data {
        
        let period = TimeInterval(self.period ?? 30)

        var counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian

        let counterData = withUnsafeBytes(of: &counter) { Array($0) }

        var hmac = Data()

        let algorithmType = HMACAlgorithm(rawValue: algorithm ?? 0)
        switch algorithmType {
        case .Sha1:
            hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: SymmetricKey.init(data: secret ?? Data())))
        case .Sha256:
            hmac = Data(HMAC<SHA256>.authenticationCode(for: counterData, using: SymmetricKey.init(data: secret ?? Data())))
        case .Sha512:
            hmac = Data(HMAC<SHA512>.authenticationCode(for: counterData, using: SymmetricKey.init(data: secret ?? Data())))
        case .Md5:
            hmac = Data(HMAC<Insecure.MD5>.authenticationCode(for: counterData, using: SymmetricKey.init(data: secret ?? Data())))
        case .none:
            break
        }
        return hmac
    }
}
