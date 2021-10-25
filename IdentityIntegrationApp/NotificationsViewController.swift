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

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}
//MARK:- Initial configuration
extension NotificationsViewController {
    func configure(){
        registerCell()
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
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
