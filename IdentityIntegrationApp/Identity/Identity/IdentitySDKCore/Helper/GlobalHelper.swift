
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
}
public func plistValues(bundle: Bundle, plistFileName: String) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String,systemurl: String)? {
    guard
        let path = bundle.path(forResource: plistFileName, ofType: "plist"),
        let values = NSDictionary(contentsOfFile: path) as? [String: Any]
    else {
        print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
        return nil
    }
    guard
        let clientId = values["clientid"] as? String,
        let domain = values["domain"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String, let systemurl = values["systemurl"] as? String
    else {
        print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
        return nil
    }
    return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, threshold: threshold, applicationID: applicationID, logouturi: logouturi, systemurl: systemurl)
}
