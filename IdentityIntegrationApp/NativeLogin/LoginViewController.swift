
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


class LoginViewController: UIViewController, UITextFieldDelegate {

    private let settingControllerSegueIdentifier = "SettingSegueIdentifier"
    private let transferFundsSegueIdentifier = "TransferFundsSegueIdentifier"

    @IBOutlet weak var userName_textfeild: UITextField!
    @IBOutlet weak var password_textfeild: UITextField!

    var activeField: UITextField?

    @IBOutlet weak var scrollView: UIScrollView!

    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    var loginType: LoginType?

    let loginProvider = LoginProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }

}
//MARK:- Initial configuration
extension LoginViewController {
    func configure(){
        addTitle()
        addRightBar()
        addLoginObserver()
        showActivityIndicator(on: self.view)
        password_textfeild.isSecureTextEntry = true
        addKeyboardObservers()
        setupTextFeilds()
    }
    func addTitle() {
        self.navigationItem.title = "Acme Inc"
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
    }
    @objc func back()  {
        pop()
    }
    func addRightBar() {
        let image = UIImage(named: "settings_icon")?.withRenderingMode(.alwaysOriginal)
        let rightButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsAction(sender:)))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    @objc func settingsAction(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: settingControllerSegueIdentifier, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if (segue.identifier == settingControllerSegueIdentifier) {
            let controller = segue.destination as! SettingsViewController
             controller.loginType = .stepupauthenticationusingMFA
        }
    }
}
extension LoginViewController {
    @IBAction func login_click(_ sender: Any) {
        guard let userName =  userName_textfeild.text, let password =  password_textfeild.text else {
            return
        }
        if userName.count > 0 && password.count > 0 {
           // doLoginAPI(userName: userName, password: password)
           doLogin(userName: userName, password: password)
        } else {
            showAlert(with: "", message: "Please enter username and password")
        }
    }
    func doLoginAPI(userName: String, password: String) {
        if Reachability.isConnectedToNetwork() {
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
            activityIndicator.startAnimating()
            loginProvider.handleLogin(userName: userName, password: password, baseURL: config.loginURL) {
            }
        } else {
            showAlert(with: "Network issue", message: "Please connect to the the internet")
        }
    }
    
}
//MARK: add Observer
extension LoginViewController {
    // To get the logout response
    func addLoginObserver(){
        loginProvider.didReceiveLoginApiResponse = { (result, message, accessToken, userName) in
            self.activityIndicator.stopAnimating()
            if result {
                do {
                    
                    if let sessionToken = accessToken {
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSessionCreated.rawValue)
                       try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.session_Id.rawValue, data: sessionToken.toData() ?? Data())
                    }
                    if let name = userName {
                        try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.userName.rawValue, data: name.toData() ?? Data())
                     }
                } catch {
                    print("Unexpected error: \(error)")
                }
                self.performSegue(withIdentifier: self.transferFundsSegueIdentifier, sender: self)
            } else {
                self.showAlert(with: "Unable to login", message: "")
            }
        }
    }
   
}

//MARK:- activity indicator
extension LoginViewController {
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
extension LoginViewController {
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
extension LoginViewController {
    func setupTextFeilds(){
        addDoneButtonOnKeyboard(textFeild: userName_textfeild)
        addDoneButtonOnKeyboard(textFeild: password_textfeild)
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
    func textFieldDidBeginEditing(textField: UITextField!) {
        activeField = textField
    }

    func textFieldDidEndEditing(textField: UITextField!) {
        activeField = nil
    }
    
}
extension LoginViewController {
    
    func doLogin(userName: String, password: String) {
        if Reachability.isConnectedToNetwork() {
            self.activityIndicator.startAnimating()
            guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
            let logoutString = "\(config.loginURL)/api/BasicLogin"
        
            if let url = URL(string: logoutString) {
                var request = URLRequest(url: url)
                let params = ["Username": userName, "Password": password]
        
                request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    guard let data = data else { return }
                    do {
                        print("Response:\(String(describing: response))")
                        let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                        print(json)
                        self.handleCookies(data: data, response: response, error: error)
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            if let status = json["Success"], status as! Bool {
                                do {
                                    if let info = json["Result"] as? Dictionary<String, Any> {
                                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSessionCreated.rawValue)

                                        if let sessionToken = info["SessionUuid"] as? String {
                                           try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.session_Id.rawValue, data: sessionToken.toData() ?? Data())
                                        }
                                        if let name = info["MFAUserName"] as? String {
                                            try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.userName.rawValue, data: name.toData() ?? Data())
                                         }
                                        self.performSegue(withIdentifier: self.transferFundsSegueIdentifier, sender: self)

                                    }
                                    
                                } catch {
                                    print("Unexpected error: \(error)")
                                }
                            } else {
                                self.showAlert(with: "Unable to login", message: "")
                            }
                            
                        }
                        
                    } catch {
                        print("error")
                    }
                })
                task.resume()
            }
        } else {
            showAlert(with: "Network issue", message: "Please connect to the the internet")
        }
       
    }
    func handleCookies(data: Data?, response: URLResponse?, error:Error?) {
        guard
            let url = response?.url,
            let httpResponse = response as? HTTPURLResponse,
            let fields = httpResponse.allHeaderFields as? [String: String], let token = fields["Set-Cookie"]
        else { return }
        
        do {
            let x = token.replacingOccurrences(of: "XSRF-TOKEN=", with: "", options: .regularExpression, range: nil)
            let y = x.replacingOccurrences(of: "; Path=/", with: "", options: .regularExpression, range: nil)

            try KeyChainWrapper.standard.save(key: KeyChainStorageKeys.xsrfToken.rawValue, data: y.toData() ?? Data())
        } catch {
            print("Unexpected error: \(error)")
        }
        
    }
}
