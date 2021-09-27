
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
import LocalAuthentication

/*
/// LAContextProtocol
/// Class resposible for biometrics
/// A Protocol for the biometrics
 */
public protocol LAContextProtocol {
    func canEvaluatePolicy(_ : LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
}
/*
/// BiometricError
/// Class resposible for OAuth entry Point
/// Shared instance
/// A Protocol for th EnrollmentProvider
 */
public enum BiometricError: LocalizedError {
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    public var errorDescription: String {
        switch self {
        case .authenticationFailed: return "There was a problem verifying your identity."
        case .userCancel: return "You pressed cancel."
        case .userFallback: return "You pressed password."
        case .biometryNotAvailable: return "Face ID/Touch ID is not available."
        case .biometryNotEnrolled: return "Face ID or Touch ID is not configured."
        case .biometryLockout: return "Face ID/Touch ID is locked."
        case .unknown: return "Face ID/Touch ID may not be configured"
        }
    }
}

final public class BiometricsAuthenticator {
    let context: LAContextProtocol
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    public init(context: LAContextProtocol = LAContext(),
                policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: String = "Verify your Identity") {
        self.context = context
        self.policy = policy
        self.localizedReason = localizedReason
    }
    
    public func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(self.policy, error: nil)
    }
    
    public func authenticateUser(completion: @escaping (Result<Bool, BiometricError>) -> Void) {
        guard canEvaluatePolicy() else {
            completion( .failure(BiometricError.biometryNotEnrolled))
            return
        }
        
        let reason = "Identify yourself to continue"
        context.evaluatePolicy(self.policy, localizedReason: reason) { [weak self] (success, evaluateError) in
            if success {
                // User authenticated successfully
                print("Success")
                DispatchQueue.main.async {
                    completion(.success(success))
                }
                
            } else {
                // User authenticated failed
                guard let error = evaluateError else {
                    completion( .failure(BiometricError.unknown))
                    return
                }
                completion(.failure(self?.biometricError(from: error) ?? BiometricError.unknown))
            }
        }
    }
    
    private func biometricError(from laError: Error) -> BiometricError {
        let error: BiometricError
        
        switch laError {
        case LAError.authenticationFailed:
            error = .authenticationFailed
        case LAError.userCancel:
            error = .userCancel
        case LAError.userFallback:
            error = .userFallback
        case LAError.biometryNotAvailable:
            error = .biometryNotAvailable
        case LAError.biometryNotEnrolled:
            error = .biometryNotEnrolled
        case LAError.biometryLockout:
            error = .biometryLockout
        default:
            error = .unknown
        }
        
        return error
    }
}

extension LAContext: LAContextProtocol{
    
}
