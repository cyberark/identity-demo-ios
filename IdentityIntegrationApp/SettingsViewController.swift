
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

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        tenant_textfeild.delegate = self
        addDoneButtonOnKeyboard(textFeild: tenant_textfeild)
    }
    
}
extension SettingsViewController {
    func config(){
        guard let config = plistValues(bundle: Bundle.main, plistFileName: "IdentityConfiguration") else { return }
        tenant_textfeild.text = config.domain
    }
}
extension SettingsViewController {
    func addDoneButtonOnKeyboard(textFeild: UITextField){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textFeild.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        
        if let urlString = tenant_textfeild.text {
            if urlString.isValidURL {
                var url = urlString
                if (!urlString.lowercased().hasPrefix("http://") || !urlString.lowercased().hasPrefix("https://")) {
                    url = "https://\(url)"
                }
                //updatePlist(domain: url)
                tenant_textfeild.resignFirstResponder()
            } else {
                showAlert(message: "Please provide valid url...")
            }
        }
    }
    /*func updatePlist(domain: String){
        guard
            let path = Bundle.main.path(forResource: "IdentityConfiguration", ofType: "plist"),
            var values = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            print("Missing CIAMConfiguration.plist file with 'ClientId' and 'Domain' entries in main bundle!")
            return
        }
        values["domainautho"] = domain
        values.writeToFile(path, atomically: true)
    }*/
    
}
