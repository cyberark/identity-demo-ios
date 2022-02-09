
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
/*
/// MFAProviderProtocol
/// Class resposible for MFA entry Point
/// A Protocol for th MFAProviderProtocol
 */

public protocol MFAWidgetProviderProtocol {
    /*
    /// handleMFAChallenge
    /// - Parameter baseURL: base URL
     */
    func launchMFAWidget(userName: String, widgetID: String, baseURL: String, presentingViewconstroller: UIViewController, withCompletionHandler completionHandler:
                   CheckNotificationResult?)
    /*
    /// Callback when MFA is done
    /// Handler for the enrollment api response
     */
    var didReceiveApiResponse: ((Bool) -> Void)? { get set}

}
/*
/// A class resposible for Enrollment entry Point
 */
public class MFAWidgetProvider: MFAWidgetProviderProtocol {
    
    /// callback when enrollmentt is done
    public var didReceiveApiResponse: ((Bool) -> Void)?
 
    public init() {
        
    }
    
}
//MARK:-
extension MFAWidgetProvider {
   
    public func launchMFAWidget(userName: String, widgetID: String, baseURL: String, presentingViewconstroller: UIViewController, withCompletionHandler completionHandler:
                     CheckNotificationResult?) {
        launchBrowser(userName: userName, widgetID: widgetID, baseURL: baseURL, presentingViewconstroller: presentingViewconstroller)
    }
}
//MARK:- Authentication and Autherization
extension MFAWidgetProvider {
    /// Browser
    /// - Parameter account: CyberarkAccount with the required parameters
    public func launchBrowser(userName: String, widgetID: String, baseURL: String, presentingViewconstroller: UIViewController){
        let endpoint: Endpoint = MFAWidgetEndpoint().getWidgetEndpoint(baseURL: baseURL, userName: userName, widgetID: widgetID)
        let request = endpoint.request
        let mfaWidgetViewController = MFAWidgetViewController.loadFromNib()
        mfaWidgetViewController.webRequest = request
        presentingViewconstroller.push(mfaWidgetViewController)
        mfaWidgetViewController.didRecieveResponse = { [weak self] (status) in
            if(status) {
                self?.didReceiveApiResponse!(status)
            }
        }
    }
   
}
