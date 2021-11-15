
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
/// This class constructs the URL Request
/// Push token
///
*/

enum PushTokenHeader: String {
    case name = "Name"
    case osVersion = "OSVersion"
    case pushtoken = "ClientPushToken"
    case deviceid = "DeviceID"
    case pkgname = "pkgname"

}
internal class PushTokenEndpoint {
    
    /// deviceToken configured in the server
    var token: Data? = nil

  
    init (token: Data) {
        self.token = token
    }
}
extension PushTokenEndpoint {
    
    /// To update the device token
    /// - Parameters:
    /// - Returns: Endpoint
    func updateDeviceToken(baseURL: String) -> Endpoint {
        
        let udid =  DeviceManager.shared.getUUID()
        let modelName = UIDevice.modelName
        let osversion = UIDevice.iOSVersion
        //let bundleVersion =  Bundle.getVersion()
        let bundleIdentifier =  Bundle.getBundleIdentifier()

        let post = [
            PushTokenHeader.osVersion.rawValue: osversion,
            PushTokenHeader.name.rawValue: modelName,
            PushTokenHeader.deviceid.rawValue: udid,
            PushTokenHeader.pushtoken.rawValue: self.token?.base64EncodedString(),
            //PushTokenHeader.mobileManagerVersion.rawValue: bundleVersion,
            PushTokenHeader.pkgname.rawValue: bundleIdentifier
        ]
        let jsonData = post.jsonData
        
        let queryItems = [URLQueryItem]()
        
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"
        do {
            if let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue), let accessToken = data.toString()  {
                let accessToken = "Bearer \(accessToken)"
                headers[HttpHeaderKeys.authorization.rawValue] = accessToken
            }
        } catch  {
        }
        
        let path = "/IosAppRest//UpdateDevSettings"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
