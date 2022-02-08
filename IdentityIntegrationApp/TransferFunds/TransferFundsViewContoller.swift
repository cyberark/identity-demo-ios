//
//  TransferFundsViewContoller.swift
//  IdentityIntegrationApp
//
//  Created by Mallikarjuna Punuru on 30/12/21.
//

import UIKit
import Identity

class TransferFundsViewContoller:  UIViewController, UITextViewDelegate, UITextFieldDelegate {
                
    @IBOutlet weak var body_textView: UITextView!
    
    @IBOutlet weak var amount_textFeild: UITextField!

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var isAuthenticated = false
    
    var isFromLogin = false

    private let settingControllerSegueIdentifier = "TransferFundsSettingsSegueIdentifier"

    let provider = MFAWidgetProvider()

}
//MARK:- Viewlife cycle
extension TransferFundsViewContoller {
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        self.addKeyboardObserver()
        amount_textFeild.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
    
}
//MARK:- Intial configuration and UI Handlers
extension TransferFundsViewContoller {
    
    /*
     /// Initial Configurations
     ///
     */
    func configure() {
        showActivityIndicator(on: self.view)
        addRightbarButtons()
        configureTextView(with: getFundsTransferAttributedString())
        addDidBecomeActiveObserver()
        if !isFromLogin {
            lauchBiometrics()
        } else {
            isFromLogin = false
        }
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        }
        if(UserDefaults.standard.object(forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue)
        }
        setupTextFeilds()
    }
    
    /// Button handlers
    /// - Parameter sender: sender
    @IBAction func transferFunds_click(_ sender: Any) {
        if let amount = amount_textFeild.text, Int(amount) ?? 0 > 0 {
            initiateFundsTransfer()
        } else {
            showAlert(message: "Please enter amount")
        }
    }
    // To launch the biometrics
    @objc func lauchBiometrics() {
        if (!isAuthenticated) {
            checkBiometricsOnAppLaunch()
        } else {
            isAuthenticated = false
        }
    }
}


//MARK:- activity indicator
extension TransferFundsViewContoller {
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

//MARK:- Navigation
extension TransferFundsViewContoller {
    func addRightbarButtons() {
        let settingsImage = UIImage(named: "settings_icon")?.withRenderingMode(.alwaysOriginal)
        let rightButtonItem = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: #selector(settingsAction(sender:)))
        rightButtonItem.tintColor = .white
        let LogoutImage = UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal)
        let logoutButtonItem = UIBarButtonItem(image: LogoutImage, style: .plain, target: self, action: #selector(logoutAction(sender:)))
        rightButtonItem.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [logoutButtonItem, rightButtonItem]
    }
    @objc func settingsAction(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: settingControllerSegueIdentifier, sender: self)
    }
    @objc func logoutAction(sender: UIBarButtonItem){
        removePersistantStorage()
        self.configureInitialScreen()
    }
    /// To setup the root view controller
    func configureInitialScreen() {
        let story = UIStoryboard(name: "Main", bundle:nil)
        var vc: UIViewController = UIViewController()
        vc = story.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        let navController = UINavigationController.init(rootViewController: vc)
        self.window?.rootViewController = navController
    }
    func removePersistantStorage() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue)
        do {
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.session_Id.rawValue)
            try KeyChainWrapper.standard.delete(key: KeyChainStorageKeys.userName.rawValue)

        } catch {
        }
    }
    
}
extension TransferFundsViewContoller {
    func configureTextView(with text :NSMutableAttributedString) {
        body_textView.attributedText = text
        body_textView.delegate = self
        body_textView.textAlignment = .center
        body_textView.isEditable = false
        body_textView.isSelectable = true
        body_textView.dataDetectorTypes = .link

    }
    func getFundsTransferAttributedString() -> NSMutableAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let normalText = "Once the user enters the amount and clicks on “Transfer funds” the CyberArk Identity MFA widget is loaded, and the user is asked to clear the challenges. Once user clears the challenges the user will be able to do the funds transfer successfully.\n\nPlease visit here to get detailed instructions to create the MFA widget\n\nPlease visit here for details on SDK implementation.​"
        
        let attributedString = normalText.getLinkAttributes(header: "", linkAttribute: "here", headerFont: UIFont.boldSystemFont(ofSize: 25.0), textFont:  UIFont.boldSystemFont(ofSize: 15.0), color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), underLineColor: .blue, linkValue: "https://identity-developer.cyberark.com/docs/cyberark-identity-sdk-for-ios")
        
        return attributedString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        launchURL()
        return true
    }
    func launchURL() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: "https://identity-developer.cyberark.com/docs/cyberark-identity-sdk-for-ios") {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
}
extension TransferFundsViewContoller {
    
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
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @objc func launchBiomtericsOnForeground() {
        let isBiometricsEnabled = evaluateBiometrics()
        let isSystemBiomtericsEnabled = BiometricsAuthenticator().canEvaluatePolicy()
        if isBiometricsEnabled && !isSystemBiomtericsEnabled {
            showBiometricsNotConfigurationAlert()
        }
    }
    func evaluateSystemBiometrics() -> Bool {
        let systemBiomtericsEnabled = BiometricsAuthenticator().canEvaluatePolicy()
        return systemBiomtericsEnabled
    }
    func evaluateBiometrics() -> Bool {
        let isBiometricOnAppLaunchEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)
        let isBiometricNeededOnTransferFunds = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue)

        var isNeedBiomtrics = false
        if (isBiometricOnAppLaunchEnabled || isBiometricNeededOnTransferFunds) {
            isNeedBiomtrics = true
        }
        
        return isNeedBiomtrics
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
    /// Navigate to settings to system settings page
    func navigateSettings() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
//MARK:- Biomtrics launch
extension TransferFundsViewContoller {
    
    /// To add biometrics
    func checkBiometricsOnAppLaunch() {
        if (UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricOnAppLaunchEnabled.rawValue)) {
            invokeBiomtrics(fromTransferFunds: false)
        }
    }
    func checkBiometricsOnTransferFunds() {
        if (UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBiometricEnabledOnTransfeFunds.rawValue)) {
            invokeBiomtrics(fromTransferFunds: true)
        }else {
            initiateFundsTransfer()
        }
    }
    func invokeBiomtrics(fromTransferFunds: Bool){
        DispatchQueue.main.async {
            self.addBlurrView()
        }
        BiometricsAuthenticator().authenticateUser { (response) in
            switch response {
            case .success(let success):
                self.isAuthenticated = true
                if(fromTransferFunds) {
                    self.initiateFundsTransfer()
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
    }
    func initiateFundsTransfer(){
        do {
            guard let userName = try KeyChainWrapper.standard.fetch(key: KeyChainStorageKeys.userName.rawValue) else { return }
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
            provider.launchMFAWidget(userName: userName.toString() ?? "", widgetID: config.widgetID, baseURL: config.mfaTenantURL, presentingViewconstroller: self, withCompletionHandler: nil)
            addTransferFundsTransfer()
        } catch {
        }
        
    }
    func addTransferFundsTransfer()  {
        provider.didReceiveApiResponse = { [weak self] status in
            self?.pop()
            self?.showFundsTransferSuccessMessage()
        }
    }
    func showFundsTransferSuccessMessage(){
        let alertViewController: InfoPopupViewController =  InfoPopupViewController.initFromNib()
        let normalText = "Awesome !​\n​\n Your funds have been transferred successfully​"
        let attributedString = normalText.getLinkAttributes(header: "Awesome !​​", linkAttribute: "", headerFont: UIFont.boldSystemFont(ofSize: 22.0), textFont:UIFont.boldSystemFont(ofSize: 15.0), color: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0), underLineColor: .white, linkValue: "")
        alertViewController.callCompletion {
            alertViewController.dismiss()
        }
        alertViewController.continueCallCompletion {
            alertViewController.dismiss()
        }
        alertViewController.meessageAtributedText = attributedString
        presentTranslucent(alertViewController, modalTransitionStyle: .crossDissolve, animated: true, completion: nil)
    }
}


extension TransferFundsViewContoller {
    func setupTextFeilds(){
        addDoneButtonOnKeyboard(textFeild: amount_textFeild)
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
        textFeild.delegate = self
    }
    
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
}

