
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

class ViewController: UIViewController {
    
    let homeViewSegueIdentifier = "HomeViewSegueIdentifier"
    let settingsViewSegueIdentifier = "SettingsSugueidentifier"

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var loginTypes = [
        "Login"
        //"Refresh Token",
        //"End Session/Logout"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeBlurrView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurrView()
    }
    @IBAction func login_click(_ sender: Any) {
        navigateToLogin()
    }
    
}
extension ViewController {
    func configure(){
        registerCell()
        addObserver()
        addLogoutObserver()
        //addRightBar()
    }
    func registerCell() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    func addRightBar() {
        let image = UIImage(named: "settings_icon")?.withRenderingMode(.alwaysOriginal)
        let rightButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    @objc func rightButtonAction(sender: UIBarButtonItem){
        navigateToSettingsScreen()
    }
    func navigate(index: Int) {
        if index == 0 {
            navigateToLogin()
        }
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
    /*
    /// Invokes the Login call
    /// Launches the extrenal safari view controller based on the configuration
    /// Setup the initial configuration
    /// Custom browser Parameters
    ///
    */
    func navigateToLogin() {
        
        guard let config = plistValues(bundle: Bundle.main) else { return }
        
        guard let account =  CyberArkAuthProvider.webAuth()?
                .set(clientId: config.clientId)
                .set(domain: config.domain)
                .set(redirectUri: config.redirectUri)
                .set(applicationID: config.applicationID)
                .set(presentingViewController: self)
                .setCustomParam(key: "", value: "")
                .set(scope: config.scope)
                .set(webType: .sfsafari)
                .build() else { return }

        CyberArkAuthProvider.login(account: account)
    }
    /*
    ///
    /// Observer to get the access token
    /// Must call this method before calling the login api
    */
    func addObserver(){
        CyberArkAuthProvider.didReceiveAccessToken = { (status, message, response) in
            if status {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.save(response: response)
                        self.navigateToHomeScreen()
                    }
                }
            } else {
                self.showAlert(with: "Seems like something went wrong", message: message)
            }
        }
    }
    func addLogoutObserver(){
        CyberArkAuthProvider.viewmodel()?.didLoggedOut = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                    }
                }
            }
        }
    }
    func save(response: AccessToken?) {
        do {
            if let accessToken = response?.access_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.accessToken.rawValue, data: accessToken.toData() ?? Data())
            }
            if let refreshToken = response?.refresh_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.refreshToken.rawValue, data: refreshToken.toData() ?? Data())
            }
            if let expiresIn = response?.expires_in {
                let date = Date().epirationDate(with: expiresIn)
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.access_token_expiresIn.rawValue, data: Data.init(from: date))
            }
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
    
}
//MARK:- Navigation
extension ViewController {
    func navigateToHomeScreen() {
        performSegue(withIdentifier: homeViewSegueIdentifier, sender: self)
    }
    func navigateToSettingsScreen() {
        performSegue(withIdentifier: settingsViewSegueIdentifier, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == homeViewSegueIdentifier) {
            _ = segue.destination as! HomeViewController
        } else if (segue.identifier == settingsViewSegueIdentifier) {
            _ = segue.destination as! SettingsViewController
        }
    }
  
}
extension ViewController {
    func plistValues(bundle: Bundle) -> (clientId: String, domain: String, domain_auth0: String, scope: String, redirectUri: String, threshold: Int, applicationID: String, logouturi: String)? {
        guard
            let path = bundle.path(forResource: "IdentityConfiguration", ofType: "plist"),
            let values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return nil
        }
        guard
            let clientId = values["clientid"] as? String,
            let domain = values["domainautho"] as? String, let scope = values["scope"] as? String, let redirectUri = values["redirecturi"] as? String, let threshold = values["threshold"] as? Int, let applicationID = values["applicationid"] as? String, let logouturi = values["logouturi"] as? String
        else {
            print("IdentityConfiguration.plist file at \(path) is missing 'ClientId' and/or 'Domain' values!")
            return nil
        }
        return (clientId: clientId, domain: domain, domain_auth0: domain, scope: scope, redirectUri: redirectUri, threshold: threshold, applicationID: applicationID, logouturi: logouturi)
    }
}
extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return nil }
        return delegate
    }
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
    func addBlurrView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    /// Remove UIBlurEffect from UIView
    func removeBlurrView() {
        let blurredEffectViews = self.view.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
}
