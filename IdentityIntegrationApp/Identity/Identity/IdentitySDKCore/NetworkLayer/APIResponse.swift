//
//  APIResutl.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 25/06/21.
//

import Foundation


/// Generic response form api call
/// T on success
/// U on fail
public enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
