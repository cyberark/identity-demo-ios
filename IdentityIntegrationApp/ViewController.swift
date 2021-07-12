//
//  ViewController.swift
//  IdentitySDKIntegrationExample
//
//  Created by Mallikarjuna Punuru on 07/07/21.
//

import UIKit
import Identity

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    let loginTypes = [
        "Login(OAuth+PKCE)",
        "Refresh Token",
        "End Session/Logout",
        "QRCode Authenticator"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        addObserver()
        // Do any additional setup after loading the view.
    }
    func registerCell() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loginTypes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = loginTypes[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigate(index: indexPath.row)
    }
}
//MARK: Weblogin
extension ViewController {
    func navigate(index: Int) {
        if index == 0 {
            navigateToLogin()
        }  else if index == 1 {
            refreshToken()
        }else if index == 2 {
            closeSession()
        }else {
            navigateToScanner()
        }
    }

    func navigateToLogin() {
        guard let _ = plistValues(bundle: Bundle.main) else { return }
        CyberArkAuthProvider.webAuth()?.set(presentingViewController: self)
            .setCustomParam(key: "", value: "")
            .build()
            .login(completion: { (result, error) in
                if((result) != nil) {
                    
                }
        })
    }
    func addObserver(){
        CyberArkAuthProvider.viewmodel()?.didReceiveAccessToken = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.showAlert(with :"Access Token: ", message: accessToken)
                    }
                }
            }
        }
    }
    func closeSession() {
        guard let _ = plistValues(bundle: Bundle.main) else { return }
        CyberArkAuthProvider.webAuth()?.set(presentingViewController: self)
            .setCustomParam(key: "", value: "")
            .build()
            .closeSession(completion: { (result, error) in
                if((result) != nil) {
                    
                }
            })
    }
    func refreshToken() {
        CyberArkAuthProvider.sendRefreshToken()
    }
}
//MARK: QRScanner
extension ViewController {
    func navigateToScanner() {
        let builder = QRCodeScannerBuilder()
        builder.authenticate(with: nil, presenter: self)
    }
}

//MARK:- read from plist
extension ViewController {
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String, domain_auth0: String)? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String,let applicationID = values["applicationid"] as? String, let threshold = values["threshold"] as? Int
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return (clientId: clientId, domain: domain, domain_auth0:domain)
    }

}
