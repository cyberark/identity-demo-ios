
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
        
    @IBOutlet weak var accessToken_Switch: UISwitch!
    
    @IBOutlet weak var appLaunch_switch: UISwitch!
    
    var isAuthenticated = false
    
    var isFromLogin = false

    var isFromEnrollORQRCode = false

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    let builder = QRAuthenticationProvider()
    
    let enrollProvider = EnrollmentProvider()

}
//MARK:- Viewlife cycle
extension HomeViewController {
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureBiometricsUI()
    }
}
//MARK:- UI Handlers
extension HomeViewController {
    func configure() {
        addLogoutObserver()
        configureBiometricsUI()
        addDidBecomeActiveObserver()
        configureEnrollButton()
        addEnrollObserver()
        showActivityIndicator(on: self.view)
        addRefreshTokenObserver()
        if !isFromLogin {
            lauchBiomtrics()
        } else {
            isFromLogin = false
        }
        isFromEnrollORQRCode = false;
    }
    @IBAction func do_click(_ sender: Any) {
        navigate(button: sender as! UIButton)
    }
    @IBAction func enableApplaunch(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
        UserDefaults.standard.synchronize()

    }
    @IBAction func enableOnAccesstokeExpires(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
        UserDefaults.standard.synchronize()
    }
}
//MARK:- Initial Configurations
extension HomeViewController {
    func configureBiometricsUI() {
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
        }
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
        }
        UserDefaults.standard.synchronize()
        appLaunch_switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue), animated: true)
        accessToken_Switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue), animated: true)
    }
    func addDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(lauchBiomtrics),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    @objc func lauchBiomtrics() {
        if (!isAuthenticated) {
            addBiometrics()
        } else {
            isAuthenticated = false
        }
        configureEnrollButton()
        configureBiometricsUI()
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
}
//MARK:- Biomtrics launch
extension HomeViewController {
    func addBiometrics() {
        let isAcessTokenExpired = checkForAccessTokenExpiry()
        if ( UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue) || (UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue) && isAcessTokenExpired)) {
            if (!isAcessTokenExpired && isFromEnrollORQRCode) {
                configureEnrollment()
                isFromEnrollORQRCode = false
                return
            }
            DispatchQueue.main.async {
                self.addBlurrView()
            }
            
            BiometricsAuthenticator().authenticateUser { (response) in
                switch response {
                case .success(let success):
                    print("Success \(success)")
                    self.isAuthenticated = true
                    if isAcessTokenExpired {
                        self.getRefreshToken()
                    }
                case .failure(let error):
                    self.isAuthenticated = false
                    
                    DispatchQueue.main.async {
                        let state = UIApplication.shared.applicationState
                        if state == .active  {
                            print("Error for Biometric enrole\(error.localizedDescription)")
                            let mesage = error.localizedDescription
                            let alertController = UIAlertController(title: "Biometric error", message: mesage, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(action)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    self.removeBlurrView()
                }
            }
        } else if (isAcessTokenExpired) {
            let alertController = UIAlertController(title: "Unauthorized access", message: "Seems like the current session is expired. Please click on OK to get the new access token...", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.getRefreshToken()
            })
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }else if (!isAcessTokenExpired && isFromEnrollORQRCode) {
            configureEnrollment()
        }

    }
    func checkForAccessTokenExpiry() -> Bool {
        do {
            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.access_token_expiresIn.rawValue) else {
                return false
            }
            return  Date().isAccessTokenExpired(with: data)
        } catch {
            print("Unexpected error: \(error)")
        }
        return false
    }
}
//MARK: Weblogin
extension HomeViewController {
    func navigate(button: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if button == enroll_button {
            }  else if button == refresh_button {
                getRefreshToken()
            }else if button == logout_button {
                closeSession()
            }else {
                isFromEnrollORQRCode = true
                addBiometrics()
            }
           
        } else {
            showAlert(with: "Network issue", message: "Please connect to the the internet")
        }
    }
    
    func configureEnrollment() {
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            navigateToScanner()
        } else {
            enrollDevice()
        }
    }
   
    func navigateToScanner() {
        builder.authenticateWithQRCode(presenter: self, completion: { [weak self] result in
            switch result {
            case .success(_):
                print("QR auth success")
            case .failure(let error):
                    self?.showAlert(with :"Invalid Request", message: "Seems like something went wrong.Please try again later")
            }
        })
    }
}
extension HomeViewController {
    
    /// To close the current session
    /// Remove  all the data which is persisted locally
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
    
    /// Observer for the logout response
    func addLogoutObserver(){
        CyberArkAuthProvider.didReceiveLogoutResponse = { (result, message) in
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
            enrollProvider.enroll(baseURL: config.systemurl)
            
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
extension HomeViewController {
    
    /// To get the refresh token
    func getRefreshToken() {
        activityIndicator.startAnimating()
        CyberArkAuthProvider.sendRefreshToken()
    }
    /*
    ///
    /// Observer to get the access token
    /// Must call this method before calling the login api
    */
    func addRefreshTokenObserver(){
        CyberArkAuthProvider.didReceiveRefreshToken = { (status, message, response) in
            self.activityIndicator.stopAnimating()
            if status {
                self.save(response: response)
                if self.isFromEnrollORQRCode {
                    self.isFromEnrollORQRCode = false;
                    self.configureEnrollment()
                }
            } else {
                self.isFromEnrollORQRCode = false;
                self.clearCachedData()
                self.navigateToLogin()
                //self.showAlert(with: "Seems like something went wrong", message: message)
            }
        }
    }
    func save(response: AccessToken?) {
        do {
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
            if let accessToken = response?.access_token {
                try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.accessToken.rawValue, data: accessToken.toData() ?? Data())
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
extension HomeViewController {
    func navigateToLogin(){
        let alertController = UIAlertController(title: "Unauthorized access", message: "Seems like the current session is expired. Please login again to continue...", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.closeSession()
            //self.configureInitialScreen()
        })
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    func clearCachedData() {
        do {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
        } catch {
            debugPrint("operation error")
        }
    }
}
