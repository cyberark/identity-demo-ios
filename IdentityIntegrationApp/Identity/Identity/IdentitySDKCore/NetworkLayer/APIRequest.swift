//
//  APIRequest.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 28/06/21.
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

/// A classic class object for each kind of request.
/// Define parameters to pass along with the request and how
/// they are encapsulated into the http request itself.
///
/// - body: part of the body stream
/// - url: as url parameters

internal struct Endpoint {
    
    /// Relative path of the endpoint we want to call
    var path: String?
    
    /// This define the HTTP method we should use to perform the call
    /// We have defined it inside an String based enum called `HTTPMethod`
    /// just for clarity
    var httpMethod: HTTPMethod
    
    /// These are the parameters we need to send along with the call.
    /// Params can be passed into the body or along with the URL
    var headers: HTTPHeaders?
    
    /// body to pass along with each request.
    var body: Data?
    
    /// Each URLQueryItem represents a single key-value pair,
    var queryItems: [URLQueryItem]?
    
    /// What kind of data we expect as response
    var dataType: DataType

    /// Base URL
    var base: String? = APIRequestConstants.ciamDevURL

}

extension Endpoint {
    
    /// This structure parses and constructs URLs according to RFC 3986. Its behavior differs subtly from that of the URL structure, which conforms to older RFCs. However, you can easily obtain a URL value based on the contents of a URLComponents value or vice versa.
    var urlComponents: URLComponents {
        let base: String = self.base ?? ""
        var component = URLComponents(string: base)!
        if path != nil {
            component.path = path ?? ""
        }
        if queryItems?.count ?? 0 > 0{
            component.queryItems = queryItems
        }
        return component
    }
    
    /// A URL load request that is independent of protocol or URL scheme.
    var request: URLRequest {
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod  = httpMethod.rawValue
        request.httpBody    = body
        if  let headers = headers {
            for(headerField, headerValue) in headers {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        //request.httpShouldHandleCookies = true
        return request
    }
}
