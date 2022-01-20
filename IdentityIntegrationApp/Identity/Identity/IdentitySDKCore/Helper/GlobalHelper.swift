
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

public enum UserDefaultsKeys: String {
    case isDeviceEnrolled        = "isDeviceEnrolled"
    case isBiometricOnAppLaunchEnabled       = "isEnabledBiometricOnAppLaunch"
    case isBiometricWhenAccessTokenExpiresEnabled       = "isEnabledBiometricOnAccessTokenExpires"
    case isBiometricOnQRLaunch       = "isBiometricOnQRLaunch"
    case isBiometricEnabledOnTransfeFunds       = "isBiometricEnabledOnTransfeFunds"

}
public func plistValues(bundle: Bundle, plistFileName: String) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, applicationID: String, systemurl: String, responseType: String, loginURL: String, widgetID: String, mfaTenantURL: String)? {
    var values: [String: Any] = [String: Any]()

    if UserDefaults.standard.getDict(key: "OAuthConfig") != nil {
        values = UserDefaults.standard.getDict(key: "OAuthConfig") ?? [String: Any]()
    } else if let path = bundle.path(forResource: plistFileName, ofType: "plist"),
              let info = NSDictionary(contentsOfFile: path) as? [String: Any] {
        values = info
    } else {
        print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
        return nil
    }
    guard
        let clientId = values["clientid"] as? String,
        let domain = values["domainoauth"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let applicationID = values["applicationid"] as? String, let systemurl = values["systemurl"] as? String, let responsetype = values["responsetype"] as? String, let loginURL =  values["loginurl"] as? String, let widgetID =  values["widgetid"] as? String, let mfaTenantURL =  values["mfatenanturl"] as? String
    else {
        print("IdentityConfiguration.plist file at \(bundle.path(forResource: plistFileName, ofType: "plist")) is missing 'ClientId' and/or 'Domain' values!")
        return nil
    }
    return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, applicationID: applicationID, systemurl: systemurl, responseType: responsetype, loginURL: loginURL, widgetID: widgetID, mfaTenantURL: mfaTenantURL)
}
