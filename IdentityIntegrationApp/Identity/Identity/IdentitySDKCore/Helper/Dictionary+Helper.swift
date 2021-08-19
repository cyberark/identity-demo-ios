//
//  Dictionary+Helper.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 13/08/21.
//

import Foundation

extension Dictionary {
    
    var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch let error as NSError {
            debugPrint("Unable to parse the JSON : The error: \(error)")
            return nil
        }
    }
}
