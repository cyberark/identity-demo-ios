
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

public class Logger {
   
   static var name: String {
       get {
           var versionStr = ""
             if let version = Bundle.getVersion() {
               versionStr = "[\(version)]"
           }
           return "Identity-\(versionStr)"
       }
   }
   
    static func debugPrint<T>(_ message: String,_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        let value = object()
        let stringRepresentation: String
        
        if let value = value as? CustomDebugStringConvertible {
            stringRepresentation = value.debugDescription
        } else if let value = value as? CustomStringConvertible {
            stringRepresentation = value.description
        } else {
            stringRepresentation = "\(value)"
        }
        let fileURL = URL(string: file)?.lastPathComponent ?? "Unknown file"
        print("\(name): \(message)\(fileURL) \(function)[\(line)]: " + stringRepresentation)
        #endif
    }
}

/// To write the logs
