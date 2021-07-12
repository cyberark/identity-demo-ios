//
//  KeychainManager.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 06/07/21.
//

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
enum KeyChainStorageKeys: String {
    case accessToken = "access_token"
    case grantCode = "grant_code"
    case refreshToken = "refresh_code"
    case access_token_expiresIn = "access_token_expiresIn"

}
/// Keychain Wrapper
///  Wrapper to store the credentials in secure way
///
public class KeyChainWrapper{
    
    public static let standard = KeyChainWrapper()

    private (set) public var serviceName: String = {
       return "OAuth"
    }()
    
    private (set) public var accessGroup: String = {
        return Bundle.main.bundleIdentifier ?? "com.cyberark.Identity"
    }()
    
    private init() {
    }
    
    public func save(key: String, data: Data) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: serviceName,
            //kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: data,
        ] as NSDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
    
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
    /**
     Function to delete a single item
     - parameters:
     - account: Account name for keychain item
     */
    func delete(account: String) throws {
        /// Status for the query
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: serviceName,
        ] as NSDictionary)
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
    
    /**
     To delete all items for the app
     */
    func deleteAll() throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
        ] as NSDictionary)
        guard status == errSecSuccess else { throw KeychainError.operation_error }
    }
}
