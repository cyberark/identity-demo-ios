
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
import UIKit

/*
/// CyberarkAccount
/// This is created for account.
///  Safari controller
/// - webType: type of  the browser
/// - customParam: as custom parameters
/// - oAuthEndPoint: url components
/// - presentingViewController: presentingViewController
*/

public class CyberarkAccount: NSObject {
    
    /// clientId configured in the server
    var clientId: String? = nil
    
    /// domain configured in the server
    var domain: String? = nil
    
    /// domain configured in the server
    var systemURL: String? = nil

    /// scope configured in the server
    var scope: String? = nil
    
    /// redirectUri configured in the server
    var redirectUri: String? = nil
    
    /// threshold configured in the server
    var threshold: Int? = 60
    
    /// applicationID configured in the server
    var applicationID: String? = nil
    
    /// logoutUri configured in the server
    var logoutUri: String? = nil
    
    /// logoutUri configured in the server
    var customParam: [String: String] = [:]
    
    var presentingViewController: UIViewController?

    /// pkce configured
    var pkce: AuthOPKCE?
    
    lazy var verifier: String? = {
        return self.pkce?.verifier
    } ()
    lazy var challenge: String? = {
        return self.pkce?.challenge
    } ()
    
    init (clientId: String, domain: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logoutUri: String, pkce: AuthOPKCE, presentingViewController: UIViewController, systemURL: String) {
        self.clientId = clientId
        self.domain = domain
        self.systemURL = domain
        self.scope = scope
        self.threshold = threshold
        self.applicationID = applicationID
        self.logoutUri = logoutUri
        self.redirectUri = redirectUri
        self.pkce = pkce
        self.presentingViewController = presentingViewController
    }
}
