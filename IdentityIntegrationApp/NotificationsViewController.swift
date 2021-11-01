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
        
    var notifications = [
        "Login"
    ]
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    let celIdentifier = "MFANotificationTableViewCell"
    
    var pushUserInfo = [AnyHashable : Any]()

    let mfaProvider = MFAChallengeProvider()

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    public func reloadNotifications() {
        tableView.reloadData()
    }
}
//MARK:- Initial configuration
extension NotificationsViewController {
    func configure(){
        registerCell()
        addMFAObserver()
        showActivityIndicator(on: self.view)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    func registerCell() {
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "MFANotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "MFANotificationTableViewCell")
    }
}
//MARK:- UITableViewDelegate, UITableViewDataSource
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MFANotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: celIdentifier, for: indexPath) as! MFANotificationTableViewCell
        let userInfo = pushUserInfo["payload"] as! [AnyHashable: Any]
        let info = userInfo["Options"] as! [AnyHashable: Any]
        let message =  "\(info["Message"] as! String) for \(info["TargetAuthUser"] as! String)"
                cell.text_label.text = message
        cell.text_label.numberOfLines = 0
        cell.approve_button.addTarget(self, action:#selector(approve_click), for: .touchUpInside)
        cell.reject_button.addTarget(self, action:#selector(reject_click), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        do {
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
            mfaProvider.handleMFAChallenge(isAccepted: isAccepted, challenge: challenge, baseURL: config.domain, withCompletionHandler: nil)
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
                self.navigationController?.popViewController(animated: true)
            }else {
                self.showAlert(message: accessToken)
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
