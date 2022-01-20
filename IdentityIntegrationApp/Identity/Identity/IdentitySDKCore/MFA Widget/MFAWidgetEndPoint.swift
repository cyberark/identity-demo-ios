//
//  MFAWidgetEndPoint.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 17/01/22.
//

import Foundation

enum MFAWidgetEndpointHeader: String {
    case username = "username"
    case widgetID = "id"
}
internal class MFAWidgetEndpoint {
    
    init () {
    }
}
extension MFAWidgetEndpoint {
        
    /// Login Endpoint
    /// - Parameters:
    ///   - sessionToken: sessionToken description
    ///   - baseURL: baseURL description
    ///   - userName: userName description
    ///   - password: password description
    /// - Returns: Endpoint
    func getWidgetEndpoint(baseURL: String, userName: String, widgetID: String) -> Endpoint {
        let queryItems = [URLQueryItem(name: MFAWidgetEndpointHeader.widgetID.rawValue, value: widgetID), URLQueryItem(name: MFAWidgetEndpointHeader.username.rawValue, value: userName)]
        var headers: [String: String] = [:]
        headers[HttpHeaderKeys.contenttype.rawValue] = "application/json"
        headers[HttpHeaderKeys.xidpnativeclient.rawValue] = "true"
        headers[HttpHeaderKeys.acceptlanguage.rawValue] = "en-IN"
        let path = "//Authenticationwidgets/WidgetPage"
        return Endpoint(path:path, httpMethod: .post, headers: headers, body: nil, queryItems: queryItems, dataType: .JSON, base: baseURL)
    }
}
