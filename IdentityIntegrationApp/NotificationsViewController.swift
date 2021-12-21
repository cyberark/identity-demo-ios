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
import Identity

class NotificationsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var content_label: UILabel!
    @IBOutlet weak var approve_button: UIButton!
    @IBOutlet weak var deny_button: UIButton!

    var pushUserInfo = [AnyHashable : Any]()

    let mfaProvider = MFAChallengeProvider()

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}
//MARK:- Initial configuration
extension NotificationsViewController {
    func configure(){
        addMFAObserver()
        configureNotificationData()
        showActivityIndicator(on: self.view)
        self.navigationItem.setHidesBackButton(true, animated: true)
        approve_button.layer.cornerRadius = 15
        approve_button.layer.masksToBounds = true
        deny_button.layer.cornerRadius = 15
        deny_button.layer.masksToBounds = true

    }
    func configureNotificationData(){
        let userInfo = pushUserInfo["payload"] as! [AnyHashable: Any]
        let info = userInfo["Options"] as! [AnyHashable: Any]
        let message =  "\(info["Message"] as! String)"
        content_label.text = message
    }
}

extension NotificationsViewController {
    
    @IBAction func approve_click(_ sender: Any) {
        performChallengeby(isAccepted: true)
    }
    
    @IBAction func reject_click(_ sender: Any) {
        performChallengeby(isAccepted: false)
    }
    func performChallengeby(isAccepted: Bool){
        let userInfo = pushUserInfo["payload"] as! [AnyHashable: Any]
        let info = userInfo["Options"] as! [AnyHashable: Any]
        let challenge =  info["ChallengeAnswer"]
        handleChallange(isAccepted: isAccepted, challenge: challenge as! String)
    }
    /// To approve the mfa the device
    func handleChallange(isAccepted: Bool, challenge: String) {
        activityIndicator.startAnimating()
        guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
        mfaProvider.handleMFAChallenge(isAccepted: isAccepted, challenge: challenge, baseURL: config.domain, withCompletionHandler: nil)
    }
  
    /*
    ///
    /// Observer to get the MFA status
    /// Must call this method before calling the MFA api
    */
    func addMFAObserver(){
        mfaProvider.didReceiveMFAApiResponse = { (result, message) in
            if result {
                self.navigationController?.popViewController(animated: true)
            }else {
                self.showAlert(message: message)
            }
            self.activityIndicator.stopAnimating()
        }
    }
}
//MARK:- activity indicator
extension NotificationsViewController {
    func showActivityIndicator(on parentView: UIView) {
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
        ])
    }
}
