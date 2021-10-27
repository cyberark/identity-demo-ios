
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

import UIKit
import Identity
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    

    var notificationcompletionHandler: CheckNotificationResult? = nil
    private let categoryIdentifier = "MfaNotificationCategoryId"
    private let backGroundCategoryIdentifier = "MfaNotificationBackgroundCategoryId"
    private let kMfaNotificationApproveActionID = "MfaNotificationApproveActionId"
    private let kMfaNotificationDenyActionID = "MfaNotificationDenyActionId"
    private let kMfaNotificationBackgroundApproveActionID = "MfaNotificationBackgroundApproveActionId"
    private let MfaNotificationBackgroundDenyActionId = "MfaNotificationBackgroundDenyActionId"

    let mfaProvider = MFAChallengeProvider()

    private enum NotificationActionIdentifier: String {
        case accept = "MfaNotificationApproveActionId", reject = "MfaNotificationDenyActionId"
    }
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        addMFAObserver()

        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate {
    func registerPushNotifications() {
        let application = UIApplication.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .badge, .sound, .alert
        ]) { granted, _ in
            guard granted else { return }
            self.registerCustomActions()
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    func unregisterPushNotifications() {
        let application = UIApplication.shared
        application.unregisterForRemoteNotifications()
    }
    private func registerCustomActions() {
        let accept = UNNotificationAction(
            identifier: kMfaNotificationApproveActionID,
            title: "Approve",options: UNNotificationActionOptions(rawValue: 0))
        
        let reject = UNNotificationAction(
            identifier: kMfaNotificationDenyActionID,
            title: "Deny",options: UNNotificationActionOptions(rawValue: 0))
        
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [accept, reject],
            intentIdentifiers: [],options: .customDismissAction)
        
        
        let accept_background = UNNotificationAction(
            identifier: kMfaNotificationBackgroundApproveActionID,
            title: "Approve")
        
        let reject_background = UNNotificationAction(
            identifier: kMfaNotificationBackgroundApproveActionID,
            title: "Deny")
        
        let backgroundCategory = UNNotificationCategory(
            identifier: backGroundCategoryIdentifier,
            actions: [accept_background, reject_background],
            intentIdentifiers: [],options: .customDismissAction)

        UNUserNotificationCenter.current()
            .setNotificationCategories([category, backgroundCategory])
    }
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data) {
            CyberArkAuthProvider.handlePushToken(token: deviceToken)
            //registerCustomActions()
        }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if UIApplication.shared.applicationState == .active {
            Notification.Name.handleNotification.post(userInfo: userInfo)
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active {
            let userInfo = notification.request.content.userInfo
            Notification.Name.handleNotification.post(userInfo: userInfo)
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
                                @escaping () -> Void) {
        
        notificationcompletionHandler = completionHandler
        let identity = response.notification
            .request.content.categoryIdentifier
        let userInfo = response.notification.request.content.userInfo

        guard identity == categoryIdentifier,
              let action = NotificationActionIdentifier(rawValue: response.actionIdentifier) else {
                  //if UIApplication.shared.applicationState == .active {
                      Notification.Name.handleNotification.post(userInfo: userInfo)
                        completionHandler()
                 // }
                  return
              }
        
        switch action {
        case .accept:
            self.performChallengeby(isAccepted: true, userInfo: userInfo, withCompletionHandler:
                                        nil)
            //Notification.Name.acceptButton.post(userInfo: userInfo)
        case .reject:
            self.performChallengeby(isAccepted: false, userInfo: userInfo, withCompletionHandler:
                                        nil)
            //Notification.Name.rejectButton.post(userInfo: userInfo)
        }
        
    }
}
extension AppDelegate {
    
    func performChallengeby(isAccepted: Bool, userInfo: [AnyHashable : Any]? = nil, withCompletionHandler completionHandler:
                            CheckNotificationResult? ){
        let userInfo = userInfo?["payload"] as! [AnyHashable: Any]
        let info = userInfo["Options"] as! [AnyHashable: Any]
        let challenge =  info["ChallengeAnswer"]
        handleChallange(isAccepted: isAccepted, challenge: challenge as! String, withCompletionHandler: completionHandler)
    }
    /// To approve the mfa the device
    func handleChallange(isAccepted: Bool, challenge: String, withCompletionHandler completionHandler:
                         CheckNotificationResult?) {
        do {
            guard let config = plistValues(bundle: Bundle.main) else { return }
            mfaProvider.handleMFAChallenge(isAccepted: isAccepted, challenge: challenge, baseURL: config.domain, withCompletionHandler: completionHandler)
        } catch  {
        }
    }
  
    /*
    ///
    /// Observer to get the enrollment status
    /// Must call this method before calling the enroll api
    */
    func addMFAObserver(){
        mfaProvider.didReceiveMFAApiResponse = { (result, accessToken) in
            if result {
            }else {
            }
            if let handler = self.notificationcompletionHandler {
                handler()
            }
        }
    }
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String,systemurl: String)? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String, let systemurl = values["systemurl"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, threshold: threshold, applicationID: applicationID, logouturi: logouturi, systemurl: systemurl)
    }
}

extension Notification.Name {

    static let handleNotification = Notification.Name("handleNotification")
    static let acceptButton = Notification.Name("acceptTapped")
    static let rejectButton = Notification.Name("rejectTapped")
    
    func post(
        center: NotificationCenter = NotificationCenter.default,
        object: Any? = nil,
        userInfo: [AnyHashable : Any]? = nil) {
        
        center.post(name: self, object: object, userInfo: userInfo)
    }
    
    @discardableResult
    func onPost(
        center: NotificationCenter = NotificationCenter.default,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using: @escaping (Notification) -> Void)
    -> NSObjectProtocol {
        
        return center.addObserver(
            forName: self,
            object: object,
            queue: queue,
            using: using)
    }
}
