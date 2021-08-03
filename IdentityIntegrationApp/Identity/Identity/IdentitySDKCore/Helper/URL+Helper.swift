//
//  URL+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 06/07/21.
//

import Foundation
extension URL {
    
    /// Finds the Query parameter
    /// - Parameter param: param
    /// - Returns: corresponding parameter value
    public func queryParameter(with param: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
