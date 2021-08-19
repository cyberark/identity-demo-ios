//
//  DeviceManager.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 12/08/21.
//
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


/// This class manages the ddevice related infirmation
public class DeviceManager {
    
    static var shared = DeviceManager()

    private init() {}
    
    //Creates a new unique user identifier or retrieves the last one created
    public func getUUID() -> String? {
        
        // this is the key we'll use to store the uuid in the keychain
        let uuidKey = "com.cyberark.Identity.uniquedeviceudid"

        // check if we already have a uuid stored, if so return it
        if let uuid = try? KeyChainWrapper.standard.string(for: uuidKey) {
            return uuid
        }

        // generate a new id
        guard let newIdentifier = UIDevice.identifier else {
            return nil
        }

        // store new identifier in keychain
        try? KeyChainWrapper.standard.save(key: uuidKey, data: newIdentifier.toData() ?? Data())

        // return new id
        return newIdentifier
    }
}
