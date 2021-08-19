//
//  CyberArkAccountBuilder.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 16/08/21.
//

import Foundation
import UIKit

public class CyberarkAccount: NSObject {
    
    /// clientId configured in the server
    var clientId: String? = nil
    
    /// domain configured in the server
    var domain: String? = nil
    
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
    
    init (clientId: String, domain: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logoutUri: String, pkce: AuthOPKCE, presentingViewController: UIViewController) {
        self.clientId = clientId
        self.domain = domain
        self.scope = scope
        self.threshold = threshold
        self.applicationID = applicationID
        self.logoutUri = logoutUri
        self.redirectUri = redirectUri
        self.pkce = pkce
        self.presentingViewController = presentingViewController
    }
}
