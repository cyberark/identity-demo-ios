//
//  ViewController+Helper.swift
//  CIAMSDK
//
//  Created by Mallikarjuna Punuru on 09/07/21.
//

import Foundation
import UIKit

extension UIViewController {
    class func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            let frameworkBundleID  = "com.cyberark.Identity"
            let bundle = Bundle(identifier: frameworkBundleID)
            return T.init(nibName: String(describing: T.self), bundle: bundle)
        }

        return instantiateFromNib()
    }
}
extension UIViewController {
   public func showAlert(with title: String? = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    static func showAlertOnRootView(with title: String? = "", message: String) {
        let rootViewController = UIApplication.shared.windows.last?.rootViewController
        rootViewController?.showAlert(with: title, message: message)
         
     }
}
