
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

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tenant_textfeild: UITextField!
    @IBOutlet weak var systemURL_textfeild: UITextField!
    @IBOutlet weak var loginURL_textfeild: UITextField!
    @IBOutlet weak var clientID_textfeild: UITextField!
    @IBOutlet weak var appID_textfeild: UITextField!
    @IBOutlet weak var responseType_textfeild: UITextField!
    @IBOutlet weak var scope_textfeild: UITextField!
    @IBOutlet weak var redirectURI_textfeild: UITextField!
    @IBOutlet weak var widgetID_textfeild: UITextField!
    @IBOutlet weak var mfaTenant_textfeild: UITextField!

    @IBOutlet weak var accessToken_Switch: UISwitch!
    @IBOutlet weak var appLaunch_switch: UISwitch!
    @IBOutlet weak var qrLaunch_switch: UISwitch!
    @IBOutlet weak var transferFunds_switch: UISwitch!

    var activeField: UITextField?

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var invokeBiometricsStackView: UIStackView!
    @IBOutlet weak var invokeBiometricsTitleStackView: UIStackView!
    @IBOutlet weak var qrLaunchStackView: UIStackView!
    @IBOutlet weak var accesstokenExpiresStackView: UIStackView!
    @IBOutlet weak var cyberarkHostedloginStackView: UIStackView!
    @IBOutlet weak var mfaTitleStackView: UIStackView!
    @IBOutlet weak var transferFundsStackView: UIStackView!

    //Authentication Widget
    @IBOutlet weak var authWidgetContentStackView: UIStackView!
    @IBOutlet weak var authWidgetID_textfeild: UITextField!
    @IBOutlet weak var authWidgetHostURL_textfeild: UITextField!
    @IBOutlet weak var authWidgetResourceURL_textfeild: UITextField!

    var loginType: LoginType?


    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
extension SettingsViewController {
    func config(){
        setupData()
        setupTextFeilds()
        addKeyboardObservers()
        addDoneBarButtonItem()
        addTopbar()
        setupStackViewUI()
        configureBiometricsUI()
    }
    func setupData(){
        guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
        tenant_textfeild.text = config.domain
        systemURL_textfeild.text = config.systemurl
        loginURL_textfeild.text = config.loginURL
        clientID_textfeild.text = config.clientId
        appID_textfeild.text = config.applicationID
        scope_textfeild.text = config.scope
        redirectURI_textfeild.text = config.redirectUri
        responseType_textfeild.text = config.responseType
        widgetID_textfeild.text = config.widgetID
        mfaTenant_textfeild.text = config.mfaTenantURL
        responseType_textfeild.isEnabled = false
        responseType_textfeild.backgroundColor = .lightGray
        
        authWidgetID_textfeild.text = config.authwidgetId
        authWidgetHostURL_textfeild.text = config.authwidgethosturl
        authWidgetResourceURL_textfeild.text = config.authwidgetresourceURL
    }
    func setupStackViewUI(){
        do {
            if (try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.accessToken.rawValue)) != nil  {
                setupStackViews(isHidden: true)
                invokeBiometricsStackView.isHidden = false
                invokeBiometricsTitleStackView.isHidden = false
                //transferFundsStackView.isHidden = true
                accesstokenExpiresStackView.isHidden = false
                qrLaunch_switch.isHidden = false
                cyberarkHostedloginStackView.isHidden = true
            }else if (try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.session_Id.rawValue)) != nil  {
                setupStackViews(isHidden: true)
                invokeBiometricsStackView.isHidden = false
                invokeBiometricsTitleStackView.isHidden = false
                //transferFundsStackView.isHidden = false
                accesstokenExpiresStackView.isHidden = true
                qrLaunchStackView.isHidden = true
                cyberarkHostedloginStackView.isHidden = true
            }else if loginType == .stepupauthenticationusingMFA {
                mfaTitleStackView.isHidden = false
                //transferFundsStackView.isHidden = false
                cyberarkHostedloginStackView.isHidden = true
                invokeBiometricsStackView.isHidden = true
                invokeBiometricsTitleStackView.isHidden = true
            } else {
                setupStackViews(isHidden: false)
                invokeBiometricsStackView.isHidden = true
                invokeBiometricsTitleStackView.isHidden = true
                cyberarkHostedloginStackView.isHidden = false
                mfaTitleStackView.isHidden = false
                //transferFundsStackView.isHidden = false
            }
            transferFundsStackView.isHidden = true

            
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    func setupStackViews(isHidden: Bool){
        for subview in contentStackView.subviews {
            subview.isHidden = isHidden
        }
    }
    func addTopbar() {
        self.navigationItem.title = "Acme Inc"
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
    }
    @objc func back()  {
        pop()
    }
}
extension SettingsViewController {
    func setupTextFeilds(){
        addDoneButtonOnKeyboard(textFeild: tenant_textfeild)
        addDoneButtonOnKeyboard(textFeild: systemURL_textfeild)
        addDoneButtonOnKeyboard(textFeild: loginURL_textfeild)
        addDoneButtonOnKeyboard(textFeild: clientID_textfeild)
        addDoneButtonOnKeyboard(textFeild: appID_textfeild)
        addDoneButtonOnKeyboard(textFeild: responseType_textfeild)
        addDoneButtonOnKeyboard(textFeild: scope_textfeild)
        addDoneButtonOnKeyboard(textFeild: redirectURI_textfeild)
        addDoneButtonOnKeyboard(textFeild: widgetID_textfeild)
        addDoneButtonOnKeyboard(textFeild: mfaTenant_textfeild)
        addDoneButtonOnKeyboard(textFeild: authWidgetID_textfeild)
        addDoneButtonOnKeyboard(textFeild: authWidgetHostURL_textfeild)
        addDoneButtonOnKeyboard(textFeild: authWidgetResourceURL_textfeild)

    }
    func addDoneButtonOnKeyboard(textFeild: UITextField){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textFeild.inputAccessoryView = doneToolbar
        textFeild.autocorrectionType = .no
        tenant_textfeild.delegate = self
    }
    
    @objc func doneButtonAction(){
        
        if let urlString = tenant_textfeild.text {
            if urlString.isValidURL {
                var url = urlString
                if (!urlString.lowercased().hasPrefix("http://") || !urlString.lowercased().hasPrefix("https://")) {
                    url = "https://\(url)"
                }
            } else {
                showAlert(message: "Please provide valid url...")
            }
        }
        self.view.endEditing(true)

    }
    func addDoneBarButtonItem() {
        let rightButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(save(sender:)))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    @objc func save(sender: UIBarButtonItem){
         
        if(clientID_textfeild.text?.count ?? 0 > 0 && tenant_textfeild.text?.count ?? 0 > 0 && systemURL_textfeild.text?.count ?? 0 > 0 && appID_textfeild.text?.count ?? 0 > 0 && redirectURI_textfeild.text?.count ?? 0 > 0 && scope_textfeild.text?.count ?? 0 > 0 && responseType_textfeild.text?.count ?? 0 > 0 && widgetID_textfeild.text?.count ?? 0 > 0 && mfaTenant_textfeild.text?.count ?? 0 > 0) {
            var info = [String: Any]()
            info["clientid"] = clientID_textfeild.text
            info["domainoauth"] = tenant_textfeild.text
            info["systemurl"] = systemURL_textfeild.text
            info["loginurl"] = loginURL_textfeild.text
            info["applicationid"] = appID_textfeild.text
            info["redirecturi"] = redirectURI_textfeild.text
            info["scope"] = scope_textfeild.text
            info["responsetype"] = responseType_textfeild.text
            info["widgetid"] = widgetID_textfeild.text
            info["mfatenanturl"] = mfaTenant_textfeild.text
            info["authwidgethosturl"] = authWidgetHostURL_textfeild.text
            info["authwidgetid"] = authWidgetID_textfeild.text
            info["resourceurl"] = authWidgetResourceURL_textfeild.text

            UserDefaults.standard.setDict(dict: info, for: "OAuthConfig")
            pop()
        } else {
            showAlert(with: "", message: "Please enter all the input feilds")
        }
    }
    func textFieldDidBeginEditing(textField: UITextField!) {
        activeField = textField
    }

    func textFieldDidEndEditing(textField: UITextField!) {
        activeField = nil
    }
    func navigateToWelcomeScreen(){
        var ispresent = false
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: WelcomeViewController.self) {
                    ispresent = true
                    clearCachedData()
                    popToViewController(ofClass: WelcomeViewController.self)
                    break
                }
            }
        }
        if(!ispresent) {
            self.configureInitialScreen()
        }
        
    }
    /// To setup the root view controller
    func configureInitialScreen() {
        let story = UIStoryboard(name: "Main", bundle:nil)
        var vc: UIViewController = UIViewController()
        vc = story.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let navController = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = navController
    }
}
extension SettingsViewController {
    func addKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 60, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
   
}
//MARK:- Biomtrics
extension SettingsViewController {
    /*
     /// To configure the biomtrics
     /// Setup UI
     */
    func configureBiometricsUI() {
       
        appLaunch_switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue), animated: true)
        accessToken_Switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricWhenAccessTokenExpiresEnabled.rawValue), animated: true)
        qrLaunch_switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnQRLaunch.rawValue), animated: true)
        transferFunds_switch.setOn(UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue), animated: true)

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
    /// Handler
    /// - Parameter sender: <#sender description#>
    @IBAction func enableOnQRLaunch(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isBiometricOnQRLaunch.rawValue)
        UserDefaults.standard.synchronize()
    }
    /// Handler
    /// - Parameter sender: <#sender description#>
    @IBAction func enableOnTransferFundsLaunch(_ sender: Any) {
        UserDefaults.standard.set((sender as! UISwitch).isOn, forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue)
        UserDefaults.standard.synchronize()
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
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnQRLaunch.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.accessToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.grantCode.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.refreshToken.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.access_token_expiresIn.rawValue)
        } catch {
            debugPrint("error: \(error)")
        }
    }
}
