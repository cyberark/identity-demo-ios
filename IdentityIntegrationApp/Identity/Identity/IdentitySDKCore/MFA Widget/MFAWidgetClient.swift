//
//  MFAWidgetClient.swift
//  Identity
//
//  Created by Mallikarjuna Punuru on 17/01/22.
//

import Foundation


/*
/// LoginClientProtocol
/// Protocol for getting the login authentication
///
 */
/// <#Description#>
protocol MFAWidgetClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: <#baseURL description#>
    ///   - userName: <#userName description#>
    ///   - password: <#password description#>
    ///   - completion: <#completion description#>
    func launchMFAWidget(baseURL: String, userName: String, widgetID: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void)
}
/*
/// LoginClient
///
///
 */
class MFAWidgetClient: APIClient {
    
    /// url session
    let session: URLSession
    
    /// initializer
    /// - Parameter configuration: configuration
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    /// initializer
    convenience init() {
        self.init(configuration: .default)
    }
}
// MARK: - API Request calls
extension MFAWidgetClient: MFAWidgetClientProtocol {
    
    /// Handle login
    /// - Parameters:
    ///   - baseURL: <#baseURL description#>
    ///   - userName: <#userName description#>
    ///   - password: password description
    ///   - completion: <#completion description#>
    func launchMFAWidget(baseURL: String, userName: String, widgetID: String, completion: @escaping (Result<LoginResponse?, APIError>) -> Void) {
        let endpoint: Endpoint = MFAWidgetEndpoint().getWidgetEndpoint(baseURL: baseURL, userName: userName, widgetID: widgetID)
        let request = endpoint.request
        fetch(with: request, decode: { json -> LoginResponse? in
            guard let acccessToken = json as? LoginResponse else { return  nil }
            return acccessToken
        }, completion: completion)
        
    }
}
