//
//  Codable+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 29/06/21.
//

import Foundation

extension Encodable {
  var toDictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
