
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
    
    let mfaProvider = MFAChallengeProvider()

    private let notificationsSegueIdentifier = "NotificationsSegueIdentifier"
    
    private var pushUserInfo = [AnyHashable : Any]()

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
//MARK:- Intial configuration and UI Handlers
extension HomeViewController {
    
    /*
     /// Initial Configurations
     ///
     */
    
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
            appLaunch_switch.isUserInteractionEnabled = true
            accessToken_Switch.isUserInteractionEnabled = true
        }
        
        isFromEnrollORQRCode = false;
        addListenersForNotification()
    }
    
    /// Button handlers
    /// - Parameter sender: sender
    @IBAction func do_click(_ sender: Any) {
        navigate(button: sender as! UIButton)
    }
    
    /// Handler
    /// - Parameter sender:
    @IBAction func enableApplaunch(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        UserDefaults.standard.synchronize()

    }
    
    /// Handler
    /// - Parameter sender: <#sender description#>
    @IBAction func enableOnAccesstokeExpires(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
        UserDefaults.standard.synchronize()
    }
}
//MARK:- Initial Configurations
extension HomeViewController {
    /*
     /// To configure the biomtrics
     /// Setup UI
     */
    func configureBiometricsUI() {
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        }
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
        }
        UserDefaults.standard.synchronize()
        appLaunch_switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue), animated: true)
        accessToken_Switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue), animated: true)
    }
    /*
     /// Obsever for didbecome active
     /// Check for biometrics
     */
    func addDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(launchBiomtericsOnForeground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    // To launch the biometrics
    @objc func lauchBiomtrics() {
        if (!isAuthenticated) {
            addBiometrics()
        } else {
            isAuthenticated = false
        }
        configureEnrollButton()
        configureBiometricsUI()
    }
    // To remove the biometrics
    func removeOberver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    // to configure the enrollbutton
    func configureEnrollButton(){
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            QR_button.setTitle("QR Code Authenticator", for: .normal)
            
        } else {
            QR_button.setTitle("Opt in for MFA", for: .normal)
        }
    }
    @objc func launchBiomtericsOnForeground() {
        let isBiometricsEnabled = evaluateBiometrics()
        let isSystemBiomtericsEnabled = BiometricsAuthenticator().canEvaluatePolicy()
        if isBiometricsEnabled && !isSystemBiomtericsEnabled {
            showBiometricsNotConfigurationAlert()
        }
        //enableBiomtericSwitches(isBiometricsEnabled: isBiometricsEnabled)
    }
    func evaluateSystemBiometrics() -> Bool {
        let systemBiomtericsEnabled = BiometricsAuthenticator().canEvaluatePolicy()
        return systemBiomtericsEnabled
    }
    func evaluateBiometrics() -> Bool {
        let isBiometricOnAppLaunchEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        let isBiometricWhenAccessTokenExpiresEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
        var isNeedBiomtrics = false
        if (isBiometricOnAppLaunchEnabled || isBiometricWhenAccessTokenExpiresEnabled) {
            isNeedBiomtrics = true
        }
        
        return isNeedBiomtrics
    }
    func enableBiomtericSwitches(isBiometricsEnabled: Bool){
        if(!isBiometricsEnabled){
            appLaunch_switch.isUserInteractionEnabled = false
            appLaunch_switch.tintColor = .gray
            accessToken_Switch.isUserInteractionEnabled = false
            accessToken_Switch.tintColor = .gray
        }else {
            appLaunch_switch.isUserInteractionEnabled = true
            accessToken_Switch.isUserInteractionEnabled = true
        }
    }
    func showBiometricsNotConfigurationAlert(){
        
        let state = UIApplication.shared.applicationState
        if state == .active  {
            let mesage = "Biometrics are not configured.Please configure Face ID or Touch ID"
            let alertController = UIAlertController(title: "Biometrics configuration error", message: mesage, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(action)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                self.navigateSettings()
            })
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
}

//MARK:- Biomtrics launch
extension HomeViewController {
    
    /// To add biometrics
    func addBiometrics() {
        let isAcessTokenExpired = checkForAccessTokenExpiry()
        if ( UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue) || (UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue) && isAcessTokenExpired)) {
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
                    self.isAuthenticated = true
                    if isAcessTokenExpired {
                        self.getRefreshToken()
                    }
                case .failure(let error):
                    self.isAuthenticated = false
                    
                    DispatchQueue.main.async {
                        let state = UIApplication.shared.applicationState
                        if state == .active  {
                             let errorType = error as BiometricError
                            if errorType == .biometricsNotEnrolled {
                                let mesage = error.errorDescription
                                let alertController = UIAlertController(title: "Biometrics configuration error", message: mesage, preferredStyle: .alert)
                                let action = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                alertController.addAction(action)
                                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                                    self.navigateSettings()
                                })
                                alertController.addAction(settingsAction)
                                self.present(alertController, animated: true, completion: nil)
                                
                            } else {
                                let mesage = error.errorDescription
                                let alertController = UIAlertController(title: "Biometrics configuration error", message: mesage, preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    self.removeBlurrView()
                }
            }
        } else if (isAcessTokenExpired) {
            let alertController = UIAlertController(title: "", message: "Access token is expired. Would you like get new Access Token using refresh token?", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.getRefreshToken()
            })
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }else if (!isAcessTokenExpired && isFromEnrollORQRCode) {
            configureEnrollment()
        }

    }
    
    /// To check for the access token expiry
    /// - Returns: boolean value indicates the token expiry
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
    /// Navigate to settings to system settings page
    func navigateSettings() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
//MARK: Navigation
extension HomeViewController {
    
    /// Navigate based on the click
    /// - Parameter button: button
    func navigate(button: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if button == enroll_button {
            }  else if button == refresh_button {
                getRefreshToken()
            }else if button == logout_button {
                closeSession()
            }else {
                let isBiometricsEnabled = evaluateBiometrics()
                let isSystemBiomtericsEnabled = BiometricsAuthenticator().canEvaluatePolicy()
                if isBiometricsEnabled && !isSystemBiomtericsEnabled {
                    showBiometricsNotConfigurationAlert()
                    return
                }
                isFromEnrollORQRCode = true
                lauchBiomtrics()
            }
           
        } else {
            showAlert(with: "Network issue", message: "Please connect to the the internet")
        }
    }
    
    /// configure enrollment
    func configureEnrollment() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue) {
            scanQRCode()
        } else {
            enrollDevice()
        }
    }
    // To Scan the QR code
    func scanQRCode() {
        builder.authenticateWithQRCode(presenter: self, completion: { [weak self] result in
            switch result {
            case .success(_): break
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
        guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
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
                        self.appDelegate.unregisterPushNotifications()
                        self.configureInitialScreen()
                    }
                }
            }
            self.removeBlurrView()
        }
    }
    func removePersistantStorage() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
    }
}
extension HomeViewController {
    
    /// To setup the root view controller
    func configureInitialScreen() {
        let story = UIStoryboard(name: "Main", bundle:nil)
        var vc: UIViewController = UIViewController()
        vc = story.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let navController = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = navController
    }
    
    /// To enroll the device
    func enrollDevice() {
        activityIndicator.startAnimating()

        do {
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }

            guard let data = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.grantCode.rawValue), let code = data.toString() , let refreshTokenData = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.refreshToken.rawValue),let refreshToken = refreshTokenData.toString() else {
                return
            }
            enrollProvider.enroll(baseURL: config.systemurl)
            
        } catch  {
        }
    }
    /*
    ///
    /// Observer to get the enrollment status
    /// Must call this method before calling the enroll api
    */
    func addEnrollObserver(){
        enrollProvider.didReceiveEnrollmentApiResponse = { (result, accessToken) in
            if result {
                self.configureEnrollButton()
                self.appDelegate.registerPushNotifications()
            }else {
                self.showAlert(message: accessToken)
            }
            self.activityIndicator.stopAnimating()
        }
    }
}
//MARK:- activity indicator
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
    /*
    /// To get the new access token
    /// when the accesstok expires, Need to fetch the new token by using refresh token.
    /// Need to take to the logout screen if refresh token gets exired.
    */
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
    /*
    /// To save the data to the keychain securely
    ///  User should use the keycahin wrapper to store the data
    /// - Parameter response: response
     */
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
    
    /// Navigate to login screen
    func navigateToLogin(){
        let alertController = UIAlertController(title: "", message: "Refresh token is expired. You need to login again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.closeSession()
            //self.configureInitialScreen()
        })
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    /// To clear the local cache
    /// No longer needed the persistant data,Need to remove the userdafaults and keychain storage.
     */
    func clearCachedData() {
        do {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isDeviceEnrolled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
        } catch {
            debugPrint("error: \(error)")
        }
    }
}
//MARK:- Extensions
extension HomeViewController {
    /*
    // Observers for the notifications
    // Accept and Reject handlers
    */
    func addListenersForNotification(){
        
        Notification.Name.acceptButton.onPost { [weak self] notification in
            let info = notification.userInfo
            self?.pushUserInfo = info ?? [AnyHashable : Any]()
            //self?.performChallengeby(isAccepted: true)
        }
        
        Notification.Name.rejectButton.onPost { [weak self] notification in
            let info = notification.userInfo
            self?.pushUserInfo = info ?? [AnyHashable : Any]()
            //self?.performChallengeby(isAccepted: false)
        }
        
        Notification.Name.handleNotification.onPost { [weak self] notification in
            let info = notification.userInfo
            self?.pushUserInfo = info ?? [AnyHashable : Any]()
            self?.navigateToNotifications()
        }
    }
    
}

//MARK:- Navigation
extension HomeViewController {
    /*
    // Observers for the notifications
    // Accept and Reject handlers
    */
    func navigateToNotifications(){
        var ispresent = false
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: NotificationsViewController.self) {
                    ispresent = true
                    let controller = viewController as! NotificationsViewController
                    controller.pushUserInfo = pushUserInfo
                    controller.reloadNotifications()
                    break
                }
            }
        }
        if(!ispresent) {
            self.performSegue(withIdentifier: notificationsSegueIdentifier, sender: self)
        }
    }
    func addRightBar() {
        let image = UIImage(named: "notification_icon")?.withRenderingMode(.alwaysOriginal)
        let rightButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightButtonAction(sender:)))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    @objc func rightButtonAction(sender: UIBarButtonItem){
        navigateToNotifications()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == notificationsSegueIdentifier {
            let destinationController = segue.destination as! NotificationsViewController
            destinationController.pushUserInfo = pushUserInfo
        }
    }
}
