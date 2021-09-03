
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

/**
  enum to return possible errors
 */
public enum KeychainError: Error {
    /// Error with the keychain creting and checking
    case create_error
    /// Error for operation
    case operation_error
}
public enum KeyChainStorageKeys: String {
    case accessToken = "access_token"
    case grantCode = "grant_code"
    case refreshToken = "refresh_code"
    case access_token_expiresIn = "access_token_expiresIn"

}
/// Keychain Wrapper
/// Wrapper to store the credentials in secure way
///
public class KeyChainWrapper {
    
    public static let standard = KeyChainWrapper()
    
    private (set) public var serviceName: String = {
        return "OAuth"
    }()
    
    private (set) public var accessGroup: String = {
        return Bundle.main.bundleIdentifier ?? "com.cyberark.Identity"
    }()
    
    private init() {
    }
    
    /// To save the keychain
    /// - Parameters:
    ///   - key: key
    ///   - data: data
    /// - Throws: erro
    public func save(key: String, data: Data) throws {
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: serviceName,
            kSecValueData: data,
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as NSDictionary, nil)
        
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
    /// To fetch the keys
    /// - Parameter key: key
    /// - Throws: data
    /// - Returns: data
    public func fetch(key: String) throws -> Data? {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: serviceName,
            kSecReturnData: true,
        ] as NSDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.operation_error
        }
    }
    
    /// To get string from key
    /// - Parameter key: key
    /// - Throws: error
    /// - Returns: value
    public func string(for key: String) throws -> String? {
        guard let data = try fetch(key: key) else {
            return nil
        }
        return data.toString()
    }
    /// To delete the account with key
    /// - Parameter account: account
    /// - Throws: error
    func delete(key: String) throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: serviceName,
        ] as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
    /// To f
    /// To delete all the
    /// - Throws: error
    func deleteAll() throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
        ] as NSDictionary)
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
}
