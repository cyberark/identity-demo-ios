
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
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        configureInitialScreen(windowScene: windowScene)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

extension SceneDelegate {
    
    /// CyberArkAuthProvider resume operations
    /// - Parameters:
    ///   - scene: scene
    ///   - URLContexts: context
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            process(with: context.url)
        }
    }
    
    /// OAUth based result
    /// - Parameter url: context URL
    func process(with url: URL) {
        CyberArkAuthProvider.resume(url: url)
    }
}

extension SceneDelegate {
    
    /// To configure root view controller
    /// - Parameter windowScene: window scene
    func configureInitialScreen(windowScene: UIWindowScene) {
        do {
            UINavigationBar.appearance().backgroundColor = UIColor.hexToUIColor(hex: "#192436")
            UINavigationBar.appearance().barTintColor = UIColor.hexToUIColor(hex: "#192436")
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white,
                                                                .font : UIFont.boldSystemFont(ofSize: 16.0)]
            
            let story = UIStoryboard(name: "Main", bundle:nil)
            var vc: UIViewController = UIViewController()
            if (try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue)) != nil {
                vc = story.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            }else {
                vc = story.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            }
            let window = UIWindow(windowScene: windowScene)
            let navController = UINavigationController.init(rootViewController: vc)
            window.rootViewController = navController
            self.window = window
            window.makeKeyAndVisible()
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
