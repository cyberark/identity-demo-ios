//
//  HomeViewController.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 19/07/21.
//
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


class HomeViewController: UIViewController {
    
    @IBOutlet weak var enroll_button: UIButton!
    @IBOutlet weak var QR_button: UIButton!
    @IBOutlet weak var logout_button: UIButton!
    @IBOutlet weak var refresh_button: UIButton!
    let builder = QRAuthenticationProvider()
    
    @IBOutlet weak var accessToken_Switch: UISwitch!
    @IBOutlet weak var appLaunch_switch: UISwitch!
    var isAuthenticated = false
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        addLogoutObserver()
        configureBiometricsUI()
        addDidBecomeActiveObserver()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeOberver()
    }
    func setupDefaults(){
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            enroll_button.isEnabled = false
            QR_button.isEnabled = true
        }else{
            enroll_button.isEnabled = true
            QR_button.isEnabled = false
        }
    }
    func addBiometrics() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue) {
            BiometricsAuthenticator().authenticateUser { (response) in
                switch response {
                case .success(let success):
                    print("Success \(success)")
                    self.isAuthenticated = true
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
            }
        }
    }
    @IBAction func enableApplaunch(_ sender: Any) {
        appLaunch_switch.isSelected = !appLaunch_switch.isSelected
        UserDefaults.standard.set(appLaunch_switch.isSelected, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
    }
    @IBAction func enableOnAccesstokeExpires(_ sender: Any) {
        accessToken_Switch.isSelected = !accessToken_Switch.isSelected
        UserDefaults.standard.set(accessToken_Switch.isSelected, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
    }
    func configureBiometricsUI() {
        appLaunch_switch.isSelected = true
        accessToken_Switch.isSelected = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAppLaunch.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isEnabledBiometricOnAccessTokenExpires.rawValue)
    }
    @objc func applicationDidBecomeActive() {
        if (!isAuthenticated) {
            addBiometrics()
        } else {
            isAuthenticated = false
        }
    }
    func addDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    func removeOberver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}
extension HomeViewController {
    @IBAction func do_click(_ sender: Any) {
        navigate(button: sender as! UIButton)
    }
}
//MARK: Weblogin
extension HomeViewController {
    func navigate(button: UIButton) {
        if button == enroll_button {
            CyberArkAuthProvider.enrollDevice()
        }  else if button == refresh_button {
            refreshToken()
        }else if button == logout_button {
            closeSession()
        }else {
            navigateToScanner()
        }
    }

    func addObserver(){
        CyberArkAuthProvider.viewmodel()?.didReceiveRefreshToken = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    //self.dismiss(animated: true) {
                        self.showAlert(with :"Refresh Token: ", message: accessToken)
                   // }
                }
            }
        }
    }
  
    func refreshToken() {
        CyberArkAuthProvider.sendRefreshToken()
    }
    func navigateToScanner() {
        builder.authenticateQrCode(presenter: self, completion: { [weak self] result in
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
    }
    func addLogoutObserver(){
        CyberArkAuthProvider.viewmodel()?.didLoggedOut = { (result, accessToken) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.configureInitialScreen()
                        //self.navigationController?.popViewController(animated: true)
                    }
                }
            }
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
}
