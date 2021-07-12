//
//  Logger.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//

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
