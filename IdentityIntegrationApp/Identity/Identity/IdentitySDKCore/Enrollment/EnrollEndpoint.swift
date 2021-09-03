
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

internal enum EnrollHeader: String {
    case osversion = "OSVersion"
    case name = "Name"
    case udid = "Udid"
}
/*
/// This class constructs Enroll URL Request
/// Enrollment endoint
///
 */
internal class EnrollEndPoint {
    /// udid of the device
    var udid: String? = nil
    /// name
    var name: String? = nil
    /// os version
    var osversion: String? = nil
}
extension EnrollEndPoint {

    /// To get the enroll device token
    /// - Parameters:
    ///   - code: code
    ///   - acesstoken: Refresh token
    /// - Returns: Endpoint
    func getEnrollDeviceEndpoint(accesstoken: String, baseURL: String) -> Endpoint {
        let udid =  DeviceManager.shared.getUUID()
        let modelName = UIDevice.modelName
        let osversion = UIDevice.iOSVersion
        let post = [
            EnrollHeader.osversion.rawValue: osversion,
            EnrollHeader.name.rawValue: modelName,
            EnrollHeader.udid.rawValue: udid
        ]
        let jsonData = post.jsonData

        let queryItems = [URLQueryItem]()

        var headers: [String: String] = [:]
        let accessToken = "Bearer \(accesstoken)"
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.authorization.rawValue] = accessToken
        headers[HttpHeaderKeys.xcentrifynativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"

        let path = "/Device/EnrollIosDevice"
        
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
