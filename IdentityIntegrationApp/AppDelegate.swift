
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
    
    private let categoryIdentifier = "MfaNotificationCategoryId"
    private let backGroundCategoryIdentifier = "MfaNotificationBackgroundCategoryId"
    private let kMfaNotificationApproveActionID = "MfaNotificationApproveActionId"
    private let kMfaNotificationDenyActionID = "MfaNotificationDenyActionId"
    private let kMfaNotificationBackgroundApproveActionID = "MfaNotificationBackgroundApproveActionId"
    private let MfaNotificationBackgroundDenyActionId = "MfaNotificationBackgroundDenyActionId"

    private enum ActionIdentifier: String {
        case accept = "Approve", reject = "Deny"
    }
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
        UNUserNotificationCenter.current().delegate = self
        let application = UIApplication.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .badge, .sound, .alert
        ]) { granted, _ in
            guard granted else { return }
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
            title: "Approve")
        
        let reject = UNNotificationAction(
            identifier: kMfaNotificationDenyActionID,
            title: "Deny")
        
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [accept, reject],
            intentIdentifiers: [])
        
        
        let accept_background = UNNotificationAction(
            identifier: kMfaNotificationBackgroundApproveActionID,
            title: "Approve")
        
        let reject_background = UNNotificationAction(
            identifier: kMfaNotificationBackgroundApproveActionID,
            title: "Deny")
        
        let backgroundCategory = UNNotificationCategory(
            identifier: backGroundCategoryIdentifier,
            actions: [accept_background, reject_background],
            intentIdentifiers: [])

        UNUserNotificationCenter.current()
            .setNotificationCategories([category, backgroundCategory])
    }
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data) {
            CyberArkAuthProvider.handlePushToken(token: deviceToken)
            registerCustomActions()
        }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if UIApplication.shared.applicationState == .active {
            Notification.Name.handleNotification.post(userInfo: userInfo)

        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
                                @escaping () -> Void) {
        let identity = response.notification
            .request.content.categoryIdentifier
        guard identity == categoryIdentifier,
              let action = ActionIdentifier(rawValue: response.actionIdentifier) else {
            return
        }
        let userInfo = response.notification.request.content.userInfo
        
        switch action {
        case .accept:
            Notification.Name.acceptButton.post(userInfo: userInfo)
        case .reject:
            Notification.Name.rejectButton.post(userInfo: userInfo)
        }
        completionHandler()
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
