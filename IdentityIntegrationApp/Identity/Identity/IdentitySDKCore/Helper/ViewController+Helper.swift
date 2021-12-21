
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

public extension UIViewController {
    static func initFromNib() -> Self {
         func instanceFromNib<T: UIViewController>() -> T {
             return T(nibName: String(describing: self), bundle: nil)
         }
         return instanceFromNib()
     }
     class func loadFromNib<T: UIViewController>() -> T {
         return T(nibName: String(describing: self), bundle: nil)
     }
    class func loadFromNib() -> Self {
            func instantiateFromNib<T: UIViewController>() -> T {
                let frameworkBundleID  = "com.cyberark.Identity"
                let bundle = Bundle(identifier: frameworkBundleID)
                return T.init(nibName: String(describing: T.self), bundle: bundle)
            }

            return instantiateFromNib()
        }
    func present(_ viewControllerToPresent: UIViewController, completion: @escaping (() -> ())) {
        present(viewControllerToPresent, animated: true, completion: completion)
    }

    func present(_ viewControllerToPresent: UIViewController) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        present(viewControllerToPresent, animated: true, completion: nil)
    }

    func presentTranslucent(_ viewController: UIViewController, modalTransitionStyle: UIModalTransitionStyle = .coverVertical, animated flag: Bool = true, completion: (() -> ())? = nil) {
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle =  modalTransitionStyle
        view.window?.rootViewController?.modalPresentationStyle = .currentContext
        present(viewController, animated: flag, completion: completion)
    }
    func push(_ viewController: UIViewController) {
        navigationController?.show(viewController, sender: self)
    }

    func pop(animated: Bool = true) {
        //if let presentingViewController = presentingViewController {
       //     presentingViewController.dismiss(animated: animated, completion: nil)
       // } else {
            _ = navigationController?.popViewController(animated: animated)
        //}
    }
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = navigationController?.viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            navigationController?.popToViewController(vc, animated: animated)
      }
    }

    func popToRoot(animated: Bool = true) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: animated, completion: nil)
        } else {
            _ = navigationController?.popToRootViewController(animated: animated)
        }
    }
    func dismiss(completion: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }

}
extension UIViewController {
   public func showAlert(with title: String? = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    static func showAlertOnRootView(with presenter: UIViewController? = UIApplication.shared.windows.last?.rootViewController,
                                    title: String? = "",
                                    message: String) {
        DispatchQueue.main.async {
            presenter?.showAlert(with: title, message: message)
        }
     }
}

public extension UIApplication {

    class func getTopMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
}
