
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

/*
 /// HomeViewController
 */
class HomeViewController: UIViewController {
    
    @IBOutlet weak var enroll_button: UIButton!
    @IBOutlet weak var QR_button: UIButton!
    @IBOutlet weak var logout_button: UIButton!
    @IBOutlet weak var refresh_button: UIButton!
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    @IBOutlet weak var accessToken_Switch: UISwitch!
    @IBOutlet weak var appLaunch_switch: UISwitch!
    var isAuthenticated = false
    let builder = QRAuthenticationProvider()
    let enrollProvider = EnrollmentProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeOberver()
    }
}
//MARK:- UI Handlers
extension HomeViewController {
    func configure() {
        addObserver()
        addLogoutObserver()
        configureBiometricsUI()
        addDidBecomeActiveObserver()
        configureEnrollButton()
        addEnrollObserver()
        showActivityIndicator(on: self.view)
    }
    @IBAction func do_click(_ sender: Any) {
        navigate(button: sender as! UIButton)
    }
    @IBAction func enableApplaunch(_ sender: Any) {
        appLaunch_switch.isSelected = !appLaunch_switch.isSelected
        UserDefaults.standard.set(appLaunch_switch.isSelected, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
    }
    @IBAction func enableOnAccesstokeExpires(_ sender: Any) {
        accessToken_Switch.isSelected = !accessToken_Switch.isSelected
        UserDefaults.standard.set(accessToken_Switch.isSelected, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
    }
}
//MARK:- Configurations
extension HomeViewController {
    func configureBiometricsUI() {
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue) != nil) {
            appLaunch_switch.isSelected =  UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
            accessToken_Switch.isSelected = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
        }else {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
            appLaunch_switch.isSelected =  UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
            accessToken_Switch.isSelected = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
        }
    }
    func addDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    @objc func applicationDidBecomeActive() {
        if (!isAuthenticated) {
            addBiometrics()
        } else {
            isAuthenticated = false
        }
        configureEnrollButton()
    }
   
    func removeOberver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    func configureEnrollButton(){
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            QR_button.setTitle("QR Code Authenticator", for: .normal)

        } else {
            QR_button.setTitle("Opt in for QR Code Authenticator", for: .normal)
        }
    }
    
    func addBiometrics() {
        
        let isAcessTokenExpired = checkForAccessTokenExpiry()
        if ( UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue) || isAcessTokenExpired) {
            DispatchQueue.main.async {
                self.addBlurrView()
            }
            BiometricsAuthenticator().authenticateUser { (response) in
                switch response {
                case .success(let success):
                    print("Success \(success)")
                    self.isAuthenticated = true
                    if isAcessTokenExpired {
                        self.refreshToken()
                    }
                case .failure(let error):
                    self.isAuthenticated = false
                    DispatchQueue.main.async {
                        print("Error for Biometric enrole\(error.localizedDescription)")
                        let mesage = error.localizedDescription
                        let alertController = UIAlertController(title: "BioMetric Error", message: mesage, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.removeBlurrView()
                }
            }
        }
    }
    func checkForAccessTokenExpiry() -> Bool {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.access_token_expiresIn.rawValue) else {
                return false
            }
            let expirationDate = data.to(type: Date.self)
            if Date().isGreaterThan(expirationDate) {
                return true
            }
            return false
        } catch {
            print("Unexpected error: \(error)")
        }
        return false
    }
}
//MARK: Weblogin
extension HomeViewController {
    func navigate(button: UIButton) {
        if button == enroll_button {
        }  else if button == refresh_button {
            refreshToken()
        }else if button == logout_button {
            closeSession()
        }else {
            configureEnrollment()
        }
    }
    
    func addObserver(){
        CyberArkAuthProvider.viewmodel()?.didReceiveRefreshToken = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    //self.dismiss(animated: true) {
                    //self.showAlert(with :"Refresh Token: ", message: accessToken)
                    // }
                }
            }
        }
    }
    
    func configureEnrollment() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            navigateToScanner()
        } else {
            enrollDevice()
        }
    }
    func refreshToken() {
        CyberArkAuthProvider.sendRefreshToken()
    }
    func navigateToScanner() {
        builder.authenticateWithQRCode(presenter: self, completion: { [weak self] result in
            switch result {
            case .success(_):
                print("QR auth success")
            case .failure(let error):
                self?.showAlert(with :"Error", message: error.localizedDescription)
            }
        })
    }
}
extension HomeViewController {
    func closeSession() {
        removePersistantStorage()
        guard let config = plistValues(bundle: Bundle.main) else { return }
        
        guard let account =  CyberArkAuthProvider.webAuth()?
                .set(clientId: config.clientId)
                .set(domain: config.domain)
                .set(redirectUri: config.redirectUri)
                .set(applicationID: config.applicationID)
                .set(presentingViewController: self)
                .setCustomParam(key: "", value: "")
                .set(webType: .sfsafari)
                .build() else { return }
        
        CyberArkAuthProvider.closeSession(account: account)
        addBlurrView()
    }
    func addLogoutObserver(){
        CyberArkAuthProvider.viewmodel()?.didLoggedOut = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.configureInitialScreen()
                    }
                }
            }
            self.removeBlurrView()
        }
    }
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
    func removePersistantStorage() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
    }
}
extension HomeViewController
{
    func configureInitialScreen() {
        do {
            let story = UIStoryboard(name: "Main", bundle:nil)
            var vc: UIViewController = UIViewController()
            vc = story.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let navController = UINavigationController.init(rootViewController: vc)
            self.window?.rootViewController = navController
        } catch{
            print("Unexpected error: \(error)")
        }
    }
    func enrollDevice() {
        activityIndicator.startAnimating()

        do {
            guard let config = plistValues(bundle: Bundle.main) else { return }

            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.grantCode.rawValue), let code = data.toString() , let refreshTokenData = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.refreshToken.rawValue),let refreshToken = refreshTokenData.toString() else {
                return
            }
            enrollProvider.enroll(baseURL: config.domain)
            
        } catch  {
        }
    }
    func addEnrollObserver(){
        enrollProvider.didReceiveEnrollmentApiResponse = { (result, accessToken) in
            if result {
                self.configureEnrollButton()
            }else {
                self.showAlert(message: accessToken)
            }
            self.activityIndicator.stopAnimating()
        }
    }
}

extension HomeViewController {
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
