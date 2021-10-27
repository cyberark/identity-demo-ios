//
//  NotificationsViewController.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 07/10/21.
//

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
        addEnrollObserver()
        showActivityIndicator(on: self.view)
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
            guard let config = plistValues(bundle: Bundle.main) else { return }
            mfaProvider.handleMFAChallenge(isAccepted: isAccepted, challenge: challenge, baseURL: config.domain)
        } catch  {
        }
    }
  
    /*
    ///
    /// Observer to get the enrollment status
    /// Must call this method before calling the enroll api
    */
    func addEnrollObserver(){
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
extension NotificationsViewController {
    /// To read from the plist
    /// - Parameter bundle: bundle
    /// - Returns: configuration
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
