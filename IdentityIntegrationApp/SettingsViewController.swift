
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
    @IBOutlet weak var clientID_textfeild: UITextField!
    @IBOutlet weak var appID_textfeild: UITextField!
    @IBOutlet weak var responseType_textfeild: UITextField!
    @IBOutlet weak var scope_textfeild: UITextField!
    @IBOutlet weak var redirectURI_textfeild: UITextField!
    @IBOutlet weak var widgetID_textfeild: UITextField!

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setupTextFeilds()
        addKeyboardObservers()
        addDoneBarButtonItem()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
}
extension SettingsViewController {
    func config(){
        guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
        tenant_textfeild.text = config.domain
        systemURL_textfeild.text = config.systemurl
        clientID_textfeild.text = config.clientId
        appID_textfeild.text = config.applicationID
        scope_textfeild.text = config.scope
        redirectURI_textfeild.text = config.redirectUri
        responseType_textfeild.text = config.responseType
    }
}
extension SettingsViewController {
    func setupTextFeilds(){
        addDoneButtonOnKeyboard(textFeild: tenant_textfeild)
        addDoneButtonOnKeyboard(textFeild: systemURL_textfeild)
        addDoneButtonOnKeyboard(textFeild: clientID_textfeild)
        addDoneButtonOnKeyboard(textFeild: appID_textfeild)
        addDoneButtonOnKeyboard(textFeild: responseType_textfeild)
        addDoneButtonOnKeyboard(textFeild: scope_textfeild)
        addDoneButtonOnKeyboard(textFeild: redirectURI_textfeild)
        addDoneButtonOnKeyboard(textFeild: widgetID_textfeild)
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
        let rightButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done(sender:)))
        rightButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    @objc func done(sender: UIBarButtonItem){
        var info = [String: Any]()
        info["clientid"] = clientID_textfeild.text
        info["domainoauth"] = tenant_textfeild.text
        info["systemurl"] = systemURL_textfeild.text
        info["applicationid"] = appID_textfeild.text
        info["redirecturi"] = redirectURI_textfeild.text
        info["scope"] = scope_textfeild.text
        info["responsetype"] = responseType_textfeild.text
        UserDefaults.standard.setDict(dict: info, for: "OAuthConfig")
        self.navigationController?.popViewController(animated: true)
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
