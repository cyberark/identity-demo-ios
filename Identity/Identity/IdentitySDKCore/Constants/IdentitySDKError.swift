//
//  CIAMSDKErro.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 02/07/21.
//

import Foundation

/// Base Error
///
///
public protocol IdentityError: Error {
}

/// Represents  SDK errors
public enum IdentitySDKError: IdentityError {
    case emptyConfiguration
    case invalidConfiguration
    case requestFailed
    case invalidData
    case invalidurl
    case unknownError
    var localizedDescription: String {
        switch self {
        case .emptyConfiguration: return "Invalid configuration: configuration Dictionary is missing"
        case .invalidConfiguration: return "Invalid Configuration"
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .invalidurl: return "Invalid URL"
        case .unknownError: return "Unknown Error"
        }
    }
}
/// Represents  OAtuh errors
public enum IdentityOAuthError: IdentityError {
    case oAuth_invalidRequest(String?)
    case oAuth_invalid(String?)
    case oAuth_invalidGrant(String?)
    case oAuth_unauthorized(String?)
    case oAuth_unsupportedGrantType(String?)
    case oAuth_unsupportedResponseType(String?)
    case oAuth_invalidScope(String?)
    case oAuth_missingOrInvalidRedirectURI(String?)
    case oAuth_accessDenied(String?)
    case oAuth_invalidPKCEState
    case unknown
    var localizedDescription: String {
        switch self {
        case .oAuth_invalidRequest(let value):
            return "Invalid request: \(String(describing: value))"
        case .oAuth_invalid(let value):
            return "Invalid request: \(String(describing: value))"
        case .oAuth_invalidGrant(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_unauthorized(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_unsupportedGrantType(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_unsupportedResponseType(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_invalidScope(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_missingOrInvalidRedirectURI(let value):
            return "Invalid credentials: \(String(describing: value))"
        case .oAuth_accessDenied(let value):
            return "unauthorized request: \(String(describing: value))"
        case .oAuth_invalidPKCEState:
            return "Invalid credentials: invalid PKCE state"
        case .unknown:
            return "Unknown error"
        }
    }
}

/// Respresents Browser Errors
public enum CyberArkBrowserError: IdentityError {
    case failure
    case inprogress
    case cancelled
    var localizedDescription: String {
        switch self {
        case .failure:
            return "External failure"
        case .inprogress:
            return "The operation is progress"
        case .cancelled:
            return "User Cancelled the operation"
        }
    }

}

