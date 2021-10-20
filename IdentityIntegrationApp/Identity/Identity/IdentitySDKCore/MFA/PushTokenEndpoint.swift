//
//  PushTokenEndpoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 01/10/21.
//

import Foundation
import UIKit

/*
/// This class constructs the URL Request
/// Push token
///
*/

enum PushTokenHeader: String {
    case pushtoken = "ClientPushToken"
    case deviceid = "DeviceID"
    case vendorUdid = "vendorUdid"
    case pkgname = "pkgname"
    case internaldevicetype = "InternalDeviceType"
    case pSName = "OSName"
    case modelName = "ModelName"
    case modelNameLocalized = "ModelNameLocalized"
    case userInterfaceIdiom = "UserInterfaceIdiom"
    case MultitaskSupported = "MultitaskSupported"
    case product = "Product"
    case hwModel = "HWModel"
    case platformType = "PlatformType"
    case cPUFrequency = "CPUFrequency"
    case busFrequency = "BusFrequency"
    case cpuCount = "CPUCount"
    case totalMemory = "TotalMemory"
    case deviceCapacity = "DeviceCapacity"
    case macAddress = "MACAddress"
    case hasRetinaDisplay = "HasRetinaDisplay"
    case deviceFamily = "DeviceFamily"
    case deviceEnrollingReport = "DeviceEnrollingReport"
    case corporateOwnedSetByUser = "CorporateOwnedSetByUser"

    case jailbroken = "Jailbroken"
    case versionCode = "VersionCode"
    case versionName = "VersionName"
    case mobileManagerVersion = "MobileManagerVersion"
    case name = "Name"
    case osVersion = "OSVersion"
    case osBuild = "OSBuild"
    
    case vvailableDeviceCapacity = "AvailableDeviceCapacity"
    case userMemory = "UserMemory"
    case isAppLockedByAdmin = "IsAppLockedByAdmin"
    case adminAppLockedReason = "AdminAppLockedReason"
    case timeZone = "timeZone"
}
internal class PushTokenEndpoint {
    
    /// deviceToken configured in the server
    var token: Data? = nil

  
    init (token: Data) {
        self.token = token
    }
}
extension PushTokenEndpoint {
    
    /// To get the Refresh token
    /// - Parameters:
    ///   - code: code
    ///   - refreshToken: Refresh token
    /// - Returns: Endpoint
    func updateDeviceToken() -> Endpoint {
        
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
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: jsonData, queryItems: queryItems, dataType: .JSON, base: "https://acme2.my.dev.idaptive.app")
    }
}
