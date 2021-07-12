//
//  AuthOChallengeGenerator.swift
//  CIAMWebLoginSample
//
//  Created by Mallikarjuna Punuru on 23/06/21.
//

import Foundation
import CommonCrypto


//https://aae5953.my.idaptive.qa/oauth2/authorize/testapplicationID?response_type=code&state=1234&client_id=icici&scope=All&redirect_uri=demo:aae5953.my.idaptive.qa/ios/com.cyberark.ciamsdk/callback

public class AuthOPKCE {
    
    let kVerifierSize = 32
    private(set) var verifier: String?
    private(set) var challenge: String?
    private(set) var method: String?
    
    convenience init() {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        let verifier = Data(bytes: buffer)
        self.init(verifier: verifier)
    }
    init(verifier: Data?) {
        self.verifier = verifier?.base64EncodedString(options: []).replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").trimmingCharacters(
            in: CharacterSet(charactersIn: "="))
        method = "S256"
        challenge = createCodeChallenge()
    }
    // Dependency: Apple Common Crypto library
    // http://opensource.apple.com//source/CommonCrypto
    func createCodeChallenge() -> String? {
        guard let data = verifier?.data(using: .utf8) else { return nil }
        var buffer = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(bytes: buffer)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return challenge
    }
}
