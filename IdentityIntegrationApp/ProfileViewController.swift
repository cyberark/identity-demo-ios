
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

class ProfileViewController: UIViewController {

    @IBOutlet weak var authTime_label: UILabel!
    @IBOutlet weak var givenName_label: UILabel!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var email_label: UILabel!
    @IBOutlet weak var familyName_label: UILabel!
    @IBOutlet weak var preferredName_label: UILabel!
    @IBOutlet weak var uniqueName_label: UILabel!
    @IBOutlet weak var emailVerification_label: UILabel!

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK: Weblogin
extension ProfileViewController {
    func config() {
        authTime_label.text = ""
        givenName_label.text = ""
        name_label.text = ""
        email_label.text = ""
        familyName_label.text = ""
        preferredName_label.text = ""
        uniqueName_label.text = ""
        email_label.text = ""
        emailVerification_label.text = ""
        showActivityIndicator(on: self.view)

        addObserver()
        fetchUserInfo()

    }
    /*
    /// Invokes the Login
    /// Launches the extrenal safari view controller based on the configuration
    /// Setup the initial tenant configuration required
    /// setup Custom browser Parameters
    ///
    */
    func fetchUserInfo() {
        if Reachability.isConnectedToNetwork() {
            activityIndicator.startAnimating()
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
            //CyberarkAccount
            guard let account =  CyberArkAuthProvider.webAuth()?
                    .set(clientId: config.clientId)
                    .set(domain: config.domain)
                    .set(redirectUri: config.redirectUri)
                    .set(applicationID: config.applicationID)
                    .set(presentingViewController: self)
                    .setCustomParam(key: "", value: "")
                    .set(scope: config.scope)
                    .set(webType: .sfsafari)
                    .set(systemURL: config.systemurl)
                    .build() else { return }

            CyberArkAuthProvider.fetchUserInfo()
        } else {
            showAlert(with: "Network issue", message: "Please connect to the the internet")
        }
       
    }
    /*
    ///
    /// Observer to get the access token
    /// Must call this method before calling the login api
    */
    func addObserver(){
        CyberArkAuthProvider.didReceiveUserInfo = { (status, message, response) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if status {
                    self.setup(info: response)
                } else {
                    self.showAlert(message: message)
                }
            }
            
        }
    }
    
    /// To save the data in the keychain
    /// - Parameter response: token response
    func setup(info: UserInfo?) {
        if let authTime = info?.auth_time {
            let dateVar = Date.init(timeIntervalSinceNow: TimeInterval(authTime)/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
            
            authTime_label.text = dateFormatter.string(from: dateVar)
        }
        if let givenName = info?.given_name {
            givenName_label.text = givenName
        }
        if let name = info?.name {
            name_label.text = name
        }
        if let email = info?.email {
            email_label.text = email
        }
        if let familyName = info?.family_name {
            familyName_label.text = familyName
        }
        if let prefferedName = info?.preferred_username {
            preferredName_label.text = prefferedName
        }
        if let uniqueName = info?.unique_name {
            uniqueName_label.text = uniqueName
        }
        if let isVerified = info?.email_verified, isVerified {
            emailVerification_label.text = "True"
        }else {
            emailVerification_label.text = "False"
        }
    }
}
//MARK:- activity indicator
extension ProfileViewController {
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
